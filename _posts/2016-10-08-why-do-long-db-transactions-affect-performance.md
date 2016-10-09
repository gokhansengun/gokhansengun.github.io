---
layout: post
title: Why Do Long Database Transactions Affect Performance?
level: Intermediate
lang: en
published: true
ref: why-do-long-db-transactions-affect-performance
---

So almost everybody working with database transactions knows that the transactions should be started and then committed as soon as we are done with it to have better performance. Is this really the case? If this is the case, what is the underlying mechanism causing performance issues if we start a transaction and do not hurry up in committing it or our business just does not allow to commit it very quickly? In this blog post, we will try to dig this subject by using a few programs.

### Work Summary

In this blog, we will try to see mechanics of database transaction management and try to prove that the database transactions should be committed as quickly as possible in order not to lack performance. 

* We will first introduce what a database transaction is.
* We will investigate how an application handles a transaction with the database server.
* We will learn what connection pooling is.
* We will write a program to better see the mechanics of the database transaction handling of an application.
* We will alter the program to show performance hit this time if long running database transactions are used.
* We will talk about whether ambient transactions behave differently than connection transactions.
* We will finally talk about the countermeasures to alleviate performance issues if we just really can not commit quickly due to the business logic we are running. 

### Prerequisites

In order to follow this blog and the examples given easily, you need to be familiar with Docker Compose and Make a bit. Being able to run docker-compose and running Make will be enough. Even if you do not know Docker Compose and Make or just do not want to use them or do not want to follow along, you can trust what is written and tried here and still benefit from it :)

### Disclaimer

**Please note that everything written here is valid for .NET.** Although very unlikely, database transaction management in other platforms may be different and these explanations might be not valid.

### What is a database transaction?

Official definition of Database Transaction may be found in [Wikipedia](https://en.wikipedia.org/wiki/Database_transaction). In practice, think of an operation which requires you to interact with the database more than one time, and you want the operation to either succeed as a whole or in case of a failure revert the changes to the point of failure. For example, in order to register a new user to the system, you will first create a new entry for the user in `Users` table and assign an existing role to the user in `UserRoles` table. In this case, transaction is used to ensure that these two operations are executed as a unit. When the both operations succeed then they succeed as a unit, there is nothing fancy for transaction here, it just commits. When the first operation (adding an entry into `Users` table) succeeds but the second (assigning an existing role to the user) fails, the transaction is required to roll the first operation back, namely the new user successfully added to the `Users` table shall be removed so the operation as a whole fails without any remnant in the database.

Most striking database transaction example however related with money as you may have guessed. Let us pretend that Person A wants to transfer 100$ to Person B. Think of the scenario that 100$ have correctly been withdrawn from Person A's account, he has now -100$. While depositing 100$ to Person B's account however there has been a problem and the money will not be deposited. At the end, Person A lost 100$ to the bank. Using database transactions could avoid the situation. Upon failure on depositing 100$ to Person B's account, the database could be required to revert the 100$ withdraw operation of Person A. In this scenario, nobody loses money. Person A could retry the operation and this time it could succeed.

### How .NET handles a transaction with the database server?

.NET applications issue queries to the database servers through `SqlCommand` object which requires an `SqlConnection` to be created. `SqlConnection` under the hood, communicates with the database using a pipe, TCP connection, etc. 

.NET provides the generic interface (ADO.NET) to communicate with the databases, this interface does not know any database. In order to communicate with a database, you need a database data provider written for the database. For example, in order to use MS-SQL database, you need the data provider for MS-SQL in namespace `System.Data.SqlClient`. To use one of the greatest Open Source databases, PostgreSQL you need [Npgsql](http://www.npgsql.org/) as Data Provider.

Keeping the lecture short, when the application code issues a transaction to ADO.NET, ADO.NET passes it to the database data provider which instructs the database in the correct way that the queries through this connection will be transactional unless the transaction is committed or all rolled back. So queries using a connection for which a transaction is created are included in the transaction. Looking this from the other side, the data provider can not use this connection for other queries that does not want to use the transaction because the data provider and the database is using the connection to keep track of the queries used in the transaction. This is an important observation. This connection will belong only to the queries that are part of the transaction and it will not be usable by others until the transaction committed or rolled back. 

### What is Connection Pooling?

Most database data providers are using connection pooling to boost the performance. In order to communicate with the database, database data providers use pipe, TCP or another communication mechanism. Creating the connection (especially TCP connection due to three-way-handshake) is an expensive operation, therefore database data providers are trying to be smart and manage connections optimal based on the usage. For example, data provider does not close the connection immediately after executing the first command in case another command is received shortly after. In the same way, when the application sends multiple commands to the data provider, data provider may open multiple connections and keep them open to satisfy the requests. Finally data providers may be configured to open a minimum number of connections upfront and does not go beyond a maximum number of connections limit. For example, we may configure the data provider that in the first hit, it creates 10 connections and it does not go beyond 100 even if there is no available connection and there is a command to be satisfied. Connection Pooling is setup in application's configuration file `*.config` with Connection Strings. For the scenario given above, MS-SQL and PostgreSQL Connection String Examples are given below.

MS-SQL:

```
"....;min pool size=10;max pool size=100;"
```

PostgreSQL:

```
"....;Minimum Pool Size=10;Maximum Pool Size=100;"
```

In order to better understand the connection pooling and its power, think a situation where we have maximum number of connections set to 100 (which is the default BTW). If on the average, our database queries are resulted in 50 ms, it means we can issue 20 (1000 / 50) commands in 1 second on single connection, 100 connections means 2000 (20 x 100) commands in a second which is a very good number. As you may see, the correct number of maximum connections should be engineered according to the application's behaviour.

Please note that connections pools are per process and per connection string. What that means is that every process has its own connection pool and the connection pool inside a process is only reused if the connection strings are the same.

### A C# program to explain .NET database transaction handling

Enough talking, let us prove what we have just written. I will be using PostgreSQL for the demonstration but you may use MS-SQL server by switching the entry in `appSettings` like this `<add key="db" value="MsSql"/>` from `<add key="db" value="Postgres"/>`.

Below repository on `master` branch creates a console program that 

* Sets the maximum number of connections to 2
* Sets connection timeout (time to wait until connecting to the database) to 5 seconds
* Spawns 4 concurrent threads to create a transaction that query something and wait for 6 seconds before committing it
* Waits for 4 concurrent threads to finish

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/master)

Below is an excerpt from the code. It is just depicting how `SqlConnection`, `SqlTransaction` and `SqlCommand` objects are created and executed. Carefully look into the lines where the Thread is slept for 6000 ms `Thread.Sleep(6000)` before committing the transaction `transaction.Commit()`. So this is essentially simulating the question that we are looking for the answer. We are explicitely sleeping the Thread which mimics a slow web request. The important point is we are keeping the transaction open for at least 6 seconds, therefore keeping the database connection unusable for 6 seconds for other threads. 

```csharp
using (var sqlConnection = NewDbConnection(connStr))
{
    sqlConnection.Open();
    
    using (var transaction = sqlConnection.BeginTransaction(IsolationLevel.ReadCommitted))
    {
        using (var sqlCommand = sqlConnection.CreateCommand())
        {
            sqlCommand.CommandText = "SELECT 1";
            sqlCommand.CommandType = CommandType.Text;
            sqlCommand.Transaction = transaction;

            Console.WriteLine($"Executing the command for index: {taskId}");

            sqlCommand.ExecuteNonQuery();

            Thread.Sleep(6000);

            transaction.Commit();

            Console.WriteLine($"Committed for index: {taskId}");
        }
    }
}
```

If you remember we have set connection timeout to 5 seconds and max connections to 2. Creating 4 threads, and having them wait for 6 seconds each, we are expecting the first 2 threads are able to connect to the database and the other 2 to wait for an available connection. 5-second connection timeout has to cause waiting 2 threads to timeout and fail.

Let's setup the test now. We will use Mono to run the console app and Docker Compose to orchestrate the db and console app.

In order to follow along, clone the repository given above to a directory and open a terminal, then navigate to the `Docker` directory. Issue `make app` command, this simple command with the setup ready for you will build the solution inside a Mono container, run the PostgreSQL database, wait for 8 seconds for it to start and then run the console app creating transactions using again a Mono container.

Anyway, you will see the below output. Everything is run as we expected. On `23:54:27` two threads were able to obtain connections and started transactions on them then waited for 6 seconds before committing, they have committed the transactions on `23:54:33` but it was too late for the other two threads waiting for an available connections and they have both failed with error `The connection pool has been exhausted`. If you are careful enough, you might ask why did the remaining threads fail on `23:54:33` instead of `23:54:32` which is 5 seconds (connection timeout) away from the connection attempt. Well, I am not sure, it could be the data provider, in this case Npgsql) or my error handling in the tasks management I have done. I will leave it to you, appreciate if you leave your findings as a comment.

```
app_1          | 23:54:27 Executing the command for threadId: 2
app_1          | 23:54:27 Executing the command for threadId: 1
app_1          | 23:54:33 Committed for threadId: 1
app_1          | 23:54:33 Committed for threadId: 2
app_1          | 23:54:33 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
app_1          | 23:54:33 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
```

### Another C# program to explain performance hit of long transactions

More examples will let us grab the subject better.

Below repository on `perf-hit` branch creates another console program that 

* Sets the maximum number of connections to 5 this time
* Sets connection timeout (time to wait until connecting to the database) to 30 seconds
* Spawns 20 concurrent threads to do the following 100 times 
  * Create a transaction that query something and wait for 100 milliseconds before committing it
* Waits for all these threads to complete 100 loops and measures the time

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/perf-hit)

Doing 100 loops and waiting 100 ms in each thread, we would expect that the whole operation above to take only 10 seconds (100 x 100 ms = 10000 ms) plus some database query time for `SELECT 1` which is probably smaller than a milliseconds most of the time. However you will see that this will not be the case because we have more threads (20) than we have available database connections in the connection pools (5). 

In order to follow along, switch to the `perf-hit` branch, then navigate to the `Docker` directory. Issue `make clean` first to remove old container and `make app` command to create new and run the test.

Running the application this way shows the following output on my machine.

```
...
app_1          | 00:20:09 Committed for threadId: 14
app_1          | 00:20:09 Committed for threadId: 13
app_1          | 00:20:09 Committed for threadId: 9
app_1          | 00:20:09 Committed for threadId: 12
app_1          | Putting 100 for each of 20 took 41672 milliseconds
```

So it took around 41 seconds instead of 10 seconds. OK 10 seconds is utopic, but it must be something closer. Bottleneck in the database connection pool caused this. Threads have lost most of their times in trying to find a suitable connection because of the ones hold by Transactions. Hopefully we have Github and we have Docker and we can prove this observation by allowing more database connections in the next test, God bless them both.

Below repository on `perf-hit-avail-more-conns` branch creates another console program that 

* Sets the maximum number of connections to 40
* Sets connection timeout (time to wait until connecting to the database) to 30 seconds
* Spawns 20 concurrent threads to do the following 100 times 
  * Create a transaction that query something and wait for 100 milliseconds before committing it
* Waits for all these threads to complete 100 loops and measures the time

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/perf-hit-avail-more-conns)

In order to follow along, switch to the `perf-hit-avail-more-conns` branch, then navigate to the `Docker` directory. Issue `make clean` first to remove old containers and `make app` command to create new and run the test.

Running the application this way shows the following output on my machine.

```
app_1          | 00:30:02 Committed for threadId: 11
app_1          | 00:30:02 Committed for threadId: 10
app_1          | 00:30:02 Committed for threadId: 3
app_1          | 00:30:02 Committed for threadId: 4
app_1          | Putting 100 for each of 20 took 10699 milliseconds
```

This time it took 10.7 seconds, very very close to the theoretical limit of 10 because this time we had more (40) connections than we need (20), keeping the connections busy did not affect other threads and all were functioning properly.

So, is that all, can we increase the number of database connections in the connection pool and get the database performance we have? Seems so but let us be patient and continue.

### What about using Ambient Transactions instead of Connection Transactions

What we have worked on above was all classical Connection Transactions, we also have nice Ambient Transactions. What about them? Do they help us solve the problem? Short answer is NO but worth trying.

Ambient Transactions are great, really great. With the help of them, we are not tied to a connection, we can unite a transaction with every Transaction-Aware component WCF for example. So a transaction consisting of a WCF service call and database call could be set as a unit of work. However the database and the data provider still needs to keep track of the commands, transactions and they still use the connection as a means of that.

Below patch converts the Connection Transaction in our code to Ambient Transaction.

```
-   using (var transaction = sqlConnection.BeginTransaction(IsolationLevel.ReadCommitted))
+   using (var tran = new TransactionScope())
    {
...
-       sqlCommand.Transaction = transaction;
... 
-       transaction.Commit();
+       tran.Complete();

```

The working code could also be found in below repository.

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/ambient-transactions)

Again in order to follow along, switch to the `ambient-transactions` branch, then navigate to the `Docker` directory. Issue `make clean` first to remove old containers and `make app` command to create new and run the test.

The output is below and it did not change between Connection Transactions and Ambient Transactions.

```
app_1          | 00:50:23 Executing the command for threadId: 0
app_1          | 00:50:23 Executing the command for threadId: 1
app_1          | 00:50:29 Committed for threadId: 1
app_1          | 00:50:29 Committed for threadId: 0
app_1          | 00:50:29 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
app_1          | 00:50:29 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
```

### Conclusion

As we clearly shown above, keeping the database transactions too long really hurts the performance if your database connections in the connection pool is smaller than the need in your application. So why do not we just go ahead and increase the number of connections in the pool to the maximum number whatever that is? It is not that easy.

Connection pooling is an optimization for performance, it is good one. This is both because it reuses the connection multiple times and it protects database server to overload. Think of a situation where your app issues 10K queries at the same time which can kill your database server. It might not be your app, actually most of the time your app is not alone, there are many applications sharing the database. Using all the available connections or indirectly resources (CPU, RAM), you make the database server unusable for both you and other users of the server. So as you may have guessed, it is again mostly an engineering problem, you have to define the maximum number of connections by engineering it.

There is only one trick that could help reducing transaction open time though. Put database interaction at the end of the block and initiate transaction as late as possible. If your app uses a web service to validate a payment for example, validate through the service first, start the transaction and place the order later (assuming placing the order requires transaction). Starting the transaction, validating payment and placing the order will cause performance hit.

Having said all of this, there is another truth about the performance, not every systems need this type of a performans optimization. If you are developing a system for only a few users, do not worry much about the performance and concentrate on implementing the functionality and the development cost.

I hope you enjoyed as much as I enjoyed writing all these. Waiting for the comments and corrections if any.

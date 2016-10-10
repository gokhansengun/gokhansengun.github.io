---
layout: post
title: ASP.NET MVC and Web API - Comparison of Async / Sync Actions 
level: Intermediate
lang: en
published: true
ref: asp-net-mvc-and-web-api-comparison-of-async-or-sync-actions
---

ASP.NET provides async actions starting with .NET 4.5. Nowadays asynchronism is a trendy subject which nobody could just ignore or resist to adapt. In this blog, we will try to dig what it brings to the table and how it compares with the good old synchronous actions, we happily used for years. Instead of giving only the assertions, we will create sample programs and observe the behaviour while it is happening. This approach will hopefully help understand how ASP.NET processes the requests when it comes to the thread management. There is no big difference between handling of MVC and Web API actions, for ease of demonstration we will use Web API here. Evertyhing written for Web API will be valid for MVC too.

### Work Summary

In the blog, we will try to compare and contrast async and sync actions from various aspects in the use cases.

* We will first introduce async actions .NET provides.
* We will compare the behaviour of async and sync actions.
* We will then cite the use cases and discuss where async actions just fit better and where sync actions shine.
* We will finally create some programs to prove the assertions and also learn how ASP.NET processes the requests. 

### Prerequisites

In order to follow this blog and the examples given easily, you need to be familiar with Docker Compose, Make and JMeter a bit. Being able to run docker-compose, running Make and JMeter will be enough. Even if you do not know Docker Compose, Make and JMeter or just do not want to use them or do not want to follow along, you can trust what is written and tried here and still benefit from it :)

### Async actions in ASP.NET




### Conclusion


I hope you enjoyed as much as I enjoyed writing all these. Waiting for the comments and corrections if any.

### References

https://www.asp.net/mvc/overview/performance/using-asynchronous-methods-in-aspnet-mvc-4
http://blog.stevensanderson.com/2010/01/25/measuring-the-performance-of-asynchronous-controllers/

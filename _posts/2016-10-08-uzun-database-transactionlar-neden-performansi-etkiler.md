---
layout: post
title: Uzun Veri Tabanı Transaction'ları Neden Performansı Etkiler?
level: Orta
published: true
lang: tr
ref: why-do-long-db-transactions-affect-performance
---

Veri tabanı Transaction'ları ile uğraşan herkes iyi bir performans için Transaction'ların başlatılır başlatılmaz kısa bir süre içinde Commit'lenmesi gerektiğini bilir. Peki bu bilgi gerçekten doğru mudur? Eğer doğruysa veri tabanı Transaction'larını başlattıktan sonra Commit'lemekte acele etmediğimizde veya aslında acele etmek istesek bile iş kurallarının buna izin vermediği durumlarda, performansı olumsuz etkileyen esas mekanizma nedir? Bu blog yazısında, bu konuyu örnek programlar yazarak irdelemeye çalışacağız.

### Çalışma Özeti

Bu blog'da veri tabanı Transaction yönetiminin mekaniklerini inceleyeceğiz ve uygulamamızın performanslı bir şekilde çalışabilmesi için veri tabanı Transaction'larının gerçekten de başlatıldıktan sonra kısa bir süre içerisinde Commit'lenmesi gerektiğini ispatlamaya çalışacağız. 

* Öncelikle veri tabanı Transaction'ların ne olduğu üzerinde duracağız.
* Uygulamaların Transaction'ları veri tabanı sunucusu ile birlikte nasıl organize ettiklerini araştıracağız.
* Connection Pooling'in ne olduğunu öğreneceğiz.
* Veri tabanı Transaction yönetiminin mekaniklerini çok net bir şekilde gözlemleyebileceğimiz bir örnek uygulama yazacağız. 
* Yazdığımız programı değiştirerek uzun süre koşan veri tabanı Transaction'larının performans problemi yarattığını rakamlarla ortaya koyacağız.
* Ambient Transaction'ların Connection Transaction'lara göre farklı davranıp davranmadığını yazdığımız örnek programı değiştirerek göstermeye çalışacağız.
* Son olarak eğer veri tabanı Transaction'larını iş kuralları gereği hızlı bir şekilde Commit edemiyorsak alabileceğimiz önlemleri ve izleyebileceğimiz farklı yöntemlerin üzerinde durmaya çalışacağız.

### Ön Koşullar

Bu blog'da verilen program örneklerini takip edebilmek ve kendiniz çalıştırabilmek için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker Compose ile oluşturulan sistemi çalıştırabilmek, bu konuda bilgi için [Docker Compose Blog'una](/docker-compose-nasil-kullanilir/) göz atabilirsiniz.
* Make aracının ne işe yaradığı ile ilgili fikir sahibi olmak için [Make Blog'una](/makefile-ve-make-nedir-ne-ise-yarar/) hızlıca göz atmanızda fayda olabilir.

Docker Compose ve Make'e aşina değilseniz ya da bunları kullanmak istemiyorsanız ya da adımları kendiniz takip etmeyi gereksiz buluyor ve verilen sonuçlara güveniyorsanız yine de bu blog yazısından fayda sağlayabilirsiniz :)

### UYARI

**Bu blog'da yazılan her şey .NET için geçerlidir.** Düşük bir ihtimal olmakla birlikte diğer platformlarda veri tabanı Transaction yönetimi .NET'ten farklılık gösterebilir ve bu blog'daki açıklamalar geçerli olmayabilir.

### Veri tabanı Transaction'ı nedir?

Veri tabanı Transaction'ının resmi ve formal tanımını [Wikipedia](https://en.wikipedia.org/wiki/Database_transaction)'dan bulabilirsiniz. Pratik olarak, tamamlamak için veri tabanı ile birden fazla kere iletişime geçmeniz gereken bir operasyon olduğunu ve bu operasyonun ya bütünüyle başarılı ya da bütünüyle başarısız olmasını istediğimizi varsayalım yani parçalı olarak başarılı olan işlemlerde başarısız bir işlemle karşılaşıldığında önceki başarılı işlemlerin geri alınması gerektiğini düşünelim. Örneğin, yeni bir kullanıcıyı sisteme dahil etme işleminde öncelikle `Users` tablosunda yeni bir kayıt oluşturarak kullanıcı adı ve diğer bilgileri kaydederiz sonra da `UserRoles` tablosuna, eklediğimiz yeni kullanıcıyı var olan bir rolle ilişkilendirmek üzere yeni bir kayıt ekleriz. Bu işlemde bir Transaction kullanılması uygundur çünkü genellikle bu iki işlemin ya ikisinin birden başarılı ya da ikisinin birden başarısız olmasını isteriz. İki işlem birden başarılı ise Transaction Commit edilir ve işlem sonuçlandırılır burada özel bir durum yoktur. Birinci işlemin (`Users` tablosuna kayıt eklemenin) başarılı ancak ikinci işlemin (kullanıcıya bir rol atama) başarısız olduğu durumda, Transaction, ilk işlemi de geri alır (Rollback) yani `Users` tablosuna yeni eklenen kaydı siler dolayısıyla da bütün işlemin başarısız olmasını ve ardında herhangi bir kalıntı bırakmamasını sağlamış olur.
 
En çarpıcı veri tabanı Transaction örneği kolaylıkla tahmin edebileceğiniz gibi akçeli işlerdedir. A kişisinin B kişisine banka aracılığıyla 100 TL transfer etmek istediğini varsayalım. Senaryomuzda 100 TL A kişisinin hesabından başarılı bir şekilde çekilsin, dolayısıyla A kişisinin hesabında -100 TL olsun. Çekilen bu 100 TL'yi B kişisinin hesabına aktarırken bir problem çıktığını ve aktarımın tamamlanamadığını düşünelim. Bu işlem sonunda, A kişisinin 100 TL'si eksilecek B kişisine para aktarılamayacak ve 100 TL muhtemelen bankanın hanesine geçecektir. Veri tabanı Transaction'ları kullanılarak bu durumun önüne kolaylıkla geçilebilir. İşlem başlangıcında başlatılan Transaction B kişisinin hesabına para aktarılırken oluşan hata üzerine veri tabanında A kişisinin hesabında yapılan para çekme işlemini geriye alır. Böylelikle A kişisi para transferinde bir hata olduğunu  ancak hesabındaki paranın değişmediğini görür. Kimse para kaybetmez. A kişisi isterse sonradan para transferini tekrar deneyebilir.

### .NET Transaction'larını veri tabanı sunucusu ile nasıl kurgulamaktadır?

.NET uygulaması veri tabanı sunucusuna `SqlCommand` nesnesi üzerinden sorguları yollar. `SqlCommand` nesnesi ise `SqlConnection` nesnesinden yaratılır. `SqlConnection` nesnesi ise veri tabanı sunucusu ile pipe, TCP bağlantısı, vb ile iletişim kurar.

.NET veri tabanı ile iletişim için ADO.NET adında jenerik bir arayüz sunar, bu arayüz iletişim kurulacak veri tabanından tamamen bağımsızdır. Bir veri tabanı ile iletişim kurabilmek için ilgili veri tabanı için hazırlanmış Data Provider'ı kullanmak gereklidir. Örneğin MS-SQL veri tabanına .NET uygulamasından bağlanabilmek için `System.Data.SqlClient` namespace'inde bulunan Data Provider'ın kullanılması gereklidir. Dünyanın en popüler açık kaynak kodlu veri tabanlarından biri olan PostgreSQL veri tabanı için [Npgsql](http://www.npgsql.org/) veya benzeri bir Data Provider'ı kullanmak gereklidir. 

Uygulama kodu ADO.NET ile bir Transaction başlattığında, ADO.NET bu isteği veri tabanı için sağlanmış olan Data Provider'a gönderir, Data Provider da uygun şekilde veri tabanına, Commit veya Rollback olana kadar ilgili bağlantıdan gelen bütün sorguların Transactional olacağını belirtir. Anlaşılacağı üzere ilgili Transaction'dan gelen bütün sorgular aynı veri tabanı bağlantısı üzerinden veri tabanına iletilir ve bu bağlantı Transaction'a dahil olmayan komutların veri tabanına aktarılmasında kullanılamaz. Veri tabanı bağlantısı başka sorgular için kullanılamaz çünkü Data Provider ve veri tabanı Transaction'a dahil olan komutları bağlantı bazlı olarak tutarlar. Bu çok önemli bir bilgidir çünkü bu veri tabanı bağlantısı sadece Transaction'a dahil olan sorgular tarafından kullanılabilecek ve Transaction sonlanmadığı müddetçe yani Commit ya da Rollback olmadıkça ilgili bağlantıdan başka işlem yapılamayacaktır. Bu önemli notu burada bırakarak devam edelim.

### Connection Pooling Nedir?

Çoğu Data Provider veri tabanı ile iletişim performansını artırmak için Connection Pooling kullanmaktadır. Veri tabanı ile iletişim kurabilmek için Data Provider'ların pipe, TCP bağlantısı, vb iletişim methodları kullandığını söylemiştik. Yeni bir bağlantı yaratmak (özellikle de three-way-handshake'den dolayı TCP bağlantısı yaratmak) pahalı bir operasyondur, dolayısıyla Data Provider'lar akıllı algoritmalar kullanarak bağlantıları optimal bir şekilde kullanmaya özen göstermektedir. Örneğin, Data Provider veri tabanı bağlantısını ilk kullanımın bitişinden hemen sonra kapatmaz, belirli bir süre ikinci bir sorgu gelme ihtimaline karşın açık tutar. Aynı şekilde uygulama Data Provider'a aynı anda birden fazla sorgu gönderdiğinde Data Provider birden fazla veri tabanı bağlantısı açarak istekleri karşılamaya çalışır. Son olarak Data Provider'lar uygulama açılışında (aslında ilk veri tabanı isteğini aldıklarında) belirli sayıda bağlantıyı hazır hale getirmeleri kullanılmasa dahi açık tutmaları ve belirli sayıda bağlantı açtıktan sonra daha fazla bağlantı açmamaları konusunda konfigüre edilebilirler. Örneğin, Data Provider'ı ilk veri tabanı isteğinde 10 bağlantı açması ve bu 10 bağlantıyı kullanılmasa da sürekli açık tutması, en yoğun kullanımda 100 limitine kadar yeni bağlantılar açması fakat 100'den sonra yeni bağlantı açmaması konusunda konfigüre edebiliriz. Connection Pooling, uygulamanın konfigürasyon dosyasında `*.config` Connection String'le konfigüre edilir. Yukarıdaki senaryo için MS-SQL ve PostgreSQL Connection String'leri aşağıda verilmiştir.  

MS-SQL:

```
"....;min pool size=10;max pool size=100;"
```

PostgreSQL:

```
"....;Minimum Pool Size=10;Maximum Pool Size=100;"
```

Connection Pooling ve getirdiği gücü daha iyi anlamak için maksimum bağlantı sayısının 100 verildiği (bu arada default bağlantı sayısı budur) bir durumu ele alalım. Ortalama olarak veri tabanı sorgularımızın 50ms'de sonuçlandığını düşünürsek, bir bağlantıdan 1 saniyede 20 (1000 / 50) sorgu gönderebiliriz. 100 bağlantıda toplam query sayısı saniyede 2000 (20 x 100) sorgu olmaktadır ki bu çok iyi bir rakamdır. Görüldüğü gibi izin verilen maksimum bağlantı sayısı uygulama ihtiyaçlarına ve veri tabanı kapasitesine göre Enginner edilmelidir.

Bu noktada Connection Pool'ların proses ve Connection String bazlı olduğuna dikkat etmeliyiz. Herbir proses'in kendine ait bir Connection Pool'u vardır ve farklı proses'ler arasında paylaşılmaz. Aynı proses içinde de Connection Pool'un paylaşılması için Connection String'lerin aynı olması gerekir.

### .NET Transaction yönetimini açıklayan bir C# programı

Yeterince konuştuk, şimdi konuştuklarımızı ispatlama zamanı. Ben demo'larda PostgreSQL kullanacağım ancak `appSettings`'de `<add key="db" value="Postgres"/>` ayarını `<add key="db" value="MsSql"/>` ile değiştirerek MS-SQL kullanabilirsiniz. PostgreSQL tercihinin sebebi uygulamayı Docker ile birlikte Linux üzerinde çalıştırabilmektir. MS-SQL Server Linux'a geldiğinde yeni demo'larda MS-SQL tercih edeceğim.

Aşağıda verilen Github Repository'sinin `master` Branch'indeki konsol programı

* Veri tabanına yapılan maksimum bağlantı sayısını 2 adet olarak belirlemiş
* Veri tabanına yapılan bağlantı isteklerinin Timeout olma süresini 5 saniye olarak belirlemiş
* 4 eş zamanlı Thread yaratarak bu Thread'ler içerisinde bir Transaction yaratmış, bir sorgu göndermiş ve Transaction'ı Commit etmeden önce 6 saniye boyunca Thread'i bekletmiş
* Sonra da 4 eş zamanlı Thread'i bitmeleri için beklemiştir.

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/master)

Aşağıda Github Repository'de tamamını bulabileceğiniz koddan bir parça içermektedir. Bu kod parçası sadece `SqlConnection`, `SqlTransaction` ve `SqlCommand` nesnelerinin nasıl yaratıldığı ve çalıştırıldığını göstermektedir. Dikkatli bir şekilde göz atmanız gereken yer Thread'in Transaction Commit `transaction.Commit()` edilmeden önce 6 saniye boyunca uyutulduğu `Thread.Sleep(6000)` satırlardır. Bu kısım temel olarak aslında cevabını aradığımız soruyu simüle etmektedir. Biz bilinçli olarak Thread'i uyutarak aslında yavaş Web isteklerini taklit etmekteyiz. Önemli nokta bizim Transaction'ı 6 saniye boyunca açık tutmamız dolayısıyla da bu veri tabanı bağlantısını 6 saniye boyunca başka sorgular (başka Thread'ler) için kullanılamaz kılmamızdır. 

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

Hatırlarsanız veri tabanı bağlantı Timeout'unu 5 saniye olarak ayarlamış ve izin verilen maksimum bağlantı sayısını 2 adet olarak belirlemiştik. 4 Thread yaratıp bunların Commit edilmeden önce 6 saniye boyunca bekletilmesi durumunda şanslı ilk 2 Thread'in ilk 2 bağlantıyı kullanarak veri tabanına bağlanmasını ve diğer 2 Thread'in de veri tabanına bağlantı kurmak için beklemelerini fakat 5 saniye olarak belirlenen Timeout'dan dolayı bu 2 Thread'in uygun bir bağlantı bulamadan Timeout olmasını bekliyoruz.

Şimdi testimizi hazırlayalım. Konsol uygulamasını çalıştırmak için Mono kullanacağız. Make, Docker Compose komutları ile birlikte veri tabanını ve konsol uygulamasını orkestre edecektir.

Siz de takip etmek istiyorsanız, yukarıda verilen Github Repository'yi bir klasöre klonlayın ve bir terminal açarak ana klasörün altındaki `Docker` klasörüne gidin. `make app` komutunu verin ve bu komut Docker Compose kullanarak .NET Solution'ı Mono Container içerisinde build ederek çalıştıracak ve ayrıca PostgreSQL veri tabanını da hazır hale getirecektir. Make PostgreSQL Container'ı başlattıktan sonra veri tabanının hazır hale gelmesi için uygulamayı başlatmadan önce 8 saniye bekleyecektir. 

İlgili komutu çalıştırdığımızda aşağıdakine benzer bir ekran çıktısı elde ediyoruz. Aslında beklediğimiz sonuç ortaya çıktı. `23:54:27`'te şanslı 2 Thread 2 veri tabanı bağlantısını elde edip Transaction'ları başlattılar ve onları Commit etmeden 6 saniye beklediler ve Transaction'larını `23:54:33`'ta Commit ettiler. İlk 2 Thread Transaction'larını 6 saniye sonra Commit ederek veri tabanı Connection'larını serbest bıraktılar ancak artık diğer 2 thread için çok geç olmuştu çünkü veri tabanı bağlantısı için belirlenen süre 5 saniyeydi. Bağlantı bulamayan ve 5 saniye boyunca bağlantı bekleyen Thread'ler `The connection pool has been exhausted` hatası aldılar. Eğer yeterince dikkatli iseniz bekleyen 2 Thread'in neden başlatıldıklarından 5 saniye sonra yani `23:54:32`'de değil de 6 saniye sonra yani `23:54:33`'de log ürettiğini sorabilirsiniz. Bu konu kullanılan Npgsql Data Provider'ı ya da benim Task hata yönetim kodumla alakalı olabilir. Bu konunun aydınlatılmasını siz okuyuculara bırakıyor, aşağıda yorumlarınızı bekliyor ve devam ediyorum. 

```
app_1          | 23:54:27 Executing the command for threadId: 2
app_1          | 23:54:27 Executing the command for threadId: 1
app_1          | 23:54:33 Committed for threadId: 1
app_1          | 23:54:33 Committed for threadId: 2
app_1          | 23:54:33 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
app_1          | 23:54:33 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
```

### Uzun Transaction'ların yarattığı performans problemini açıklayan başka bir C# programı 

Daha fazla örnek, konuyu anlamamızı kolaylaştıracaktır.

Aşağıda verilen Github Repository'sinin `perf-hit` Branch'indeki konsol programı

* Veri tabanına yapılan maksimum bağlantı sayısını bu kez 5 adet olarak belirlemiş
* Veri tabanına yapılan bağlantı isteklerinin Timeout olma süresini 30 saniye olarak belirlemiş
* 20 eş zamanlı Thread yaratarak aşağıdaki işlemi 100 kere tekrarlatmış
  * Bir Transaction yaratmış, bir sorgu göndermiş ve Transaction'ı Commit etmeden önce 100 milisaniye boyunca Thread'i bekletmiş
* Sonra da 20 eş zamanlı Thread'in 100'er döngüyü bitmeleri için beklemiş ve geçirilen zamanı ölçmüştür.

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/perf-hit)

Her bir döngüde 100 ms bekleyerek 100 döngüyü tamamlayan Thread'lerin ideal ortamda bütün işlemi sadece 10 saniyede (100 x 100 ms = 10000 ms) tamamlamasını bekleriz. Bu 10 saniyenin içerisine veri tabanına `SELECT 1` için yapılan sorgu sürelerini de eklememiz gerekir ancak bu sorgular muhtemelen 1 ms'den bile daha kısa sürecek sorgular olduğu için gözardı edilebilirler. 

Bunları söylemekle birlikte 20 Thread için kullanıma sunulan sadece 5 adet veri tabanı bağlantısı olacağı için ve Transaction'lardan dolayı herbir Thread 100 saniye boyunca bir bağlantıyı başka Thread'ler için kullanılamaz hale getireceği için bir darboğaz yaşamayı beklemekteyiz.

Eğer kendi bilgisayarınızdan takip ediyorsanız, Git'te `perf-hit` Branch'ine geçiş yaparak terminal'de `Docker` klasöründe olduğunuza emin olun. Önceki uygulamaları silmek için `make clean` komutunu verin ve yeni uygulamaları yaratmak için `make app` komutunu çalıştırın. 

Uygulamanın benim bilgisayarımda çalışması sonucunda aşağıda çıktı oluştu.

```
...
app_1          | 00:20:09 Committed for threadId: 14
app_1          | 00:20:09 Committed for threadId: 13
app_1          | 00:20:09 Committed for threadId: 9
app_1          | 00:20:09 Committed for threadId: 12
app_1          | Putting 100 for each of 20 took 41672 milliseconds
```

Çıktıya göre bütün işlemin tamamlanması hesaplarımızın aksine 10 saniye yerine 41 saniye sürdü. Kabul etmek gerekir ki 10 saniye biraz ütopikti ancak sonucun 10 saniyeye yakın olmasını beklerdik. Veri tabanı bağlantı sayısındaki darboğazın bu sonuca yol açtığını düşünüyoruz. Uygun bağlantı bekleyen Thread'ler zamanın çoğunu Transaction'lar tarafından tutulan veri tabanı bağlantılarının uygunluğunu bekleyerek geçirdiler ve işlemin tamamlanması çok uzun sürdü. Neyse ki elimizde Github ve Docker var (iyi ki varlar) ve bu gözlemimizi bir sonraki testte daha fazla uygun veri tabanı bağlantısına izin vererek kolaylıkla ispatlayabiliriz.

Aşağıda verilen Github Repository'sinin `perf-hit-avail-more-conns` Branch'indeki konsol programı

* Veri tabanına yapılan maksimum bağlantı sayısını bu kez 40 adet olarak belirlemiş
* Veri tabanına yapılan bağlantı isteklerinin Timeout olma süresini 30 saniye olarak belirlemiş
* 20 eş zamanlı Thread yaratarak aşağıdaki işlemi 100 kere tekrarlatmış
  * Bir Transaction yaratmış, bir sorgu göndermiş ve Transaction'ı Commit etmeden önce 100 milisaniye boyunca Thread'i bekletmiş
* Sonra da 20 eş zamanlı Thread'in 100'er döngüyü bitmeleri için beklemiş ve geçirilen zamanı ölçmüştür.

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/perf-hit-avail-more-conns)

Eğer kendi bilgisayarınızdan takip ediyorsanız, Git'te `perf-hit-avail-more-conns` Branch'ine geçiş yaparak terminal'de `Docker` klasöründe olduğunuza emin olun. Önceki uygulamaları silmek için `make clean` komutunu verin ve yeni uygulamaları yaratmak için `make app` komutunu çalıştırın. 

Uygulamanın benim bilgisayarımda çalışması sonucunda aşağıda çıktı oluştu.

```
app_1          | 00:30:02 Committed for threadId: 11
app_1          | 00:30:02 Committed for threadId: 10
app_1          | 00:30:02 Committed for threadId: 3
app_1          | 00:30:02 Committed for threadId: 4
app_1          | Putting 100 for each of 20 took 10699 milliseconds
```

Bu kez bütün işlerin bitmesi 41.67 saniye yerine yaklaşık 10.70 saniye sürdü ki bu da teorik limit olan 10 saniyelik değere çok yakın bir değer. Bu farkın sebebi çok açık olarak gördüğünüz üzere bu testte ihtiyaç olan 20 adet bağlantıdan da fazla 40 adet bağlantı verilmesiydi. Thread'lere ayrılan bağlantılar bol olduğu için uzun süre (100 ms) Commit olmayan Transaction'lar tarafından meşgul tutulan veri tabanı bağlantıları diğer Thread'leri bekletmedi ve işleyiş etkilenmedi.

Peki, bütün bunların ışığında Connection Pool içinde izin verdiğimiz maksimum bağlantı sayısını artırarak Transaction'ları uzun tutsak bile istediğimiz veri tabanı performansını alabilir miyiz? Evet öyle görünüyor ancak sabırlı olmakta ve olayı bütün yönleriyle incelemekte fayda var.

### Connection Transaction'lar yerine Ambient Transaction'lar kullandığımızda gördüğümüz tablo değişir mi?

Şu ana kadar hep klasik Connection Transaction'lar ile çalıştık ve hiç Ambient Transaction'lara göz atmadık. Bir karara varmadan önce onlara da bakmamızda fayda var, belki de Ambient Transaction'lar veri tabanı Transaction'larını daha iyi yönetiyor ve Transaction'lar uzun bile sürse performansı olumsuz olarak etkilemiyorlardır. Cevabı baştan verecek olursak, hayır, Ambient Transaction'lar incelediğimiz anlamda Connection Transaction'lara nazaran bir avantaj sunmuyorlar. Peki, yine deneyip göreceğiz.

Ambient Transaction'lar gerçekten çok faydalıdır. Sayelerinde veri tabanı Transaction'larında bir bağlantıya bağlı kalmaksızın aynı Scope içerisinde farklı veri tabanı işlemlerini aynı Transaction altında toplayabiliriz. Bunun yanında veri tabanı Transaction'larını Transaction-Aware WCF veya özel başka bileşenlerle birlikte aynı Transaction içerisinde kullanabiliriz. Yanlış duymadınız, bir WCF çağrısı ile bir veri tabanı işlemi aynı Unit of Work içerisinde Transactional olarak kullanılabilir. Bütün bu satışa yönelik lafların yanında Ambient Transaction'lar bile veri tabanı Transaction'larını yönetmek ve aynı Transaction içerisinde yer alan sorguların izini tutabilmek için sabit bir bağlantı kullanırlar.

Aşağıdaki Patch test programlarında Connection Transaction'ını Ambient Transaction'a çevirmektedir.

```csharp
-   using (var transaction = sqlConnection.BeginTransaction(IsolationLevel.ReadCommitted))
+   using (var tran = new TransactionScope())
    {
...
-       sqlCommand.Transaction = transaction;
... 
-       transaction.Commit();
+       tran.Complete();

```

Aynı zamanda çalışan kod aşağıdaki Github Repository'sinde de bulunabilir.

[Repository](https://github.com/gokhansengun/db-transaction-internals-demo/tree/ambient-transactions)

Eğer kendi bilgisayarınızdan takip ediyorsanız, Git'te `ambient-transactions` Branch'ine geçiş yaparak terminal'de `Docker` klasöründe olduğunuza emin olun. Önceki uygulamaları silmek için `make clean` komutunu verin ve yeni uygulamaları yaratmak için `make app` komutunu çalıştırın. 

Uygulamanın benim bilgisayarımda çalışması sonucunda aşağıda çıktı oluştu, gördüğünüz gibi uygulamanın Connection Transactions ve Ambient Transactions'la çalışması arasında bir davranış farklılığı olmadı.

```
app_1          | 00:50:23 Executing the command for threadId: 0
app_1          | 00:50:23 Executing the command for threadId: 1
app_1          | 00:50:29 Committed for threadId: 1
app_1          | 00:50:29 Committed for threadId: 0
app_1          | 00:50:29 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
app_1          | 00:50:29 EXCEPTION: with The connection pool has been exhausted, either raise MaxPoolSize (currently 2) or Timeout (currently 5 seconds)
```

### Sonuç

Örneklerle çok net olarak gördüğümüz üzere, veri tabanı Transaction'ları çok uzun süre açık tutmak, Connection Pool'da hizmete sunulan bağlantı sayısı anlık olarak ihtiyaç duyulan bağlantıdan daha az ise performansı olumsuz olarak etkiliyor. O zaman daha önce sorduğumuz soruyu tekrar soralım, peki neden hemen gidip Connection Pool'daki bağlantı sayısını artırarak bu problemden hemen kurtulmuyoruz? Tahmin edebileceğiniz gibi cevap olarak hemen Evet demek çok da kolay değil.

Connection Pooling veri tabanı iletişiminde daha iyi bir performans almak için çok anlamlı bir tekniktir ve iyi bir optimizasyondur. Bunun iki nedeni vardır; birincisi daha önce de söylediğimiz gibi aynı bağlantının farklı işler için tekrar tekrar kullanılmasına izin vermesi, ikincisi ise veri tabanı sunucusunu Overload olmaktan (fazla yüklenmek) korumasıdır. Uygulamanızın 10K sorguyu aynı anda veri tabanı sunucusuna gönderdiği bir senaryoyu düşünün, veri tabanı sunucunuzu bir anda çökertip başka sorgulara cevap veremez hale getirebilirsiniz.  

Genellikle veri tabanı sunucusu birçok uygulama tarafından ortak olarak kullanılır. Hizmete sunulan bütün bağlantıların ve buna bağlı olarak dolaylı kaynakların (CPU, RAM) sizin uygulamanız tarafından kullanıldığı düşünüldüğünde veri tabanı sunucusunu siz ve başka uygulamalar tarafından kullanılamaz hale getirebilirsiniz. Lafın uzamasından tahmin edebildiğiniz gibi burada yine bir Engineering problemi var. Uygulamanız için ayırdığınız maksimum veri tabanı bağlantı sayısını uygulamanızın ihtiyacına, kullandığınız veri tabanının kaynaklarına ve veri tabanını kullanan diğer uygulamaların yapısına göre belirlemelisiniz. 

Transaction'ların açık kalma zamanını düşürebileceğiniz sadece bir yöntem akla geliyor o da Transaction'ları mümkün olduğunca geç başlatmak. Örneğin eğer uygulamanız bir dış servisi çağırarak ödeme doğrulama yapıyorsa, öncelikle ödeme doğrulamayı Transaction dışında yapmak sonra da Transaction başlatarak içerisinde sipariş ile ilgili bilgileri (Transaction gerektirdiği düşünülmüştür) veri tabanına eklemek performans açısından avantajlıdır. Öncelikle Transaction başlatmak sonra dış web servisle ödemeyi doğrulamak sonra da kayıtları veri tabanına eklemek yüksek hacimlerde performans açısından problem yaratacaktır.

Bütün bunları söylemekle birlikte performans ile ilgili akılda tutmamız gereken en önemli şey, bütün sistemlerin bu tarz bir performans optimizasyonuna ihtiyacı olmadığıdır. Eğer geliştirdiğiniz sistem günlük sadece birkaç kullanıcı tarafından kullanılıyorsa, bu tarz bir performans optimizasyonundan ziyade fonksiyonalite ve geliştirme zamanı dolayısıyla da maliyetine dikkat etmeniz gerekir. 

Umarım siz de benim yazarken keyif aldığım kadar takip ederken keyif aldınız. Yorumlarınızı ve varsa düzeltmelerinizi yorum bölümünden bekliyorum.


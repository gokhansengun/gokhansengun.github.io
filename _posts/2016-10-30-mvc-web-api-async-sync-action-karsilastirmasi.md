---
layout: post
title: ASP.NET MVC ve Web API - Async / Sync Karşılaştırması 
level: Orta
lang: tr
published: true
ref: asp-net-mvc-and-web-api-comparison-of-async-or-sync-actions
blog: yes
---

ASP.NET, .NET 4.5 versiyonu ile birlikte asenkron Action'ları desteklemektedir. Günümüzde asenkron işleme oldukça popüler hale gelmiştir ve her gün daha fazla uygulama asenkron olarak tasarlanmaya ve uygulanmaya başlanmıştır. Bu blog'da asenkron işlemlerin getirilerini ve uzun yıllar boyunca kullanmakta olduğumuz geleneksel senkron işlemler ile karşılaştırmasına yer vereceğiz. Blog'da sadece iddiaları ileri sürmektense, örnek programlar ile birlikte senkron ve asenkron işlemlerin davranışlarını gözlemleme fırsatı bulacağız. Bu yaklaşım, asenkron ve senkron işlemleri anlamanın yanı sıra, ASP.NET'in istekleri nasıl işlediği ve Thread yönetimi ile ilgili daha fazla bilgi sahibi olmamızı da sağlayacak. MVC ve Web API Action'larının işlenmesi arasında fazla bir fark bulunmamaktadır. Gösterim kolaylığı açısından bu blog'daki örneklerde Web API kullanacağız fakat yapılan saptamalar MVC için de geçerlidir.

### Çalışma Özeti

Bu blog'da ASP.NET'teki senkron (Sync) ve asenkron (Async) Action'ları farklı açılardan kullanım senaryoları ile birlikte karşılaştıracağız.

* Öncelikle Async Action'ları davranışlarını Sync Action'larla kıyaslayarak tanıtacağız.
* Sonra kullanım senaryolarını sıralayacağız ve kullanım senaryolarına göre Sync ve Async Action'ların hangisinin ilgili kullanım senaryosuna daha uygun olduğunu tartışacağız.
* Son olarak örnek programlar yazarak önceki bölümlerde yer verdiğimiz bilgileri ispatlayacağız ayrıca ASP.NET'in web isteklerini işlemesi ile ilgili bilgi sahibi olacağız. 

### Ön Koşullar

Bu blog'da verilen program örneklerini takip edebilmek ve kendiniz çalıştırabilmek için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker Compose ile oluşturulan sistemi çalıştırabilmek, bu konuda bilgi için [Docker Compose Blog'una](/docker-compose-nasil-kullanilir/) göz atabilirsiniz.
* Make aracının ne işe yaradığı ile ilgili fikir sahibi olmak için [Make Blog'una](/makefile-ve-make-nedir-ne-ise-yarar/) hızlıca göz atmanızda fayda olabilir.
* JMeter'ın kullanımı ile ilgili bilgiler için JMeter blog serisine [JMeter Bölüm 1](/jmeter-nedir-ve-ne-ise-yarar/), [JMeter Bölüm 2](/jmeter-fonksiyon-testi-hazirlama/), [JMeter Bölüm 3](/jmeter-pratik-test-hazirlama/), [JMeter Bölüm 4](/jmeter-performans-testi-hazirlama/) göz atabilirsiniz.

Docker Compose, Make ve JMeter'a aşina değilseniz ya da bunları kullanmak istemiyorsanız ya da adımları kendiniz takip etmeyi gereksiz buluyor ve verilen sonuçlara güveniyorsanız yine de bu blog yazısından fayda sağlayabilirsiniz :)

### Async ve Sync Action'lar

#### Giriş

Async Action'ları daha iyi anlamak için öncelikle ASP.NET'in Sync Action'ları nasıl işlediğini incelememiz gerekir. ASP.NET bir web isteği aldığında bu isteği işlemek üzere Thread havuzundan bir Thread alır ve ilgili istek bu Thread tarafından işlenir. Thread web isteğine bir cevap üretilip istemciye gönderilinceye kadar başka bir işlemde kullanılamaz. Bu mimari aynı anda işlenebilecek istek sayısını Thread havuzunda bulunan Thread sayısı ile sınırlı bırakmaktadır. ASP.NET'in her bir isteği ortalama olarak 200 milisaniyede (bir Thread için saniyede 5 istek) işlediğini ve Thread havuzunda çeşitli sebeplerden dolayı sadece 10 Worker Thread'e izin verdiğimizi varsayalım. Bu durumda Pipeline'da işleyebileceğimiz maksimum istek sayısı saniyede 50 adet olacaktır. Bu sayının uygulamamız için yeterli olmadığını düşünürsek Thread havuzundaki Thread sayısını artırabiliriz. Örnek olarak 100'e çıkardığımızı düşünelim, bu durumda Pipeline'da işleyebileceğimiz istek sayısı saniyede 500'e çıkmış olacaktır. Thread sayısını saniyede 1000'e çıkarırsak saniyede 5000 isteğe cevap verebilir hale geliriz. Bu rakam uygulamamızın ihtiyaç duyduğu kapasiteyi sağlamaya yeterli olabilir ancak tahmin ettiğiniz gibi durum bu kadar basit değil. Basit olsaydı bu blog'u yazmaya ve aşağıda verilecek örnek uygulamaları koşturmaya gerek olmazdı. Thread sayısını belirli bir düzeyin üzerinde artırmak sistem kaynaklarının aşırı tüketilmesine sebep olacaktır. Örneğin bir Thread havuzundaki her bir Thread için ayrılan Stack alanı tek başına 1MB'dır. 1000 Thread için bu rakam 1GB yapacaktır. Ayrıca artan Thread sayısı ile birlikte işletim sistemi bu Thread'leri adil bir şekilde koşturmak için [Context Switch](https://en.wikipedia.org/wiki/Context_switch)'ten dolayı sistem kaynaklarını üretken olmayan işlemler için harcayacaktır. 

#### I/O Bağımlı and CPU Bağımlı Uygulamalar

Async Action'lar ASP.NET Worker Thread'lerinin farklı isteklerin işlenmesinde kullanılabilmesini sağlarlar. Bir web isteğinin işlenmesi sırasında, ASP.NET Worker Thread bazı zamanlar bir veri tabanı veya başka bir web servis gibi bir dış kaynağa sorgu yapar ve isteğin tamamlanabilmesi için bu sorgunun cevabını beklemeye koyulur. Önceki bölümde belirtildiği gibi Sync Action'lar kullanıldığında ASP.NET Worker Thread bloklanır ve dış kaynaktan cevap gelinceye kadar başka işlemlerde kullanılamaz. Async Action'lar kullanıldığında ise Worker Thread çağrı yapılan dış kaynaktan cevap gelinceye kadar bloklanmak yerine diğer isteklerin işlenmesinde kullanılır dolayısıyla Thread'ler farklı istekler tarafından paylaşılmış olur. Dış kaynaktan beklenen cevap geldiğinde IOCP (IO Completion Ports) Thread havuzundaki Thread'ler cevabı işleyerek Worker Thread'lere haber verirler ve işleyiş devam eder ancak bu kısımda gerçekleşen olayları bu blog çerçevesinde ele almayacağız.

Görüldüğü üzere Async Action'ların getirdikleri inovasyon ASP.NET Worker Thread'lerine başka bir isteğin işlenmesi sırasında I/O beklerlerken üretken olmayı sağlamalarıdır. Bu iddianın doğru olduğunu kabul edersek, [I/O bağımlı](https://en.wikipedia.org/wiki/I/O_bound) (fazla miktarda I/O yapan) uygulamalarda Async Action'ları kullanmak uygulamanın ölçeklenebilirliğini (aynı sürede işleyebildiği istek sayısını) ve genel olarak performansını artıracağını (her bir isteğin sonuçlanma süresini kısaltacağını) rahatlıkla söyleyebiliriz. Bunu birazdan bir örnek programla ispatlamaya çalışacağız.

Async Action'ların sağladığı faydayı daha iyi anlamak için olayı rakamlarla ortaya koymaya çalışalım. Yukarıdaki örnekte her bir isteğin ortalama 200 milisaniye sürdüğünü varsaymıştık. Bu 200 milisaniyenin 50 milisaniyesinin isteğin işlenmesi sırasında kalan 150 milisaniyesinin de dış bir kaynağa yapılan istek ile (I/O yaparken) harcandığını varsayalım. Sync Action'larla bir Thread saniyede sadece 5 istek işleyebiliyordu. Async Action'larla bu rakam normalde I/O yaparken boşa geçirilecek 150 milisaniyenin de üretken olarak kullanılmasıyla ekstra 15 istekle beraber saniyede toplam 20 istek olacaktır. 10 Worker Thread'in bulunduğu varsayımı ile saniyede işlenebilecek toplam istek sayısı senkron durumdaki 50 rakamından 200'e çıkmış olacaktır. 

Uygulamamız I/O bağımlı değil de [CPU bağımlı](https://en.wikipedia.org/wiki/CPU-bound) olduğunda ve Async Action'lar kullanıldığında oluşacak duruma bakalım bir de. Bu durumda uygulamamızın 180 milisaniyesini isteği işlemekle ve kalan 20 milisaniyesini ise I/O yapmakla kullandığını düşünelim. Bu durumda her bir Thread saniyede 1000 / 180 = 5.55 isteği işleyebilecektir. 10 Worker Thread'in kullanıldığını varsayarsak işleyebileceğim toplam istek sayısı saniyede 55.5 olacaktır ve bu sadece %10'luk bir artışa karşılık gelecektir. Bu kadar küçük bir iyileşme için Action'ları Async yapıp yapmamayı iyi düşünmek gerekir.  

Yukarıdaki önermelerden I/O bağımlı uygulamaların ölçeklenebilirliği ve performansı Async Action'ların kullanılması ile birlikte çok olumlu bir biçimde etkilenecektir. CPU bağımlı uygulamalarda ise Async Action'ların kullanılmasının çok büyük fayda getirmesi beklenmemektedir. Bu çıkarımları sonraki bölümde demo uygulamalarla ispatlamaya çalışacağız.

#### Uygulamanın Basitliği

Asenkroni karmaşıklıkla birlikte gelmektedir. Bu blog'un direkt olarak konusu olmamakla birlikte, ASP.NET Async uygulamaları `async`, `await` konseptlerinin `Task` kütüphanesi ile birlikte iyi bir şekilde anlaşılmasını gerektirmektedir. Uygulamanın kendisini asenkron hale getirmek tek başına yeterli olmayacak, uygulama tarafından çağrılacak yardımcı kütüphanelerin de Async prensiplerini onurlandırması gerekecektir. Görüldüğü üzere gerçek bir asenkron uygulamanın geliştirilmesi senkron karşılığına göre daha fazla efor gerektirmektedir.

### Async ve Sync Action'ların Uygun Olduğu Kullanım Senaryoları 

Önceki bölümlerde verilen bilgiler ışığında bu bölümü daha rahat takip edebileceğiz.

**CPU Bağımlı Uygulamalar**

Optimizasyon hesabı yapan uygulamalar, belleğe çekilmiş bir dosyayı işleyenler uygulamalar gibi CPU'ya bağımlı çalışan uygulamalarda Async Action'ların kullanılmasının pek fazla avantaj getirmediğini yazmıştık. Bu tür uygulamaları Async olarak yazmak getireceği faydadan daha fazla efora ihtiyaç duyacaktır dolayısıyla bu tür uygulamaların **Sync Action**'lar kullanılarak yazılması daha mantıklı olacaktır. 

**I/O Bağımlı Uygulamalar**

Proxy Web servis'ler gibi bir web isteği üzerinde basit filtreleme ve validasyonlar yaparak isteği arkada bulunan başka web servislere ileten ve bu servisten gelecek cevabı bekleyen servis tipi uygulamalar Async Action'ların kullanımı ile işlem hacminde büyük bir iyileşme sağlayabileceklerdir. Load Balancer (yük dağıtıcı) gibi uygulamaların C ve C++ dışında bir dilde yazılması pek mümkün gibi görünmese de .NET ile yazıldığında **Async Action**'lar olarak uygulanması mantıklı olacaktır.

**İptal Edilebilir Uygulamalar**

Tasarladığımız uygulamanın işlem tam bitmeden iptal edilmeyi desteklemesi gerekebilir. Örneğin uygulamamız 10 farklı isteği aynı anda göndererek cevaplarını beklemeye başlayabilir ve ilk gelen cevabı alıp diğer cevaplarla ilgilenmek istemeyebilir ve sistem kaynaklarından tasarruf etmek için kalan 9 isteği iptal etmesi gerekebilir. Bu tür durumlarda **Async Action**'ların kullanılması gereklidir çünkü Sync Action'lar iptal edilemezler fakat Async Action'lar iptal edilebilir.

**Düşük Hacimli Uygulamalar**

Bazı uygulamaların aynı anda yüzlerce isteği karşılaması beklenmez çünkü uygulamaların eş zamanlı kullanıcı sayısı fazla değildir, arka büro (Back Office) uygulamaları bu tipe güzel bir örnek olabilir. Aynı anda işlenecek istek sayısı fazla olmadığında Async Action'larla uğraşmak yerine Sync Action'larla devam etmek mantıklı olabilir. Bu tür uygulamalarda hem **Sync Action**'lar hem de **Async Action**'lar kullanılabilir ancak **Async Action**'ların getirdiği faydalar ile gerektirdiği efor üzerinde iyi düşünülmelidir.

### Örnek Program

Yukarıda anlattığımız davranışları gözlemlemek üzere kullanacağımız uygulama OWIN altyapısı ile hazırlanmış ve Mono üzerinde koşturulan bir ASP.NET Web API uygulamasıdır. Web API `Customers` adında tek bir Controller'a sahiptir ve bu Controller hem Sync hem de Async Action'lara sahiptir.  

Blog'u takip ederken sizin de minimum eforla testleri yapabilmeniz için uygulama Docker ile çalıştırılabilecek hale getirilmiştir. İsterseniz uygulamanın kaynak kodlarında değişlik yaparak yaptığınız değişikliğin etkilerini gözlemleyebilirsiniz. Kaynak kodu aşağıdaki Github reposunda bulabilirsiniz.

[Uygulama Repo'su](https://github.com/gokhansengun/sync-async-comparison-demo). 

#### Test Ortamının Ayarlanması

Uygulamayı çalıştırabilmek için, Repository'i bilgisayarınızda bir klasöre klonlayarak bir terminal penceresi açın ve `Docker` klasörüne gidin. `make app` komutunu çalıştırarak uygulamayı derleyin ve çalıştırın. Doğru sonuçlar elde edebilmek için her bir testte uygulamayı tekrar başlatmamız gerekecektir, bunun için `make restart-app` komutunu kullanacağız. Ek olarak terminal penceresinde anlık olarak kullanımda olan Thread sayılarını ve Thread havuzunda bulunan Worker Thread ve IOCP Thread sayılarını görebileceğimiz loglar olacaktır. Uygulamanın farklı durumlardaki davranışlarını yorumlamak üzere bu logları kullacağız.

Uygulamayı test edebilmek için JMeter kullanacağız, adımları takip edebilmek için eğer daha önce yapmadıysanız [JMeter 3.0](https://jmeter.apache.org/download_jmeter.cgi)'ı indirmeniz gerekmektedir.

Testin canlı olarak akışını takip edebilmek için JMeter'da Thread Group'u genişleterek aşağıda görüldüğü gibi `Summary Report` Listener'ını seçin.

{% include image.html url="/resource/img/SyncAsync/SummaryReportElement.png" description="Summary Report Element" %}

#### I/O Bağımlı Uygulamalarda Sync / Async Karşılaştırması

`Customers` Controller'ı `SyncGet200MsDelay` ve `AsyncGet200MsDelay` adında iki adet Action içermektedir. Bu Action'lar adlarından da anlaşılacağı üzere sırasıyla Sync ve Async olarak 200 milisaniye bekleyerek bir müşteri listesi dönmektedirler. Buradaki 200 milisaniye bekleme süresi bir veri tabanı veya dış web servis çağrısını simüle etmek için kullanılmıştır.

##### Sync Action Testi

```csharp
[HttpGet]
public IHttpActionResult SyncGet200MsDelay()
{
    // simulate a delay - could be a database query or another service request
    Task.Delay(200).Wait();
    
    return Ok(GetSampleCustomers());
}
```

Öncelikle I/O bağımlı durumda Sync Action'ı yani `SyncGet200MsDelay`'ı test edelim. JMeter Thread Group eş zamanlı 50 web isteği yapacak ve her bir kullanıcı bunu 5 kere tekrar edecektir. Web isteklerinin dönüş süreleri için kabul edilebilir aralık tabii ki 200-210 milisaniye olmalıdır. Action'lar isteği 200 milisaniye beklettiği için zaten geri dönüş değerimiz teorik olarak 200 milisaniyenin altında olamaz.

`make restart-app` komutunu çalıştırın sonra `JMeter` programını açarak buradan `JMeter/Sync-50-Threads-IO-Bound-Work.jmx` dosyasını seçin. 

Testi başlatarak sonuçları gözlemleyin. Aşağıda benim yaptığım testin sonucunu görebilirsiniz.

{% include image.html url="/resource/img/SyncAsync/IOBoundAppSyncResult.png" description="IO Bound Action's Behaviour in Sync Pipeline" %}

Gördüğünüz gibi ortalama olarak Sync Action'lar 200-210 milisaniye yerine 2467 milisaniye sürdü. Burada ciddi bir performans problemi yaratmış olduk. Eğer uygulamayı başlattığımız terminal penceresinden uygulama log'larına bakarsak uygulama ilk başladığında sadece 5 adet bulunan Thread'lerin gelen eş zamanlı 50 isteğe cevap vermek için 15 saniye içerisinde 57 adete çıktığını görebiliriz. Sync Action'ların Sleep işlemleri sırasında bloklandığı ve başka isteklerin işlenmesi için kullanılamadığı gerçeğini aklımıza getirdiğimizde Sleep'ler sırasında Thread'lerin hiçbir şey yapmayıp beklemelerinden dolayı yeni Thread'lerin yaratılması gerekmiştir. ASP.NET yeni Thread'leri bir anda oluşturmayıp peyder pey oluşturduğu için web istekleri kuyrukta beklediler ve ortalama olarak 2467 milisaniye içinde ancak cevaplanabildiler dolayısıyla da elde ettiğimiz performans çok kötü oldu. 

```
app_1    | At 10/29/2016 22:30:33 - # of threads in use is 5, avail worker: 400, ports: 400
app_1    | At 10/29/2016 22:30:34 - # of threads in use is 5, avail worker: 400, ports: 400
app_1    | At 10/29/2016 22:30:35 - # of threads in use is 5, avail worker: 400, ports: 400
app_1    | At 10/29/2016 22:30:36 - # of threads in use is 12, avail worker: 395, ports: 400
app_1    | At 10/29/2016 22:30:37 - # of threads in use is 17, avail worker: 390, ports: 400
app_1    | At 10/29/2016 22:30:38 - # of threads in use is 17, avail worker: 390, ports: 400
app_1    | At 10/29/2016 22:30:39 - # of threads in use is 17, avail worker: 390, ports: 400
app_1    | At 10/29/2016 22:30:40 - # of threads in use is 17, avail worker: 390, ports: 400
app_1    | At 10/29/2016 22:30:41 - # of threads in use is 17, avail worker: 390, ports: 400
app_1    | At 10/29/2016 22:30:42 - # of threads in use is 18, avail worker: 389, ports: 400
app_1    | At 10/29/2016 22:30:43 - # of threads in use is 20, avail worker: 387, ports: 400
app_1    | At 10/29/2016 22:30:44 - # of threads in use is 25, avail worker: 382, ports: 400
app_1    | At 10/29/2016 22:30:45 - # of threads in use is 27, avail worker: 380, ports: 400
app_1    | At 10/29/2016 22:30:46 - # of threads in use is 27, avail worker: 380, ports: 400
app_1    | At 10/29/2016 22:30:47 - # of threads in use is 37, avail worker: 370, ports: 400
app_1    | At 10/29/2016 22:30:48 - # of threads in use is 47, avail worker: 360, ports: 400
app_1    | At 10/29/2016 22:30:49 - # of threads in use is 57, avail worker: 350, ports: 400
app_1    | At 10/29/2016 22:30:50 - # of threads in use is 57, avail worker: 350, ports: 400
app_1    | At 10/29/2016 22:30:51 - # of threads in use is 57, avail worker: 350, ports: 400
```

##### Async Action Testi

```csharp
[HttpGet]
public async Task<IHttpActionResult> AsyncGet200MsDelay()
{
    // simulate a delay - could be a database query or another service request
    await Task.Delay(200);
    
    return await Task.FromResult(Ok(GetSampleCustomers()));
}
```

Şimdi de I/O bağımlı durumda Async Action'ı yani `AsyncGet200MsDelay`'ı test edelim. JMeter Thread Group yine eş zamanlı olarak 50 isteği gönderecek ve her bir kullanıcı bunu 5 kere tekrarlayacaktır. Bu testimizde de isteklerin cevaplanma süresi için beklentimiz 200-210 milisaniyedir. Bakalım Async Action'lar bu beklentimizi karşılayabilecek mi?

`make restart-app` komutunu çalıştırın sonra `JMeter` programından `JMeter/Async-50-Threads-IO-Bound-Work.jmx` dosyasını seçin.

Testi başlatarak sonuçları gözlemleyin. Aşağıda benim yaptığım testin sonucunu görebilirsiniz.

{% include image.html url="/resource/img/SyncAsync/IOBoundAppAsyncResult.png" description="IO Bound Action's Behaviour in Async Pipeline" %}

Gördüğünüz gibi Async Action ile istekleri ortalam 232 milisaniyede cevaplayabildik ki bu da kabul edilebilir bir sonuç. Bu sonucu alabilmemizde Sleep çağrısında bloklanan Thread'lerin başka isteklerin işlenmesinde kullanılabilmesi etkili oldu ve uygulamamız gayet güzel bir şekilde ölçeklenebildi. Terminal loglarına göz attığımızda uygulamanın sadece 6 Thread ile başladığını ve maksimum 13 Thread'e ulaşarak bütün isteklere kabul edilebilir bir zaman aralığında cevap verebildiğini görebiliyoruz.

```
app_1    | At 10/29/2016 22:42:51 - # of threads in use is 6, avail worker: 400, ports: 400
app_1    | At 10/29/2016 22:42:52 - # of threads in use is 6, avail worker: 400, ports: 400
app_1    | At 10/29/2016 22:42:53 - # of threads in use is 6, avail worker: 400, ports: 400
app_1    | At 10/29/2016 22:42:54 - # of threads in use is 10, avail worker: 397, ports: 400
app_1    | At 10/29/2016 22:42:55 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:42:56 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:42:57 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:42:58 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:42:59 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:43:00 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:43:01 - # of threads in use is 13, avail worker: 394, ports: 400
app_1    | At 10/29/2016 22:43:02 - # of threads in use is 13, avail worker: 394, ports: 400
```

#### CPU Bağımlı Uygulamalarda Sync / Async Karşılaştırması

`Customers` Controller'ında bulunan diğer Action'lar `SyncGetCpuBound` ve `AsyncGetCpuBound`'dir. Bu Action'lar belirli bir süre boyunca bir sayı hesaplamaya çalışıp sonra da bu sayıyı döndürmektedir. Aynı hesaplamayı verilen Action'lar sırayla Sync ve Async olarak yapacaklardır.

##### Sync Action Testi

```csharp
[HttpGet]
public IHttpActionResult SyncGetCpuBound()
{
    var result = HeavyWork();

    return Ok(result);
}
```

CPU bağımlı durumda Sync Action'ı yani `SyncGetCpuBound`'ı test edelim. JMeter Thread Group yine 50 eş zamanlı isteği 5 tur boyunca çalıştıracaktır.

`make restart-app` komutunu çalıştırın sonra `JMeter` programından `JMeter/Sync-50-Threads-CPU-Bound-Work.jmx` dosyasını seçin.

Testi başlatarak sonuçları gözlemleyin. Aşağıda benim yaptığım testin sonucunu görebilirsiniz.

{% include image.html url="/resource/img/SyncAsync/CPUBoundAppSyncResult.png" description="CPU Bound Action's Behaviour in Sync Pipeline" %}

Gördüğünüz gibi ortalamada Sync Action'lar 86 milisaniyede sonuçlandı. Sadece bu değere bakarak elde ettiğimiz sonucun iyi bir sonuç olup olmadığını söylemek güç çünkü Action'da yapılan hesaplamanın ne kadar sürdüğü ile ilgili bir bilgimiz yok. Şimdi Async Action'ı test edelim ve yorumlamayı sonraya bırakalım.

##### Async Action Testi

```csharp
[HttpGet]
public async Task<IHttpActionResult> AsyncGetCpuBound()
{
    var result = HeavyWork();

    return await Task.FromResult(Ok(result));
}
```

CPU bağımlı durumda Async Action'ı yani `AsyncGetCpuBound`'ı test edelim. JMeter Thread Group yine 50 eş zamanlı isteği 5 tur boyunca çalıştıracaktır.

`make restart-app` komutunu çalıştırın sonra `JMeter` programından `JMeter/Async-50-Threads-CPU-Bound-Work.jmx` dosyasını seçin.

Testi başlatarak sonuçları gözlemleyin. Aşağıda benim yaptığım testin sonucunu görebilirsiniz.

{% include image.html url="/resource/img/SyncAsync/CPUBoundAppAsyncResult.png" description="CPU Bound Action's Behaviour in Async Pipeline" %}

Gördüğünüz gibi ortalamada Async Action 93 milisaniyede istekleri cevaplayabildi. Bu kez Async Action'da aldığımız sonuç Sync Action'a göre daha kötü oldu. Fazla bir iyileşme olmasını beklemiyorduk ancak kötüye gitmeyi açıkçası hiç beklemiyorduk. İsterseniz buradaki sonucu yorum bölümünde tartışalım.

Önceki bölümlerde CPU bağımlı uygulamalar için yaptığımız çıkarımı da kanıtlamış olduk. CPU bağımlı uygulamada Async Pipeline'ı kullanmak uygulamanın ölçeklenebilirliğinin ve performasının artırılmasına katkıda bulunmamış oldu.

### Sonuç

Sanırım bu yazılanlar ile Async Action'ların uygulamaların ölçeklenebilirliği ve performansını mucizevi bir şekilde artırmadığını gözlemledik. Async Action'lar I/O bağımlı uygulamalarda kullanıldığında uygulamanın kaynakları daha iyi kullanması ile ölçeklenebilirliğini artırır. Bununla birlikte Async Action'lar sıfır maliyetle gelmez, Async kod yazmak daha fazla dikkat, uzmanlık ister. 

Umarım siz de benim yazarken keyif aldığım kadar takip ederken keyif aldınız. Yorumlarınızı ve varsa düzeltmelerinizi yorum bölümünden bekliyorum.

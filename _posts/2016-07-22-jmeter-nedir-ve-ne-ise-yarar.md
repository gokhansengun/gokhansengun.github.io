---
layout: post
title: "JMeter Bölüm 1: Nedir ve Ne İşe Yarar?"
level: Başlangıç
lang: tr
ref: jmeter-part-1
---

Bu blog yazısında Apache Software Foundation (Apache Yazılım Vakfı) tarafından geliştirilmekte olan JMeter uygulaması ile ilgili genel bilgiler vermeye çalışacağız. Bu blog'da kısaca tanıtılacak olan JMeter'i, sonraki iki blog'da detaylı olarak işlemeye devam edeceğiz. JMeter uygulamasının kullanım alanları ile birlikte sağladığı farklı bileşenleri ekran görüntüleri ile birlikte paylaşarak siz okuyucuların kafasında net bir JMeter imajı oluşturmaya çabalayacağız.

Bu blog yazısını okuduktan sonra aşağıdaki blog yazılarını da sırasıyla okumanız tavsiye edilir. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyoruz.

[JMeter Bölüm 2: Fonksiyon Testi Nasıl Hazırlanır?](/jmeter-fonksiyon-testi-hazirlama/)

[JMeter Bölüm 3: Pratik Test Senaryosu Kaydı Nasıl Yapılır?](/jmeter-pratik-test-hazirlama/)

[JMeter Bölüm 4: Performans Testi Nasıl Hazırlanır??](/jmeter-performans-testi-hazirlama/)

[JMeter Bölüm 5: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

Şimdi isterseniz ufaktan başlayalım.

## JMeter Nedir?

JMeter, başlangıçta web uygulamalarının test edilebilmesi için tasarlanmış fakat sonrasında farklı test fonksiyonlarını da gerçekleştirecek şekilde geliştirilmiş bir Apache projesidir.

JMeter web uygulamalarında html, resim, css ve js gibi statik dosyaları isteyerek test edebilmenin yanı sıra SOAP (Simple Object Access Protocol) ve REST (REpresentational State Transfer) bazlı içeriği dinamik olarak üretilen web servisleri test etme amaçlı olarak da kullanılabilir. Gerçek kullanıcıların bir web uygulamasını kullanırken sunuculara yaptıkları kaynak talepleri (web istekleri), JMeter yardımı ile sanki gerçek kullanıcılar bu kaynakları talep ediyormuşcasına simüle edilir. JMeter ile simüle edilen kullanıcı senaryoları (kullanıcıların web uygulamasını kullanma şekilleri), web uygulamasının isteği girdiler (input) farklılaştırılarak sanki birden fazla kullanıcı aynı anda aynı senaryoyu çalıştırıyormuş gibi kurgulanır ve sistemde istenen büyüklükte bir yük oluşturulabilir. Bir kullanıcı senaryosu oluşturma ve bir kullanıcı için oluşturulan senaryonun farklı kullanıcılar tarafından da koşturulacak şekilde hazırlanması, yani JMeter'ın temel fonksiyonu diyebileceğimiz bu özellik, bir sonraki blog'da bir demo ile birlikte gösterilecektir.

JMeter %100 Java ile yazılan bir araç olduğu için Java Runtime Environment (JRE) veya Java Development Environment (JDK) kurulu olmak kaydı ile Windows, Linux veya Mac işletim sistemine sahip herhangi bir bilgisayarda problemsiz çalıştırılabilmektedir. Bu blog yazısında Mac OS X işletim sistemi kurulu bir bilgisayar kullanılacak ve ekran görüntüleri Mac OS X işletim sisteminde alınacaktır fakat siz herhangi bir işletim sisteminde adımları takip edebilirsiniz. GUI'nin Java olması ve görünümün platformdan platforma pek fazla farklılık göstermemesinin adımları takip ederken işinizi kolaylaştıracağını düşünüyoruz.

JMeter kurulumu çok iyi bir şekilde dokümante edildiği ve blog'umuzu uzatacağı için kurulum adımlarına burada yer vermek istemiyoruz. JMeter kurulumu için platformunuza göre [bu linkten](http://jmeter.apache.org/usermanual/get-started.html#install) yardım alabilirsiniz. Bu blog'da JMeter'ın 2.13 versiyonu kullanılacaktır fakat 2.13 ve üzeri herhangi bir versiyonda blog'da yer verilen adımlar sorunsuz takip edilebilmelidir.

## Çalışma Özeti

Aşağıdaki adımları tamamlayarak JMeter hakkında genel anlamda fikir sahibi olarak hangi amaçlarla kullanıldığını anlamaya çalışacağız.

* Farklı test çeşitlerini (Fonksiyonel, Yük, Performans, Stres) tanıyacağız.
* JMeter terminolojisi ve performans testi terminolojisi ile ilgili bilgiler vererek JMeter dilinde ve test konseptinde konuşmayı öğreneceğiz.
* JMeter ile sonraki blog'da bir demo yapabilmemize olanak tanıyacak en önemli JMeter bileşenlerini inceleyeceğiz.
* JMeter GUI'sini (Graphical User Interface - Grafik Kullanıcı Arayüzü) tanıyacağız.

## Test ve JMeter Terminolojisi

Bu blog ve sonraki iki blog'da aynı dili konuşabilmek için test ve JMeter terminolojisine hakim olmamız gereklidir. Bu bölümde teorik olarak açıklanacak bazı kavramlar konunun daha iyi anlaşılmasına yardımcı olacakken bir yandan da JMeter bileşenlerinin kullanım alanlarının öğrenilmesini sağlayacaktır. Ayrıca bu bölümde yer verilen JMeter bileşenlerini ilerleyen bölümlerdeki demo'larda kullanacak ve fonksiyonlarını daha iyi anlayacağız.

### Test Çeşitleri

#### Fonksiyonel Test

Sunulan servisin fonksiyon olarak doğruluğunu test eder. Öğrenciler için sınav sonuçlarının sunulduğu bir web uygulamasında yapılması gereken fonksiyonel testlerden bazıları her bir öğrencinin kendi sınav sonucunu sorgulayabilmesi, başkasına ait sınav sonucunu sorgulayamaması, her bir öğrencinin sorgusunun sadece kendi sonucunu getirmesi (başka bir sonuç getirmemesi) ve sınava girmeyen bir öğrenci için sonuç dönülmemesi ile birlikte öğrencinin sınava girmediği bilgisinin dönülmesi olarak sıralanabilir.

#### Yük Testi

Çoğu zaman performans testi ile aynı anlamda kullanılmakla birlikte daha geniş bir anlama sahiptir. Sunulan uygulamanın belirli bir yük altında nasıl davrandığını (cevaplarda gecikme süresi, kullanıcı deneyimi, vb) gözlemleyen test türüdür.

#### Performans Testi

Sunulan uygulamanın planlanan performans kriterleri çerçevesinde çalışıp çalışmadığını test eder. Her bir uygulama kendisine belirli bir performans hedefi koymalıdır. Örneğin, bir web sitesi kaynak planlamasını (sunucu sayısı, sunucu özellikleri, network bant genişliği, vb) aynı anda ve/veya belirli bir süre boyunca (örneğin bir dakika) beklediği maksimum kullanıcı sayısına göre yapar. Performans testi, ilgili web sitesinin belirlenen performans kriterlerini (anlık 2K kullanıcı, bir dakikada 1M request, vb) gerçekçi bir şekilde simüle eder ve beklenen en fazla kullanıcı geldiğinde sistemin kararlı bir şekilde çalışabileceği güvence altına alınmış olur.

#### Stres Testi

Performans testinin, sunulan uygulamanın planlanan maksimum kapasitede nasıl davrandığını test ettiğini belirtmiştik. Stres testi ise planlanan maksimum kapasitenin üzerinde bir yük altında sistemin nasıl davrandığını ve en önemlisi hangi noktada kırıldığını gözlemlemek üzere yapılan testtir. Beklenen davranış uygulamanın planlanan kapasite üzerinde (Storm - fırtına) fonksiyonlarını kısmen gerçekleştirememesi veya tamamen gerçekleştirememesi fakat test bittikten (fırtına dindikten) sonra uygulamanın kararlı ve doğru sonuçlar üretebilecek durumda olmasıdır.

### Test Kavramları

#### Ramp-up Time (Tırmanma Süresi)

Yapacağımız testte sunduğumuz uygulamanın 1000 kullanıcı için test edilmek istendiğini düşünelim. Sistemde ilk anda 1000 kullanıcının 1000'inin birden içeriye alınması çok gerçekçi değildir. Ramp-up Time, 1000 kullanıcının test aracı tarafından kaç saniye içerisinde sisteme dahil edileceğini belirler. 1000 kullanıcı için Ramp-up Time 20 saniye olarak verildiğinde ilk saniye sonunda sistemde 50, ikinci saniye sonunda 100 kullanıcı girmiş olacak ve 20 saniye sonunda bütün kullanıcılar sisteme giriş yapmış olacaklardır.

JMeter'da bütün kullanıcıların aynı anda sisteme girmesi isteniyorsa Ramp-up Time 0 saniye olarak verilebilir. Ramp-up Time 0 saniye belirlense bile JMeter'ın bu kullanıcıları yaratarak sisteme dahil etmesi belirli bir zaman alacaktır, yani siz 0 saniye verseniz bile 1000 kullanıcının sisteme dahil edilmesi JMeter testi için kullandığınız bilgisayarın kaynaklarının durumuna, yaptığınız testin ağırlığına (açtığı socket'ler, karmaşıklığı) göre 10-15 saniye arasında sürebilir.

Aşağıdaki ekran çıktısında görülebileceği üzere JMeter'da Ramp-up Time Thread Group bileşeni üzerinden ayarlanmaktadır.

{% include centeredImage.html url="/resource/img/JMeterPart1/JMeterRampUpTime.png" description="Ramp-up Time" %} 

#### Think Time (Düşünme Süresi)

Sahip olduğumuz bilgisayarlar biz insanların aksine çok hızlı bir şekilde işlem yapabilmektedirler. Testlerde, istisnai durumlar (Stres Testi, vb), dışında gerçek kullanıcı davranışı simüle edilmeye çalışılır. Gerçek kullanıcıların iki test adımı arasında mouse veya klavye ile giriş yapmaları bir miktar süre gerektirir. Test senaryosunda bu kullanıcı davranışını simüle etmek için iki adım arasına bir Timer konulur ve sanal kullanıcının (test kullanıcısı) iki adım arasında bir miktar beklemesi sağlanır. İki test adımı arasında kullanıcı için tanımlanan bekleme süresi Think Time olarak adlandırılır. Örneğin, bir HTML formununun bulunduğu sayfayı yükleyen gerçek kullanıcı, formu submit etmeden önce doldurmak için belirli bir süreye ihtiyaç duyacaktır. Yük ve performans testlerinde sanal kullanıcılar için adımlar arasında belirlenen Think Time ile bu süre simüle edilebilir.

#### Loop Count (Döngü Sayısı)

Sisteminize 10 dakika içerisinde 100K kullanıcının gireceğine ve bir dakika boyunca işlem yapacağına göre plan yaptığınızı varsayalım. Hazırladığınız test senaryosunu 100K kullanıcıyı Ramp-up Time 10 dakika olarak sisteme sokacak şekilde hazırlamak yerine 1 dakikada 10K kullanıcıyı sisteme sokup işi biten kullanıcının sisteme tekrar tekrar (toplam 10 kere) girerek bütün adımları tekrarlamasını sağlayabilirsiniz. Loop Count buradaki her bir test kullanıcısının sisteme toplam giriş sayısıdır.

Yukarıdaki senaryo dışında sisteminizin dayanıklılığını ve sürekliliğini test etmek üzere belirli bir süre için sistemin kullanıcılar tarafından normal kullanımından çok çok daha yoğun kullanılması senaryosunu kurgulamak için de Loop Count kullanabilirsiniz. Örneğin, sistemimizi günde 10K kullanıcının 1 dakika için kullandığını düşünelim. Sistemimizin 1000 gün boyunca yeniden başlatılmadan sağlıklı çalışıp çalışmayacağını test etmek isteyelim. Sistemimize 1K kullanıcıyı belirli aralıklarla sokarak işi biten kullanıcının tekrar tekrar (toplam 10K x 1000 / 1K = 10000 kere) girmesini sağlayarak 10000 dakikada (yaklaşık 7 günde) uygulamamızın 1000 gün (yaklaşık 3 sene) boyunca tekrar başlatılmaya ihtiyaç duymadan sağlıklı çalışıp çalışmayacağını test edebiliriz.

#### Sample Time (Örnekleme Süresi) ve Latency (Gecikme)

Birbiri ile sık sık karıştırılan bu iki kavram bir arada verilerek belki daha kolay anlatılabilir. Bir HTTP isteğinin yaşam döngüsünü ele alalım. Yaşam döngüsü aşağıdaki adımlardan oluşur. 

1. İstemci ile sunucu arasında öncelikle bir TCP bağlantısının sağlanması (halihazırda bir bağlantı varsa onun kullanılması -http pipelining-) 
2. İstemci tarafından HTTP isteğinin bütünü ile TCP bağlantısı üzerinden sunucu tarafına yollanması
3. İsteğin sunucu tarafından TCP seviyesinde bütünü ile alınması 
4. TCP seviyesinde alınan isteğin sunucu tarafındaki web veya uygulama sunucusuna aktarılması
5. İsteğin web veya uygulama sunucusu tarafından işlenmesi (veri tabanı sorguları, vb yapılması)
6. Cevabın sunucu tarafından istemciye açık olan TCP bağlantısı üzerinden bütünü ile iletilmesi
7. Cevabın istemci tarafından bütünü ile TCP bağlantısı üzerinden alınması

Sample Time (Örnekleme Süresi) son kullanıcının hissettiği ve gözlemlediği performanstır ve yukarıdaki adımların tamamının toplamından oluşur. Latency (Gecikme) ise sunucu tarafında geçen işleme süresidir. Yukarıdaki listeye göre 3, 4, 5 ve 6 adımlarında geçen toplam süre Latency'yi oluşturur.

### JMeter Bileşenleri

Bu bölümde bütün JMeter bileşenlerini ayrıntılı olarak ele almak yerine hızlıca başlamamıza olanak tanıyacak olan en önemli ve kullanışlı JMeter bileşenlerine yer vereceğiz. Bu blog sonrasında gelecek 2 blog'da birçok başka bileşene de göz atma fırsatı bulacağız. 

#### Sampler (Örnekleyici)

Test yapılacak sistemle etkileşim kurmak için ihtiyaç duyulan JMeter bileşenleridir. Birçok farklı Sampler arasında en çok kullanılan HTTP Request Sampler'dır. Adından da anlaşılacağı üzere HTTP Request Sampler, sunucuya HTTP istekleri göndermeye yarar.

`http://www.milliyet.com.tr/Siyaset` sayfasına istek yapmak üzere hazırlanan HTTP Request Sampler'ın görüntüsü aşağıda verilmiştir. 1 ile işaretlenen bölümde HTTP Request Sampler'ına "Siyaset Sayfası" adı verilerek raporlarda ayrıştırılabilmesi hedeflenmiştir. 2 ile işaretlenen bölümde sunucunun DNS sunucular tarafından çözülebilecek ismi yani FQDN'i (Fully Qualified Domain Name) verilmiştir. Bu kısımda IP de verilebilirdi. 3 ile işaretlenen bölümde ise web sunucudan istenecek bölüm (path) verilmiştir.

{% include image.html url="/resource/img/JMeterPart1/JMeterHttpRequestSampler.png" description="JMeter HTTP Request Sampler" %} 

JMeter versiyon 2.13 tarafından desteklenen güncel Sampler listesi aşağıda verilmiştir. Bu blog serisinde ele alacağımız ve en çok kullanılan Sampler'lar ise altları çizilerek işaretlenmiştir.

{% include image.html url="/resource/img/JMeterPart1/JMeterSamplerList.png" description="JMeter Sampler List" %}

JMeter genel olarak genişletilebilir bir araç olduğu için kendi Sampler'ımızı yazmamız da mümkün. Örneğin MQTT sunucusuna isteklerde bulunmak üzere kendimiz MQTT Request Sampler'ını Java kullanarak yazabiliriz veya daha önce başkaları tarafından yazılmışsa import ederek kullanabiliriz.

#### Listener (Dinleyici)

Sampler'lar tarafından yapılan istekler ve bu isteklere sunucu tarafından verilen cevapların özelliklerinin teker teker, toplu veya kümüle bir şekilde kaydedilmesi işlevini Listener'lar yerine getirmektedir. Bazı Listener'lar yapılan istek ve cevabı tutarken, bazıları yapılan isteğe sunucu tarafından dönen cevabın süresini tutmaktadır. Çok fazla Listener eklenmesi JMeter istemci tarafında loglamayı artıracağı için performansı olumsuz etkileyecek ve bir JMeter Node'unda simüle edilebilecek maksimum kullanıcı sayısını düşürecektir. Bu sebeple sadece gerçekten ihtiyaç duyulan Listener'lar test sırasında açık tutulmalıdır.

Sampler'ı anlatırken örnek olarak kullandığımız Test Plan'ına View Result Tree ve View Results in Table Listener'larını ekleyip 10 eş zamanlı kullanıcı ile yapılan test sonucu oluşan çıktı aşağıda verilmiştir. JMeter'la uçtan uca test oluşturulmasını ilerleyen bölümlerde ele alacağız. Şimdilik örnek olması açısından bu ekranlar verilmiştir.

Aşağıdaki ekran çıktısında 1 ile işaretlenen bölümde eş zamanlı olarak 10 sanal kullanıcı için başlatılan 10 istek görülmektedir. 2 ile işaretlenen bölümde dinlenen HTTP Sampler ile ilgili detay bilgiler verilmektedir. Buradaki bilgilere bakılarak sunucuya bağlantı zamanının "Connect Time" 133 ms, sayfanın yüklenme zamanının "Load Time" 285 ms, HTTP cevabının boyutunun "Size in bytes" 47803 byte olduğunu görebiliyoruz. 3 ile işaretlenen bölümde ise yine dinlenen HTTP Sampler'ın "Sampler result"a ek olarak yapılan Request (istek) ve alınan Response (cevap) ile ilgili bilgi alabileceğimizi görüyoruz.

{% include image.html url="/resource/img/JMeterPart1/JMeterViewResultsTreeListener.png" description="JMeter View Results Tree Listener" %}

HTTP Sampler'lar tarafından yapılan istekler ve alınan cevaplar ile ilgili özet bilgiler aşağıdaki çıktıda verilen View Results in Table Listener'ı tarafından sağlanmıştır. 1 ile işaretlenen bölümde her bir HTTP isteğinin sonuçlanma süresini görebiliyoruz. `www.milliyet.com.tr`'nin en düşük 104 ms'de en yüksek ise 593 ms'de `/siyaset/` sayfası için sonuçları döndüğünü görebiliyoruz. 2 ile işaretlenen bölümde yapılan bütün isteklere sunucunun pozitif cevap verdiğini görüyoruz. 3 ile işaretlenen bölümde ise sunucudan gönderilen cevabın boyutunun neredeyse her seferinde değiştiğini görüyoruz. Aynı sayfa için sunucudan gelen toplam byte sayısının neden değiştiğini biliyorsanız aşağıdaki yorum bölümüne yazabilirsiniz. Karmaşık bir cevabı yok bu sorunun :) 4 ile işaretlenen bölümde ise her bir HTTP isteğinin sunucuda geçirdiği süreyi Latency olarak görüyoruz. Sample Time ve Latency arasındaki fark (Sample Time (Örnekleme Süresi) ve Latency (Gecikme)) başlıklı bölümde anlatılmıştı.

{% include image.html url="/resource/img/JMeterPart1/JMeterViewResultsInTableListener.png" description="JMeter View Results in Table Listener" %}

#### Thread Group

JMeter'da bir Test Plan'ında oluşturulan senaryonun farklı kullanıcılar tarafından paralel bir şekilde koşturulabileceğinden bahsetmiştik. Eş zamanlı kullanıcıların koşturacakları senaryolar (ilgili sampler'lar ile birlikte) Thread Group'lar altında tanımlanır. Thread Group'un özelliklerinden "Number of Threads (users)" simüle edilmek istenen kullanıcı sayısına göre ayarlanarak test hazırlanmış olur.

Thread Group bileşeninin görünümü aşağıda verilmiştir. 1 ile gösterilen bölümde Thread Group'un içinde bulunan Thread'lerin (user'ların) bir Sampler hatası ile karşılaşıldığında ne yapmaları gerektiği ayarlanır. Default değer Continue'dur. Örneğin HTTP Request Sampler sunucuya bir istek göndermiş ve 60 saniye boyunca sunucudan cevap alamamışsa işlemi başarısız olarak değerlendirir. Continue seçildiğinde ilgili Thread bir sonraki adıma geçer. Burada bir sonraki Loop'a başlamak seçilebileceği gibi, ilgili Thread (user) veya test bütünü ile durdurulabilir. JMeter ile yük, performans testi yapıldığında bu ayar duruma göre Continue olarak işaretlenebilir. Fonksiyon testi yapıldığında ise ayarın Stop Test olarak işaretlenmesi uygun olacaktır. 2 ile gösterilen bölümde yukarıda açıklandığı gibi Thread Group tarafından koşturulacak eş zamanlı kullanıcı sayısı girilmelidir. 3 ile gösterilen bölümde bir Number of Threads bölümünde seçilen sayıdaki kullanıcının sisteme toplam kaç saniyede gireceği belirlenir. Örneğimiz için 10 kullanıcı 1 saniye içinde yani 100 ms'de bir kullanıcı sisteme girecek şekilde bir ayar yapılmıştır. 4 ile gösterilen bölümde her bir Thread'in (User'ın) Thread Group'un altında bulunan test adımlarını toplam kaç kere koşturacağı ayarı yapılır.

{% include image.html url="/resource/img/JMeterPart1/JMeterThreadGroup.png" description="JMeter Thread Group" %}

#### CSV Data Set Config

JMeter'da bir Thread Group için hazırlanmış senaryoda kullanıcıya özgü bir takım değerler bulunabilir veya her bir kullanıcının sistemin farklı bölümlerini test etmesi istenebilir. Örneğin, test edilen senaryo eğer sisteme giriş yapılmasını gerektiriyorsa bir girdi dosyası ile JMeter'a her bir kullanıcıya ait kullanıcı adı ve parola bilgileri verilmelidir. JMeter girdi dosyalarını CSV (Comma Separated Values) formatında kabul etmektedir. Her ne kadar CSV adından virgül ile ayrılmış dosya formatını çağrıştırsa da istenildiği taktirde (input dosyasındaki alanlardan birinde virgül olması durumunda) virgül yerine noktalı virgül (;) veya soru işareti (?) de kullanılabilir.

Örnek bir CSV girdi dosyası ve JMeter CSV Data Set Config bileşeni aşağıda verilmiştir. Dikkat edilmesi gereken en önemli husus JMeter Test Plan'ın kaydedildiği JMX dosyası ile CSV dosyasının aynı klasörde olması veya CSV dosyasının CSV Data Set Config'de konfigüre edilirken JMX dosyasına göre relative path'inin verilmesi gerekliliğidir.

`jmeter_input.csv` dosya içeriği:

```
gsengun;Passw0rd;5358282828
adere;Passw0rd!!;5358282829
```

CSV Data Set Config bileşeninin görünümü aşağıda verilmiştir. 1 ile gösterilen bölümde CSV dosyasının adı (aslında JMX dosyasının konumuna göre relative path'i) verilmiştir. 2 ile gösterilen bölümde input dosyasındaki kolonlara atanacak değişken isimleri verilmiştir. İlk kolona `username`, ikinci kolona `password` ve üçüncü kolona da `mobile_phone` değişken adı atanmıştır. Debug Sampler'ın anlatıldığı kısımda burası örnekle birlikte daha anlaşılır hale gelecektir. Variable isimleri burada verilmek yerine CSV dosyasında ilk satır olarak da verilebilir. Bu durumda CSV Data Set Config bileşenindeki bu kısmın boş bırakılması gerekir. 3 ile gösterilen bölümde CSV dosyasında kolonlar arasındaki ayracın hangi karakter olduğu girilmiştir. Default değer virgüldür (,) fakat bizim dosyamızda noktalı virgül (;) kolon ayracı olarak kullanıldığı için bu bölüme (;) yazmamız gerekir.

{% include image.html url="/resource/img/JMeterPart1/JMeterCsvDataSetConfig.png" description="CSV Data Set Config" %}

#### Debug Sampler

JMeter her bir Thread için ayrı ayrı ya da bütün Thread'ler için ortak olarak geçerli olabilecek şekilde değişkenler tanımlanmasına izin vermektedir. Debug Sampler bileşeni ile ilgili Thread'e ve global olarak bütün Thread'lere ilişkin değişkenler gösterilebilir. Debug Sampler genellikle Test Plan hazırlanırken Test Script'ini debug etmek için kullanılır ve yük/performans testlerinin koşturulması sırasında devre dışı bırakılır. Kullanım senaryosuna örnek olması açısından ilk web servis çağrısından dönen JSON sonuçtaki bir alanın bir sonraki web servis çağrısına girdi olarak geçirildiği durumu ele alalım. İlk servis çağrısından dönen cevabın içindeki ilgili alan bir JMeter değişkenine atanır. Bu değişken sonraki çağrıda kullanılarak ikinci çağrı yapılır. Bu test plan'da araya bir Debug Sampler eklenerek JMeter'ın ilk web servis çağrısından parse edip doldurduğu değişkenin değeri okunarak parse işlemi için yazılan Regex'in doğru yapılandırılıp yapılandırılmadığı anlaşılır.

Debug Sampler'ı daha kolay örneklemek için bir önceki bölümde (CSV Data Set Config) ele alınan ve CSV dosyalarından okunan ve her bir Thread'e atanan değişkenleri ele alalım. Thread'lere atanan değişkenlerin (mobile_phone, password, username) değerleri (5358282828, Passw0rd, gsengun) aşağıdaki çıktıda sırasıyla 1, 2 ve 3 ile işaret edilmiştir. 

{% include image.html url="/resource/img/JMeterPart1/JMeterDebugSampler.png" description="JMeter Debug Sampler" %}

#### Assertion

JMeter'daki Assertion'lar da birçok programlama dilindeki Assertion'a benzer şekilde davranmaktadır. Programlama dillerindeki Assertion'larda gerçekleşmesi beklenen koşul belirlenir ve beklenen koşul dışındaki değerlerde Assertion Failure durumu oluşur ve akış kesilerek hatadan haberdar olunur. JMeter'da ise Assertion Failure oluştuğundaki davranış aşağıdaki çıktıda 1 ile gösterilen bölümde Thread Group'daki "Action to be taken after a Sampler error" konfigürasyonu ile belirlenir. Assertion Failure, Assertion'ın bağlı bulunduğu Sampler'da hataya sebep olacağı için bu konfigürasyonda girilecek aksiyon alınacaktır. 

{% include image.html url="/resource/img/JMeterPart1/JMeterThreadGroup.png" description="JMeter Thread Group" %}

Assertion'lar ile Thread bazlı olarak istenen test adımında değişkenler incelenip beklenmeyen koşullarda Assertion Failure oluşturulabileceği gibi, JMeter Sampler'lar ile yapılan request'lere verilen response'lar da incelenip beklenmeyen koşullar Assertion Failure oluşturmak üzere programlanabilir.

Aşağıda Test Plan'da Siyaset Sayfası'na bir Response Assertion eklenerek test edilecek response bölümü olarak "Response Code" seçilmiştir. Alttaki bölümde test edilecek patern olarak Response Code'un 400 olması beklendiği ifade edilmiştir. Response Code normal şartlarda sunucudan bildiğiniz gibi 200 olarak dönecektir. Böylece örneğimizde bir Assertion Failure'ı canlandırmış olacağız.

{% include image.html url="/resource/img/JMeterPart1/JMeterResponseAssertion.png" description="JMeter Response Assertion" %}

Test Plan'ı çalıştırdığımızda View Results Tree bileşeninde Assertion Failure durumu olan Sample'ların JMeter tarafından kırmızıya boyandığı ve Assertion Failure sebebinin sağ tarafta yazıldığı görülmektedir.

{% include image.html url="/resource/img/JMeterPart1/JMeterResponseAssertionFailure.png" description="JMeter Response Assertion Failure" %}

#### Pre Processor ve Post Processor (Extractor'lar)

JMeter Sampler'lar koşturulmadan önce ve sonra çalıştırılmak üzere sampler'lara sağ tıklanarak eklenebilecek Pre ve Post Processor'lar sunmaktadır. Post Processor'lardan Regular Expression Extractor'ı örnekleyerek Extractor'ların nasıl kullanıldıkları ile ilgili kafanızda bir fikir oluşturmaya çalışalım.

Yine aynı örneği (`www.milliyet.com.tr/siyaset/` sayfasını) kullanarak sayfa başında gösterilen ve HTML `<title>` tag'leri arasında bulunan sayfa başlığını alıp bir değişkene atmaya çalışalım. 

Regex ile yakalanacak metin aşağıda işaretlenmiştir.

{% include image.html url="/resource/img/JMeterPart1/JMeterMilliyetTitleRegexExtractor.png" description="JMeter Title Regex Extractor" %}

`<title>` tag'leri arasında bulunan sayfa başlığının alınabilmesi için gerekli olan JMeter Regular Expression Extractor konfigürasyonu aşağıda verilmiştir. 1 ile işaretlenen bölümde Regex ile parse edilen string'in atılacağı JMeter değişkeninin ismi verilmiştir. Bu değişken ilerleyen adımlarda `{$page_title}` olarak kullanılabilecektir. 2 ile işaretlenen bölümde HTML Response'u ile eşleştirilmek üzere gerekli olan Regular Expression (Düzenli İfade) verilmiştir. 3 ile işaretlenen bölümde Regex ile eşleşen değişkene atılacak değer için bir template belirtimi yapılmaktadır. `$1$` Regex'te ilk eşleşen grubu `$2$` Regex'te ikinci eşleşen grubu ifade etmektedir. Değişkenden başına `Sayfa Başlığı ` ve sonuna da `'dır` eklemek istersek template'i `Sayfa Başlığı $1$'dır` şeklinde vermemiz gerekir. 4 ile işaretlenen bölümde Regex ile birden fazla eşleşme olması durumunda hangi sıradaki eşleşmenin kullanılacağını belirler, bizim durumumuzda sadece 1 eşleşme olacağı için bu bölümde 1 kullanılmıştır. 

{% include image.html url="/resource/img/JMeterPart1/JMeterMilliyetTitleRegexExtractorConf.png" description="JMeter Title Regex Extractor Conf" %}

Response'lardan çıkarılan bilgilerin atıldığı değişkenlerin başka Sampler'larda kullanılabileceğini daha önce söylemiştik. Demo'da bu kullanımı örnekleyeceğiz. Şimdilik Debug Sampler'daki görünümü aşağıda vererek bu kısmı kapatalım. Görebileceğiniz üzere `page_title` değişkenine `<title>` tag'leri arasında bulunan başlık atılmış oldu.

{% include image.html url="/resource/img/JMeterPart1/JMeterMilliyetTitleRegexExtractorResult.png" description="JMeter Title Regex Extractor Result" %}

## JMeter GUI

Bir önceki bölümde başlangıç yapabilmemize olanak tanıyacak kadar JMeter bileşenlerine göz attık. Bu bölümde ise anlatılan bileşenlerin yerleştirildiği JMeter kullanıcı arayüzüne kısa bir bakış atacağız.

{% include image.html url="/resource/img/JMeterPart1/JMeterGuiDefault.png" description="JMeter GUI" %}

Yukarıdaki şekilde yeni bir JMeter test planı hazırlanmak üzere JMeter programı komut satırından başlatılmıştır. Görüleceği üzere 1 ile gösterilen bölümde Test Plan bulunmaktadır. Bu bölümde hiyerarşik olarak test plan adımları bir ağaç yapısı şeklinde sıralanacak ve JMeter tarafından koşturulacaktır. 

Önceki bölümlerde anlatıldığı gibi JMeter, kullanıcı senaryolarını daha gerçekçi olarak test edebilmek için farklı adımlar arasında belirli süre beklemek üzere Timer (Think Time) kullanılmasına izin vermektedir. 2 ile gösterilen bölümdeki “Oynat” butonları Test Plan’ın koşturulmaya başlanmasını sağlanmaktadır. Sol taraftaki “Oynat” butonuna basıldığında JMeter, Test Plan’ın arasına serpiştirilmiş olan Timer’ları dikkate alacak şekilde testi başlatacaktır. Sağ taraftaki Play butonu ise ilgili Timer’ları dikkate almadan testi başlatacaktır.

JMeter sunduğu geniş component setinin yanı sıra çok güçlü data toplama ve raporlama araçlarına sahiptir. Performans/yük testi yapılırken koşturumlar arasında sistemden alınan performans metriklerinin görülmesi, raporlanması ve saklanması kritiktir. JMeter data toplanması işlevi için bir önceki bölümde detaylı olarak ele aldığımız ve sonraki bölümlerde demo edeceğimiz pek çok Listener sağlamaktadır. 3 ile gösterilen bölümdeki "Süpürge" butonlarından sol tarafta olanına iki test koşturumu arasında basıldığında o anda ekranda görülen listener'da biriktirilmiş olan dataset'i sıfırlar. Sağ tarafta bulunan Süpürge butonu ise Test Plan'da bulunan bütün dataset'leri sıfırlar.

Bir Test Plan'ın farklı aşamalarında farklı sayıda kullanıcı veya farklı girdi set'leri kullanmasını isteyebiliriz. Dolayısıyla farklı kullanıcı senaryolarını aynı Test Plan'da test etmek üzere bir Test Plan'da birden fazla Thread Group konumlandırılabilir. 4 ile gösterilen bölümde bu Thread Group'lar ile ilgili konfigürasyonlar verilmiştir. "Run Thread Groups consecutively"ın seçilmesi ile Test Plan'daki Thread Group'lar paralel koşturulmanın aksine ardı ardına koşturulur. 

JMeter, Thread Group'ların çalıştırılmaya başlamasından önce Thread Group'un doğru bir biçimde koşturulabilmesi için gerekli ön ayarlamaların yapılmasına imkan tanıyan "setUp Thread Group"lar ve Thread Group'un işi bittikten sonra gerekli kaynak temizleme işlemlerinin yapılabileceği "tearDown Thread Group"lar sağlamaktadır. "Run tearDown Thread Groups after shutdown of main threads" ayarı seçildiğinde "tearDown Thread Group"lar sadece Thread Group'ların başarılı koşturumlarından sonra çalıştırılırlar fakat Test Plan koşturum devam ederken durdurulursa çalıştırılmazlar. 

## Sonuç

Bu blog'da genel olarak test terminolojilerinin üzerinden geçip, JMeter bileşenlerini yakından inceleyerek JMeter ile bir test senaryosu hazırlayabilecek duruma geldik. [Bir sonraki blog'da](/jmeter-fonksiyon-testi-hazirlama/) JMeter ile, ilgi çekici bir demo hazırlayarak öğrendiğimiz test kavramlarını ve JMeter bileşenlerini kullanarak öğrendiğimiz bilgileri pekiştirmeye çalışacağız. 

#### Teşekkür

Bu blog yazısını gözden geçiren ve düzeltmelerini yapan Dr. Mehmet Alper Uslu'ya ([alperuslu.net](http://alperuslu.net/)) teşekkür ederiz.
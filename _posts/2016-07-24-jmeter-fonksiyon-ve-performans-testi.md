---
layout: post
title: "JMeter Bölüm 2: Fonksiyon ve Performans Testi Nasıl Yapılır?"
level: Orta Düzey
---

Bu blog yazımda bir önceki blog yazısında detaylı olarak tanıtımını yaptığım JMeter aracı ile baştan sona bir fonksiyonel test demosu hazırlayacağız. Karşılaştığımız bütün problemleri çözecek ve bir sonraki adıma geçeceğiz. Fonksiyonel test script'imiz hazır olduktan sonra aynı script'i kullanarak bir performans testi hazırlayıp koşturacağız. Bu sayede fonksiyonel test ve performans testi arasındaki farklara JMeter gözünden de bakmış olacağız.

JMeter ile önceden bir deneyiminiz yoksa öncelikle aşağıdaki blog yazısını okuyarak başlamanızı öneririm. Önceden deneyiminiz varsa bile aşağıda verilen blog yazısını okumanızda fayda olduğunu düşünüyorum. 

[JMeter Bölüm 1: Nedir ve Ne İşe Yarar?](/jmeter-nedir-ve-ne-ise-yarar/)

Bu blog yazısını okuduktan sonra ise aşağıdaki yazısına göz atmanızı tavsiye ederim. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyorum.

[JMeter Bölüm 3: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

Şimdi isterseniz ufaktan başlayalım.

## Github Fonksiyon Testi - Demo
___

### Hazırlık

JMeter'ı test etmek için sunucu tarafında koşan bir uygulamaya ihtiyacımız var. Demo amaçlı olarak basit bir uygulamayı kendimiz de hazırlayıp yayınlayabiliriz ancak servis olarak birçoğumuzun bildiği bir servisi ele alarak JMeter'a yoğunlaşmamız daha pratik olacak. JMeter ile test edeceğimiz servis Github olacak.

* Bir sonraki bölümde detaylarını vereceğimiz fonksiyonları JMeter'da hazırlıp bir kullanıcı için koşturacağız ve fonksiyonel testi tamamlamış olacağız.
* Hazırladığımız senaryoyu farklı kullanıcılar için farklı input'lar verecek şekilde ayarlayıp küçük çaplı bir performans testi yapacağız.

#### Test Edilecek Fonksiyonlar

Github.com bir blog yazısında fonksiyonel olarak test edilemeyecek kadar fazla fonksiyon içermektedir. Bu blog yazısında test edeceğimiz fonksiyonlar aşağıdaki gibi olacak.

1. Github.com'un ana sayfası ve ana sayfası altında referans verilen bütün imaj, css ve js dosyalarının çekilmesi.
2. Github.com'un login sayfası ve yine bu sayfadaki bütün resource dosyalarını çekilmesi.
3. Kullanıcı adı ve parola ile Github.com'a giriş yapılması.
4. İlgili kullanıcının bütün repository'lerinin listelenmesi.
5. Rastgele seçilen bir repository'deki bütün commit'lerin listelenmesi.
6. Rastgele seçilen bir commit'in comment kısmının okunması.
7. Github.com'dan çıkış yapılması.

#### Yöntem

JMeter'da test senaryosu hazırlamak için test edeceğimiz senaryoyu öncelikle bir web browser'da (tarayıcı) test edip yapılan request'leri tarayıcımızın geliştirici araçları veya Fiddler, Burp Suite gibi Web Debugging Proxy araçları ile yakalayıp aynı düzende ve sırada JMeter'da konfigüre etmemiz gereklidir. Bu yönteme alternatif ve daha pratik olarak JMeter tarafından sağlanan ve tarayıcıdan yapılan bütün request'lerin JMeter üzerinden geçirilmesi (JMeter'ın proxy olarak kullanılması) sağlanarak kaydedilen request'ler düzenlenmek sureti ile de JMeter test senaryosu hazırlanabilir. İlk methodu anlamadan ikinci methodu etkili kullanmak pek mümkün olmadığı için ben test edilecek 7 fonksiyonun ilk 3 adımını ilk yöntemle son 4 adımını ise ikinci yöntemle yapmayı planladım.

### Adımlar

1. JMeter'da yeni bir Test Plan oluşturarak adını "Github Functional Test" olarak belirleyin ve Test Plan'ı kaydedin. Aşağıdaki gibi bir ekran görüntüsü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/CreateANewTestPlan.png" description="New Test Plan" %}

2. Test Plan üzerinde sağ tıklayarak Add > Threads (Users) > Thread Group menüsünü izleyerek yeni bir Thread Group ekleyin. Thread Group'un ismini istediğiniz gibi güncelleyerek "Action to be taken after a Sampler error" bölümünden "Stop Test"i seçin, böylece adımların herhangi birinde bir hata oluştuğunda testin diğer adımları koşturulmaz ve test sonlandırılır. Fonksiyonel test koşturduğumuz için Test Plan'ın hiçbir hata olmadan koşturulması gerekecektir. Değişikliği yaptıktan sonra aşağıdakine benzer bir ekran görüntüsü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/CreateANewThreadGroup.png" description="New Thread Group" %}

3. Thread Group üzerinde sağ tıklayarak aşağıdaki bileşenleri ekleyin. 
    * Add > Config Element > HTTP Request Defaults
    * Add > Config Element > HTTP Cookie Manager
    * Add > Config Element > HTTP Cache Manager

    HTTP Request Defaults, Test Plan'ımıza ekleyeceğimiz bütün HTTP Request'lerde geçerli olacak default değerleri belirlememize yardımcı olacak. HTTP Request Defaults bileşenini açarak "Server Name or IP" bölümüne "github.com", Protocol [http] bölümüne ise "https" yazın.

    HTTP Cookie Manager, JMeter'ın web sunucudan gönderilen cookie'leri almasını ve sonraki request'lerde web sunucuya göndermesini sağlayacaktır.

    HTTP Cache Manager, JMeter'ın web sunucu tarafından HTTP header'da set edilen cache direktiflerine uymasını ve cache kontrolü bakımından bir browser gibi davranmasını sağlayacaktır. Örneğin, ilk request sonucunda sunucudan çekilen bir JavaScript dosyası server tarafından bir saat boyunca cache'lenebilir olarak ifade edilmişse JMeter tarafından ikinci request'te aynı JavaScript dosyasının gerekli olduğu durumda sunucudan istenmeyecek ve lokal olarak cache'lenen versiyon kullanılacaktır. Bu da testin gerçeğe yakın olmasını sağlayacaktır. Eğer testi HTTP Cache Manager kullanmadan yaparsak normal senaryoda browser tarafından cache'lendiği için sunucudan istenmeyen kaynaklar JMeter tarafından istenecek ve sunucu açısından test koşullarının normal koşullardan daha zor olmasına ve testin gerçeklikten uzaklaşmasına neden olacaklardır.

    Aşağıdaki gibi bir ekran görüntüsü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/AddHttpConfigElements.png" description="Add Http Config Elements" %}

4. Thread Group üzerinde sağ tıklayarak Add > Sampler > HTTP Request ile ilk HTTP Sampler'ımızı JMeter projesine ekleyelim. Sampler'ımızın ismini "Github Ana Sayfası" olarak değiştirerek path kısmına `/` yazalım. Hatırlayacağınız gibi HTTP isteği yapacağımız adres daha önce eklediğimiz HTTP Request Defaults Config Element'inden alınacak. Aşağıdaki gibi bir ekran görüntüsü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/AddMainPageHttpRequestSampler.png" description="Add Main Page HTTP Request Sampler" %}

5. Thread Group üzerinde sağ tıklayarak Add > Listener > View Results Tree ile HTTP Request'lerin kaydedilmesi amacı ile bir listener ekleyin. View Results Tree bileşeni seçili iken Start butonuna basarak testi çalıştırın. Yapılan request'e tıklayarak sağ tarafta, Request ve Response data sekmelerine tıklayarak yapılan request'le ilgili detayları görebilirsiniz. Aşağıda benim denemem sonucu oluşan görüntüyü görebilirsiniz.

    {% include image.html url="/resource/img/JMeterPart2/RequestingMainPage.png" description="Requesting Main Page" %}

    Bu adımda Github Ana Sayfasını istedik ve HTML'ini aldık. Dikkat ettiyseniz sunucu JMeter'a sadece ana sayfanın HTML'ini gönderdi. Test senaryomuzun daha gerçekçi olabilmesi için Ana Sayfa ile birlikte Ana Sayfadaki resource'ları (imaj, css, js) da istememiz gerekir çünkü gerçek kullanıcı tarayıcı ile Github Ana Sayfasını ziyaret ettiğinde imajlarla birlikte formatlanmış (css) ve etkileşime girebileceği (JavaScript) bir site bekleyecektir. 

    HTML sayfa ile birlikte sayfa HTML'inde referans edilen resource'ları indirmek için HTTP Request Sampler bileşeninde "Retrieve All Embedded Resources" seçeneği seçili olmalıdır.

    {% include image.html url="/resource/img/JMeterPart2/RetrieveAllEmbeddedResources.png" description="Retrieve All Embedded Resources" %}
    
    Bu seçenek işaretlenip, önceki test sonucu Clear edilerek test tekrar başlatıldığında Ana Sayfa içinde embed edilmiş kaynakların da sunucudan istendiği görülecektir.

    {% include image.html url="/resource/img/JMeterPart2/RequestingMainPageWithResources.png" description="Requesting Main Page with Resources" %}
    
    Sunucudan dönen cevabın HTML cevabın text format yerine render edilmiş olarak verilmesi isteniyorsa View Results Tree'de ilgili sample seçilir ve format olarak "HTML (Download Resources)" seçilir. Bu örnekte cevap HTML olduğu için HTML seçtik dönen cevap JSON olsaydı, JSON şeklinde formatlamak için JSON seçebilirdik.

    {% include image.html url="/resource/img/JMeterPart2/RequestingMainPageResponseHTMLFormatted.png" description="Requesting Main Page HTML Formatted Response" %}
 
6. Thread Group üzerinde sağ tıklayarak Add > Sampler > HTTP Request ile Login sayfası için gerekli HTTP Sampler'ımızı JMeter projesine ekleyelim. Github.com üzerinden Sign in butonuna bastığımızda https://github.com/login adresine yönlendirilmekteyiz. https://github.com adresini HTTP Request Defaults Config Bileşeninde tanımlamıştık dolayısıyla Sampler'da Path olarak `/login` yazmamız yeterli olacaktır. Sampler'ımızın ismini "Github Login Sayfası" olarak değiştirip son olarak da "Retrieve All Embedded Resources" seçeneğini seçelim. Aşağıdakine benzer bir ekran görüntüsü elde etmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/RequestingLoginPage.png" description="Add Login Page HTTP Request Sampler" %}

7. View Results Tree bileşeni seçili iken Start butonuna basarak testi tekrar çalıştırın. Sign in sayfasının sunucudan istendiğini ve cevap olarak kullanıcı adı ve parola istenen sayfanın gönderildiğini teyit edin.

    {% include image.html url="/resource/img/JMeterPart2/RequestingLoginPageWithResources.png" description="Requesting Login with Resources" %}

8. Bundan önceki adımları tamamlayarak "Test Edilecek Fonksiyonlar" bölümünde yer verdiğimiz ilk iki fonksiyonu gerçekleştirmiş olduk. Üçüncü fonksiyon Github.com'a kullanıcı adı ve parola ile giriş yapmamızı gerektiriyor. İlk iki adımda HTTP GET ile sunucudan HTML sayfaları ve embed edilen resource'ları istemiştik. Bu adımda is HTTP POST kullanacağız. Öncelikle tarayıcımızın Geliştirici Konsolunu (Developer Console) açarak Github.com'a tarayıcı üzerinden yapılan giriş işlemlerinde hangi URL'ye POST edildiğini tespit edeceğiz ve JMeter'da aynı ayarlamayı yapacağız.

    Bu adımda öncelikle tarayıcımızın geliştirici konsolu penceresini açarak Github.com'a login olalım ve yapılan request'leri görelim. 

    Aşağıda Firefox tarayıcısında Network tabı açıkken yaptığım giriş denemesi görülüyor. Yapılan request'in bir POST request'i olduğu ve URL'inin `/session` olarak verildiği aşağıdaki ekran çıktısından görülebilir.

    {% include image.html url="/resource/img/JMeterPart2/LoginPagePostRequestUrl.png" description="Login Post Grab URL From Firefox" %}

    Yukarıdaki ekran çıktısında görülen bir başka detay da `/session` URL'ine yapılan POST request'ine dönülen cevabın 302 olmasıdır. Burada klasik PRG (Post/Redirect/Get) pattern'i uygulanmıştır. PRG pattern'i konumuz dışında fakat başka bir blog post'a konu olmaya değer bir patterndir. Kısaca buradaki durum üzerinden açıklamak gerekirse, `/session` URL'ine yapılan isteğe sunucu 302 Found (istenen URL başka bir adresten hizmet vermektedir) cevabı ile istemciye bir URL sağlar ve bu URL'e GET request yaparak işleme devam etmesini salık verir. POST sonucunda gidilecek adres HTTP Response Header'ında "Location" anahtarında verilir. Bizim durumumuzda bu URL https://github.com olarak verilmiştir. Yani Github login olduktan sonra bizi login sayfasına geldiğimiz adrese (bizim durumumuzda Ana Sayfa) yönlendirmektedir. Yukarıdaki çıktıda 302 Status Code ile sonuçlanan request'ten sonra `/`ya yapılan GET request'inin hikmeti budur.

    Konuyu dağıtıyormuşum gibi gelebilir size ancak bir sonraki bölümde yapacağımız HTTP Request Sampler konfigürasyonunu anlamanız için gerekli altyapıyı oluşturmuş olduk böylece.

9. Thread Group üzerinde sağ tıklayarak Add > Sampler > HTTP Request ile Login olmak için gerekli HTTP Sampler'ımızı JMeter projesine ekleyelim. Sampler'ın ismini "Github Login - POST" olarak girdikten sonra Path kısmına `/Session` yazıp Method kısmını GET'ten POST'a getirelim.

    Parameters bölümünü aşağıdaki bilgilerle doldurun. `login` ve `password` bölümlerinde kendi kullanıcı adınız ve parolanızı yazın. Follow Redirects'i işaretleyerek POST request'ten dönecek 302 Found ile birlikte gösterilecek adrese JMeter'in GET request yapmasını sağlayabiliriz. 

    {% include image.html url="/resource/img/JMeterPart2/LoginPostRequestIncomplete.png" description="Login Post Request Not Complete Yet" %}

    View Results Tree'ye gelerek testi başlatın. Aşağıda göreceğiniz şekilde bir hata almalısınız, endişeye kapılmayın biraz sonra o hatayı düzelteceğiz. Hata mesajından da göreceğiniz gibi Github sunucusu isteğimizi reddetti. Reddederken de bize bir şeyleri eksik yapmış olabileceğimiz ile ilgili ipuçları verdi. 

    {% include image.html url="/resource/img/JMeterPart2/LoginPostResponseToIncompleteRequest.png" description="Login Post Response to Not Complete Request" %}

    Github ve iyi bir şekilde güvenlik önlemi alınmış bütün siteler CSRF (Cross Site Request Forgery)'den korunmak için POST request'lerinde POST request'i öncesinde kendisinden GET request'i ile istenen sayfaya koydukları bir `Magic String`i sağlamalarını beklerler. Böylelikle POST request'i çağıran sayfanın kendi sayfaları olduğunu garanti altına alırlar, bu request'ler başka bir sayfadan çağrılamaz. Bizim örneğimizde https://github.com/login sayfasının içindeki Magic String'i bularak onu POST request'inde `authenticity_token` olarak vermemiz gerekiyor.

    https://github.com/login sayfasının kaynak koduna bakarsanız aşağıdakine benzer bir şekilde hidden olarak verilen bir input element görmelisiniz.
    
            <input name="authenticity_token" type="hidden" value="OZQVgGatz567XqBvhGLIMNAK3Qxq+TyTngBdCDsGshz+2C3Yp3gWN554RKVPw1+JBohpSF1zt/8ALxx1uoa/4w==" /> 

    Bir önceki blog post'u dikkatli takip ettiyseniz burada bir Post Processor (Extractor) kullanarak Regex yardımı ile `authenticity_token` alıp POST request'inde kullanabileceğimizi muhtemelen hemen farkettiniz. Şimdi bunu yapalım. 
    
    "Github Login Sayfası" adını verdiğimiz HTTP Request Sampler'a sağ tıklayarak Add > Post Processor > Regular Expression Extractor bileşenini ekleyin. Aşağıdaki çıktıda görüldüğü gibi konfigüre edin. İsterseniz, önceki blog'da anlatıldığı gibi "Github Login Sayfası"ndan sonra bir Debug Sampler ekleyerek parse edilen ve `the_auth_token` değişkenine atılan dinamik değeri görebilirsiniz.

    {% include image.html url="/resource/img/JMeterPart2/LoginAuthTokenExtractor.png" description="Login Auth Token Extractor" %}

    Şimdi sıra "Github Login - Post"taki parametrelere `authenticity_token` parametresini eklemeye geldi. `the_auth_token` değişkeninden alınacak değeri aşağıdaki gibi ekleyebilirsiniz.

    {% include image.html url="/resource/img/JMeterPart2/LoginPostRequestComplete.png" description="Login Post Request Complete" %}

    Testi tekrar çalıştırarak testin bu kez başarılı bir şekilde login olabildiğini sonrasında da POST'a cevap olarak gönderilen Redirect linkini takip ederek Ana Sayfaya - fakat bu kez login olmuş vaziyette - döndüğünü (Ana Sayfayı istediğini) görebilirsiniz. Sizdeki görüntü de aşağıdaki gibi olmalıdır.

    {% include image.html url="/resource/img/JMeterPart2/LoginPostResponseToCompleteRequest.png" description="Login Post Response to Complete Request" %}
---
layout: post
title: "JMeter Bölüm 2: Fonksiyon Testi Nasıl Hazırlanır?"
level: Orta
lang: tr
ref: jmeter-part-2
---

Bu blog'da bir önceki blog yazısında detaylı olarak tanıtımını yaptığımız JMeter aracı ile baştan sona bir fonksiyonel test demosu hazırlayacağız. Karşılaştığımız bütün problemleri çözecek ve bir sonraki adıma geçeceğiz. Fonksiyonel test script'imiz hazır olduktan sonra aynı script'i kullanarak testimize doğruluk ölçmeye yardımcı olacak Assertion'lar ekleyerek script'imizi Continuous Integration pipeline'ında kullanılabilir hale getirmeye çalışacağız. JMeter'ın Continuous Integration (CI) ve Continuous Delivery (CD) pipeline'larında nasıl kullanılabileceği sorusu ilerleyen zamanlarda başka bir blog'da cevap bulacak. 

JMeter ile önceden bir deneyiminiz yoksa öncelikle aşağıdaki blog yazısını okuyarak başlamanız önerilir. Önceden deneyiminiz varsa bile aşağıda verilen blog yazılarını okumanızda fayda bulunmaktadır. 

[JMeter Bölüm 1: Nedir ve Ne İşe Yarar?](/jmeter-nedir-ve-ne-ise-yarar/)

Bu blog yazısını okuduktan sonra aşağıdaki blog yazılarını da sırasıyla okumanız tavsiye edilir. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyoruz.

[JMeter Bölüm 3: Pratik Test Senaryosu Kaydı Nasıl Yapılır?](/jmeter-pratik-test-hazirlama/)

[JMeter Bölüm 4: Performans Testi Nasıl Hazırlanır??](/jmeter-performans-testi-hazirlama/)

[JMeter Bölüm 5: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

Şimdi isterseniz ufaktan başlayalım.

## Github Fonksiyon Testi - Demo

### Hazırlık

JMeter'ı test etmek için sunucu tarafında koşan bir web uygulamasına ihtiyacımız var. Demo amaçlı olarak basit bir uygulamayı kendimiz de hazırlayıp yayınlayabiliriz ancak web sitesi olarak fonksiyonunu ve ekranlarını birçoğumuzun bildiği bir siteyi ele alarak JMeter'a yoğunlaşmamız daha pratik olacaktır. JMeter ile test edeceğimiz web sitesi Github olarak belirlenmiştir.

* Bir sonraki bölümde detaylarını vereceğimiz fonksiyonları JMeter'da hazırlayıp bir kullanıcı için koşturacağız ve fonksiyonel testi tamamlamış olacağız.
* Hazırladığımız senaryoda yapılan Request'lere verilen cevaplar üzerinde doğruluk testleri yapacağız.

#### Test Edilecek Fonksiyonlar

Github.com bir blog yazısında fonksiyonel olarak test edilemeyecek kadar fazla fonksiyon içermektedir. Bu blog yazısında test edeceğimiz fonksiyonlar aşağıdakilerle sınırlanmıştır.

1. Github.com'un ana sayfası ve ana sayfası altında referans verilen bütün imaj, css ve js dosyalarının çekilmesi.
2. Github.com'un login sayfası ve yine bu sayfadaki bütün resource dosyalarının çekilmesi.
3. Kullanıcı adı ve parola ile Github.com'a giriş yapılması.
4. İlgili kullanıcının bütün repository'lerinin listelenmesi.
5. Rastgele seçilen bir repository'de master branch'teki bütün commit'lerin SHA1 id'lerinin listelenmesi.
6. Github.com'dan çıkış yapılması.

#### Yöntem

JMeter'da test senaryosu hazırlamak için test edeceğimiz senaryoyu öncelikle bir Web Browser'da (tarayıcı) test edip yapılan Request'leri tarayıcımızın geliştirici araçları veya Fiddler, Burp Suite gibi Web Debugging Proxy (HTTP Proxy) araçları ile yakalayıp aynı düzende ve sırada JMeter'da konfigüre etmemiz gereklidir. Bu yönteme alternatif ve daha pratik olarak JMeter tarafından sağlanan ve tarayıcıdan yapılan bütün Request'lerin JMeter üzerinden geçirilmesi (JMeter'ın proxy olarak kullanılması) sağlanarak kaydedilen Request'ler düzenlenmek sureti ile de JMeter test senaryosu hazırlanabilir. İlk methodu anlamadan ikinci methodu etkili kullanmak pek mümkün olmadığı için bu blog'da ilk method kullanılacaktır. İkinci methodu ise bir sonraki blog'da ele alacağız.

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

    HTTP Cookie Manager, JMeter'ın web sunucudan gönderilen cookie'leri almasını ve sonraki Request'lerde web sunucuya göndermesini sağlayacaktır.

    HTTP Cache Manager, JMeter'ın web sunucu tarafından HTTP Header'da set edilen Cache direktiflerine uymasını ve Cache kontrolü bakımından bir browser gibi davranmasını sağlayacaktır. Örneğin, ilk Request sonucunda sunucudan çekilen bir JavaScript dosyası server tarafından bir saat boyunca Cache'lenebilir olarak ifade edilmişse JMeter tarafından ikinci Request'te aynı JavaScript dosyasının gerekli olduğu durumda sunucudan istenmeyecek ve lokal olarak Cache'lenen versiyon kullanılacaktır. Bu da testin gerçeğe yakın olmasını sağlayacaktır. Eğer testi HTTP Cache Manager kullanmadan yaparsak normal senaryoda browser tarafından Cache'lendiği için sunucudan istenmeyen kaynaklar JMeter tarafından istenecek ve sunucu açısından test koşullarının normal koşullardan daha zor olmasına ve testin gerçeklikten uzaklaşmasına neden olacaklardır.

    Aşağıdaki gibi bir ekran görüntüsü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/AddHttpConfigElements.png" description="Add Http Config Elements" %}

4. Thread Group üzerinde sağ tıklayarak Add > Sampler > HTTP Request ile ilk HTTP Sampler'ımızı JMeter projesine ekleyelim. Sampler'ımızın ismini "Github Ana Sayfası" olarak değiştirerek path kısmına `/` yazalım. Hatırlayacağınız gibi HTTP isteği yapacağımız adres daha önce eklediğimiz HTTP Request Defaults Config Element'inden alınacak. Aşağıdaki gibi bir ekran görüntüsü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/AddMainPageHttpRequestSampler.png" description="Add Main Page HTTP Request Sampler" %}

5. Thread Group üzerinde sağ tıklayarak Add > Listener > View Results Tree ile HTTP Request'lerin kaydedilmesi amacı ile bir listener ekleyin. View Results Tree bileşeni seçili iken Start butonuna basarak testi çalıştırın. Yapılan Request'e tıklayarak sağ tarafta, Request ve Response data sekmelerine tıklayarak yapılan Request'le ilgili detayları görebilirsiniz. Aşağıda yapılan denemede oluşan sonucun ekran görüntüsünü görebilirsiniz.

    {% include image.html url="/resource/img/JMeterPart2/RequestingMainPage.png" description="Requesting Main Page" %}

    Bu adımda Github Ana Sayfasını istedik ve HTML'ini aldık. Dikkat ettiyseniz sunucu JMeter'a sadece Ana Sayfanın HTML'ini gönderdi. Test senaryomuzun daha gerçekçi olabilmesi için Ana Sayfa ile birlikte Ana Sayfadaki resource'ları (imaj, css, js) da istememiz gerekir çünkü gerçek kullanıcı tarayıcı ile Github Ana Sayfasını ziyaret ettiğinde imajlarla birlikte formatlanmış (css) ve etkileşime girebileceği (JavaScript) bir site bekleyecektir. 

    HTML sayfa ile birlikte sayfa HTML'inde referans edilen resource'ları indirmek için HTTP Request Sampler bileşeninde "Retrieve All Embedded Resources" seçeneği seçili olmalıdır.

    {% include image.html url="/resource/img/JMeterPart2/RetrieveAllEmbeddedResources.png" description="Retrieve All Embedded Resources" %}
    
    Bu seçenek işaretlenip, önceki test sonucu Clear edilerek test tekrar başlatıldığında Ana Sayfa içinde Embed edilmiş kaynakların da sunucudan istendiği görülecektir.

    {% include image.html url="/resource/img/JMeterPart2/RequestingMainPageWithResources.png" description="Requesting Main Page with Resources" %}
    
    Sunucudan dönen HTML cevabın text format yerine render edilmiş olarak verilmesi isteniyorsa View Results Tree'de ilgili sample seçilir ve format olarak "HTML (Download Resources)" seçilir. Bu örnekte cevap HTML olduğu için HTML seçtik dönen cevap JSON olsaydı, JSON şeklinde formatlamak için JSON seçebilirdik.

    {% include image.html url="/resource/img/JMeterPart2/RequestingMainPageResponseHTMLFormatted.png" description="Requesting Main Page HTML Formatted Response" %}
 
6. Thread Group üzerinde sağ tıklayarak Add > Sampler > HTTP Request ile Login sayfası için gerekli HTTP Sampler'ımızı JMeter projesine ekleyelim. Github.com üzerinden Sign in butonuna bastığımızda `https://github.com/login` adresine yönlendirilmekteyiz. `https://github.com` adresini HTTP Request Defaults Config Bileşeninde tanımlamıştık dolayısıyla Sampler'da Path olarak `/login` yazmamız yeterli olacaktır. Sampler'ımızın ismini "Github Login Sayfası" olarak değiştirip son olarak da "Retrieve All Embedded Resources" seçeneğini seçelim. Aşağıdakine benzer bir ekran görüntüsü elde etmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/RequestingLoginPage.png" description="Add Login Page HTTP Request Sampler" %}

7. View Results Tree bileşeni seçili iken Start butonuna basarak testi tekrar çalıştırın. Sign in sayfasının sunucudan istendiğini ve cevap olarak kullanıcı adı ve parola istenen sayfanın gönderildiğini teyit edin.

    {% include image.html url="/resource/img/JMeterPart2/RequestingLoginPageWithResources.png" description="Requesting Login with Resources" %}

8. Bundan önceki adımları tamamlayarak "Test Edilecek Fonksiyonlar" bölümünde yer verdiğimiz ilk iki fonksiyonu gerçekleştirmiş olduk. Üçüncü fonksiyon Github.com'a kullanıcı adı ve parola ile giriş yapmamızı gerektiriyor. İlk iki adımda HTTP GET ile sunucudan HTML sayfaları ve Embed edilen resource'ları istemiştik. Bu adımda ise HTTP POST kullanacağız. Öncelikle tarayıcımızın Geliştirici Konsolunu (Developer Console) açarak Github.com'a tarayıcı üzerinden yapılan giriş işlemlerinde hangi URL'ye POST edildiğini tespit edeceğiz ve JMeter'da aynı ayarlamayı yapacağız.

    Bu adımda öncelikle tarayıcımızın geliştirici konsolu penceresini açarak Github.com'a login olalım ve yapılan Request'leri görelim. 

    Aşağıda Firefox tarayıcısında Network tabı açıkken yapılan giriş denemesi görülüyor. Yapılan Request'in bir POST Request'i olduğu ve URL'inin `/session` olarak verildiği aşağıdaki ekran çıktısından görülebilir.

    {% include image.html url="/resource/img/JMeterPart2/LoginPagePostRequestUrl.png" description="Login Post Grab URL From Firefox" %}

    Yukarıdaki ekran çıktısında görülen bir başka detay da `/session` URL'ine yapılan POST Request'ine dönülen cevabın 302 olmasıdır. Burada klasik PRG (Post/Redirect/Get) pattern'i uygulanmıştır. PRG pattern'i konumuz dışında fakat başka bir blog post'a konu olmaya değer bir patterndir. Kısaca buradaki durum üzerinden açıklamak gerekirse, `/session` URL'ine yapılan isteğe sunucu 302 Found (istenen URL başka bir adresten hizmet vermektedir) cevabı ile istemciye bir URL sağlar ve bu URL'e GET Request yaparak işleme devam etmesini salık verir. POST sonucunda gidilecek adres HTTP Response Header'ında "Location" anahtarında verilir. Bizim durumumuzda bu URL `https://github.com` olarak verilmiştir. Yani Github, login olduktan sonra bizi login sayfasına geldiğimiz adrese (bizim durumumuzda Ana Sayfa) yönlendirmektedir. Yukarıdaki çıktıda 302 Status Code ile sonuçlanan Request'ten sonra `/`ya yapılan GET Request'inin hikmeti budur.

    Size konuyu dağıtıyormuşum gibi gelebilir ancak böylece bir sonraki bölümde yapacağımız HTTP Request Sampler konfigürasyonunu anlamanız için gerekli altyapıyı oluşturmuş olduk.

9. Thread Group üzerinde sağ tıklayarak Add > Sampler > HTTP Request ile Login olmak için gerekli HTTP Sampler'ımızı JMeter projesine ekleyelim. Sampler'ın ismini "Github Login - POST" olarak girdikten sonra Path kısmına `/Session` yazıp Method kısmını GET'ten POST'a getirelim.

    Parameters bölümünü aşağıdaki bilgilerle doldurun. `login` ve `password` bölümlerinde kendi kullanıcı adınız ve parolanızı yazın. Follow Redirects'i işaretleyerek POST Request'ten dönecek 302 Found ile birlikte gösterilecek adrese JMeter'in GET Request yapmasını sağlayabiliriz. 

    {% include image.html url="/resource/img/JMeterPart2/LoginPostRequestIncomplete.png" description="Login Post Request Not Complete Yet" %}

    View Results Tree'ye gelerek testi başlatın. Aşağıda göreceğiniz şekilde bir hata almalısınız, endişeye kapılmayın biraz sonra o hatayı düzelteceğiz. Hata mesajından da göreceğiniz gibi Github sunucusu isteğimizi reddetti. Reddederken de bize bir şeyleri eksik yapmış olabileceğimiz ile ilgili ipuçları verdi. 

    {% include image.html url="/resource/img/JMeterPart2/LoginPostResponseToIncompleteRequest.png" description="Login Post Response to Not Complete Request" %}

    Github ve iyi bir şekilde güvenlik önlemi alınmış bütün siteler CSRF (Cross Site Request Forgery)'den korunmak için POST Request'lerinde POST Request'i öncesinde kendisinden GET Request'i ile istenen sayfaya koydukları bir `Magic String`i sağlamalarını beklerler. Böylelikle POST Request'i çağıran sayfanın kendi sayfaları olduğunu güvence altına almaya çalışırlar, bu Request'ler başka bir sayfadan çağrılamaz. Bizim örneğimizde `https://github.com/login` sayfasının içindeki Magic String'i bularak onu POST Request'inde `authenticity_token` olarak vermemiz gerekiyor.

    `https://github.com/login` sayfasının kaynak koduna bakarsanız aşağıdakine benzer bir şekilde hidden olarak verilen bir input element görmelisiniz.
    
            <input name="authenticity_token" type="hidden" value="OZQVgGatz567XqBvhGLIMNAK3Qxq+TyTngBdCDsGshz+2C3Yp3gWN554RKVPw1+JBohpSF1zt/8ALxx1uoa/4w==" /> 

    Bir önceki blog post'u dikkatli takip ettiyseniz burada bir Post Processor (Extractor) kullanarak Regex yardımı ile `authenticity_token` alıp POST Request'inde kullanabileceğimizi muhtemelen hemen farkettiniz. Şimdi bunu yapalım. 
    
    "Github Login Sayfası" adını verdiğimiz HTTP Request Sampler'a sağ tıklayarak Add > Post Processor > Regular Expression Extractor bileşenini ekleyin. Aşağıdaki çıktıda görüldüğü gibi konfigüre edin. İsterseniz, önceki blog'da anlatıldığı gibi "Github Login Sayfası"ndan sonra bir Debug Sampler ekleyerek parse edilen ve `the_auth_token` değişkenine atılan dinamik değeri görebilirsiniz.

    {% include image.html url="/resource/img/JMeterPart2/LoginAuthTokenExtractor.png" description="Login Auth Token Extractor" %}

    Şimdi sıra "Github Login - Post"taki parametrelere `authenticity_token` parametresini eklemeye geldi. `the_auth_token` değişkeninden alınacak değeri aşağıdaki gibi ekleyebilirsiniz.

    {% include image.html url="/resource/img/JMeterPart2/LoginPostRequestComplete.png" description="Login Post Request Complete" %}

    Testi tekrar çalıştırarak testin bu kez başarılı bir şekilde login olabildiğini sonrasında da POST'a cevap olarak gönderilen Redirect linkini takip ederek Ana Sayfaya - fakat bu kez login olmuş vaziyette - döndüğünü (Ana Sayfayı istediğini) görebilirsiniz. Sizdeki görüntü de aşağıdaki gibi olmalıdır.

    {% include image.html url="/resource/img/JMeterPart2/LoginPostResponseToCompleteRequest.png" description="Login Post Response to Complete Request" %}

10. Bir önceki adımla birlikte test etmeyi planladığımız ilk üç fonksiyonu test ettik. Bir sonraki adım kullanıcıların bütün repository'lerini listeleme ile ilgili. Bir kullanıcının bütün repository'lerini listeleyen Github url'i `/gokhansengun?tab=repositories` dir. Bu URL'e yapılan GET Request'i ile gelen sayfayı tarayıcınızın sağladığı geliştirici araçlarından inspector ile incelediğinizde repository isimlerinin aşağıdaki ekran çıktısında işaretlenen HTML parçasından alınabileceğini görebilirsiniz. 

    {% include image.html url="/resource/img/JMeterPart2/HtmlSnippetForRepoName.png" description="Html snippet for repo name" %}

    Bir önceki adımda `authenticity_token`ı seçmek için HTML içinde Regex Extractor kullanmıştık ama oradaki senaryoda sadece bir eşleşme yeterli oluyordu. Burada ise kullanıcının birden fazla repository'si olması durumunda Regex'in birden fazla kere eşleşmesi gerekecek. Neyse ki JMeter'ın sağladığı Regex Extractor birden fazla eşleşme için destek vermekte ve bu sonuçlar üzerinde ForEach bileşeni ile dolaşmaya olanak tanımaktadır.

    Öncelikle repo isimlerini listelemek üzere ilgili URL'e GET Request'i yaparak repository'lerin olduğu HTML'leri alacak sampler'ı projeye ekleyelim. Aşağıdaki ekran görüntüsü oluşacak şekilde HTTP Request Sampler'ı test plana ekleyin.

    {% include image.html url="/resource/img/JMeterPart2/GetRepositoriesPage.png" description="Get repositories page" %}

    Bir önceki adımda olduğu gibi HTTP Request Sampler'a Post Processor olarak Regular Expression Extractor ekleyin ve aşağıda gösterildiği şekilde konfigüre edin. Burada bir önceki Extractor'dan farklı olarak `Match No.` olarak `-1` verildiğine dikkat edin. Bir önceki örnekte verilen 1 değeri, Regex Extractor'a ilk eşleşmeyi değişkene atmasını öğütlemişti. Bu örnekteki -1 değeri, eşleşen bütün değerlerin bir liste olarak değişkene atılmasını salık vermektedir.

    {% include image.html url="/resource/img/JMeterPart2/RepositoriesPageRegexExtractor.png" description="Get repositories page regex extractor" %}

    Eşleşen Regex parçalarını görmek için View Results Tree'den önce bir Debug Sampler ekleyin ve testi başlatın. Aşağıdakine benzer bir görüntü elde etmeniz gerekir.

    {% include image.html url="/resource/img/JMeterPart2/RepositoriesPageRegexExtractorDebugSampler.png" description="Get repositories page regex extractor result" %}

    Son olarak aşağıdaki gibi bir ForEach kontrolü ekleyerek Regex ile parse ederek liste olarak bir değişkene attığımız repo isimlerini teker teker işleyebilecek kabiliyette olduğumuzu görelim. `input_variable_prefix` bölümüne Regex Extractor'daki Reference Name'i yani Regex ile eşleşen elemanların bulunduğu liste ismini verelim, `output_variable_name` kısmına ise listedeki her bir elemanın değerinin tutulacağı değişken ismini verelim. Böylece ForEach kontrolü içinde `repository_name` değişkeni ile repository'lerin isimlerine teker teker ulaşabileceğiz.

    {% include image.html url="/resource/img/JMeterPart2/RepositoriesPageForEachController.png" description="Get repositories page foreach controller" %}

    Debug Sampler'ı ForEach kontrolünün içine alarak listenenin üzerinden geçilen elemanının değerinin `repository_name` çıktıda gösterilmesini sağlayın.

    {% include image.html url="/resource/img/JMeterPart2/RepositoriesPageForEachControllerDebugSampler.png" description="Get repositories page foreach controller debug sampler" %}

11. Bir önceki adımı tamamlayarak baştan test etmeyi planladığımız dördüncü fonksiyonu da test etmiş olduk. Beşinci fonksiyon bir önceki adımda sıralanan repository'lerden rastgele seçilen birine ait bütün commit'lerin listelenmesi.

    Bu adımda Regex Extractor ile bir önceki adımda parse ettiğimiz repository isimlerinden birini random olarak seçmemiz gerekiyor. Random olarak bir repo seçebilirsek bir önceki adımda uyguladığımıza benzer adımlarla bu repo'nun commit'lerini bir sonraki adımda sıralayabiliriz.

    JMeter'ın en önemli özelliklerinden bir tanesi de genişletilebilir olmasıdır. JMeter genişletilebilir, hem de Script yazılarak genişletilebilir bir araçtır. JMeter tarafından sağlanan BeanShell Post/Pre Processor'lar ile JMeter Sampler'larda Request yapılmadan önce ve yapıldıktan sonra bütün değişkenlerde Java programlama dilini kullanarak istediğimiz değişiklikleri gerçekleştirebiliriz. Bize verilen görev için yapmamız gereken BeanShell içerisinde bir önceki adımda Regex Extractor ile parse ettiğimiz repo sayısını almak, 0 ile bu repo sayısı arasında rastgele bir seçim yaparak, seçim yaptığımız index'teki repository ismini ileride kullanılmak üzere Thread bazlı değişken olarak yazmaktır.

    Github Repository Sayfası HTTP Sampler'ına aşağıdaki BeanShell PostProcessor'ını üzerinde sağ tıklayarak Add > Post Processors > BeanShell PostProcessor yolu ile ekleyin. Aşağıdaki ekran çıktısında gördüğünüz gibi konfigüre edin.

    {% include image.html url="/resource/img/JMeterPart2/RepositoryBeanShellPostProcessor.png" description="Repository BeanShell Post Processor" %}

    Bu noktada yazdığımız kodu anlamaya çalışalım. Bir önceki adımda eklediğimiz Debug Sampler'ın çıktısının son bölümü aşağıdaki gibiydi. Buradaki `repositories_list_matchNr` değişkeninin Regex'in yaptığı toplam eşleşme sayısı yani repository sayısı olan `7`yi tuttuğunu göreceğiz. Ayrıca eşleşen repository isimlerinin `X` eşleşme index'i olmak üzere `repositories_list_X` formatında olduğuna dikkat edelim.

        ....
        repositories_list_5_g1=Docker-DB-Seed-Sample
        repositories_list_6=Gulp-Sample
        repositories_list_6_g=1
        repositories_list_6_g0=itemprop="name codeRepository">
                Gulp-Sample</a>
        repositories_list_6_g1=Gulp-Sample
        repositories_list_7=SignalR-Sample
        repositories_list_7_g=1
        repositories_list_7_g0=itemprop="name codeRepository">
                SignalR-Sample</a>
        repositories_list_7_g1=SignalR-Sample
        repositories_list_matchNr=7

    Şimdi BeanShell'e yazdığımız kodu satır satır inceleyelim.

    Aşağıdaki kod parçasında JMeter'ın tuttuğu `repositories_list_matchNr` değişkenini BeanShell içerisinde kullanmak üzere alıyoruz, bir anlamda import ediyoruz.

        noOfRepos = vars.get("repositories_list_matchNr");

    Sonra `0` ile `noOfRepos` arasında rastgele bir sayı seçiyoruz. Burada 0 bazlı bir index geleceği ve bize 1 bazlı bir index gerekli olduğu için sonucu 1 artırıyoruz.

        Random rand = new Random();
        int randIndex = rand.nextInt(Integer.parseInt(noOfRepos)) + 1; // bump index by 1
    
    Index'i belirledikten sonra sıra bu index'teki repository'nin ismini tutan variable ismini oluşturmaya ve JMeter'dan bu variable'ın değerini BeanSheel içerisine almaya geliyor.

        // example var: repositories_list_7=SignalR-Sample
        String existingVariableName = "repositories_list_" + randIndex.toString();

        // retrieve randomly selected repo name from the variable
        String randomlySelectedRepo = vars.get(existingVariableName);

    Son adım olarak random olarak seçtiğimiz repo ismini `random_repository_name` adlı değişkene atarak kontrolü tekrar JMeter'a bırakmak üzere BeanShell Script'i bitiriyoruz.

        // add the randomly selected repo to variable list to be used by JMeter
        vars.put("random_repository_name", randomlySelectedRepo);

    Script'i çalıştırdığınızda aşağıdaki gibi siz de random olarak bir repository'nin seçildiği ve `random_repository_name` adlı değişkene atıldığını gözlemlemelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/RepositoryBeanShellPostProcessorDebugOutput.png" description="Repository BeanShell Post Processor Debug Output" %}

12. Bir önceki adımda random olarak bir repository seçmiştik. Şimdi bu repository'deki commit'lerin id'lerini listeleyelim. Dördüncü fonsiyon ile çok büyük benzerlik içerdiği için hızlanma amaçlı olarak bazı kısımları daha az detayla ele alacağız.

    Github'da rastgele seçilen bir repository'de master branch'teki bütün commitlerin listelenmesi için https://github.com/gokhansengun/Owin-Sync-vs-Async-Perf-Test/commits/master URL'ine benzer bir URL kullanılıyor.

    Öncelikle yeri gelmişken yeni bir bilgi öğrenelim. Burada test edeceğimiz Github account'u gokhansengun olmasına rağmen bu başka bir testte değişebilir. Test bazlı olarak belirlemek istediğimiz ve daha önceden öğrendiğimiz CSV dosyasından almak istemediğimiz değişkenler de olabilir. Bu tip değişkenler tanımlamak için JMeter User Defined Variables bileşenini kullanmaktadır. Thread Group üzerinde sağ tıklayarak Add > Config Element > User Defined Variables yolu ile bileşeni plana ekleyerek ilk bileşen olmasını sağlayın. Sonra da aşağıdaki gibi konfigüre edin.

    {% include image.html url="/resource/img/JMeterPart2/UserDefinedVariablesAccountName.png" description="User Defined Variable for Account Name" %}

    Path'i aşağıdaki belirtilen şekilde olacak bir HTTP Request Sampler ekleyin ve testi başlatın. Başarılı bir şekilde commit sayfasını almış olduğunuzu kontrol edin.

    {% include image.html url="/resource/img/JMeterPart2/RetrieveCommitPageForRandomRepo.png" description="Retrieve Commit Page for Random Repository" %}

    Tıpkı onuncu adımda olduğu gibi HTTP Request Sampler'a Post Processor olarak Regular Expression Extractor ekleyerek aşağıdaki HTML içinde belirli bir patern'de bulunan commit id'lerini ayıklayalım.

    Tarayıcının geliştirici araçları ile sayfa incelendiğinde commit id'lerin aşağıdaki HTML snippet'ları ile oluşturulduğu görülebilir.

        <a href="/gokhansengun/Mono-Linux-Interop/commit/892f59423a71122d294046d618516ca7312f5075" class="sha btn btn-outline">
            892f594
        </a>

    Aşağıdaki Regex patern'i ve sonrasında verilen Regular Expression Extractor belirtilen patern'le eşleşecektir.

        <a href="\/${ACCOUNT_NAME}\/${random_repository_name}\/commit\/(\w+?)" class="sha

    {% include image.html url="/resource/img/JMeterPart2/CommitIdsRegexExtractorConfig.png" description="Commit ids Regex Extractor" %}

    Testi çalıştırıp View Results Tree'de extract edilen değerlere baktığınızda rastgele seçilen repository'ye göre aşağıdaki gibi bir görüntü görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/CommitIdsExtracted.png" description="Commit ids Regex Extractor" %}

13. Gerçekleştirmemiz gereken son fonksiyon Github.com'dan çıkış yapılması. Yine tarayıcımızın geliştirici araçlarından network bölümüne bakarak tarayıcıda çıkış yaptığımızda sunucuya gönderilen Request'i görebiliriz.

    Belirtilen adımları uyguladığınızda tek yapmamız gerekenin `/logout` URL'ine bir POST Request'i yapmak olduğunu görebilirsiniz. Yeni bir HTTP Request Sampler ekleyip Path'ini `/logout` ve methodunu POST olarak değiştirin. Github logout adımında da tıpkı login'de olduğu gibi `authenticity_token`'ın POST Request'inde gönderilmesini beklemektedir. `authenticity_token` logout tetiklenmeden önceki son sayfadan alınmalıdır. Github Login Sayfası HTTP Request Sampler'ı altında bulunan Auth Token Extractor'ü Logout'tan önceki son sayfa olan Github Commit Sayfası HTTP Request Sampler'ının altına kopyalayın. Aşağıdaki gibi bir görüntü elde etmelisiniz.

    {% include image.html url="/resource/img/JMeterPart2/LogoutAuthenticityTokenExtractor.png" description="Logout Authenticity Token Extractor" %}

    Son olarak POST Request'i aşağıdaki gibi yapılandırarak testi başlatın. View Results Tree'de bütün adımların başarılı olduğunu gözlemlemeniz gerekmektedir.

    {% include image.html url="/resource/img/JMeterPart2/LogoutPostRequestSampler.png" description="Logout Post Request Sampler" %}

## Doğruluk Testleri

Fonksiyon testlerinde test edilen senaryolarda sunucuya yapılan isteklere verilen cevapların detaylı bir şekilde incelenerek gerçekten beklenen cevapların gelip gelmediği kontrol edilmelidir. Bir önceki blog'da da bahsedilen Assertion'lar doğruluk testlerinin gerçekleştirilmesinde kullanılmaktadır.

### Response Assertion

Assertion'lar Request Sampler'lara eklenerek response'ları farklı açılardan kontrol edebilirler. Assertion'lardan en çok kullanılanı Response Assertion'dır. Response Assertion, ilgili Sampler'ın üzerinde sağ tıklanarak Add > Assertions > Response Assertion menüsünden eklenebilir. Github.com web sitesinin ana sayfasında bulunan "How people build software" text'inin Github ana sayfası istendiğinde gelip gelmediğini test etmek için aşağıdaki gibi bir Response Assertion bileşeni eklenebilir.

Aşağıdaki ekran çıktısında 1 ile gösterilen bölümde response olarak "Main sample only" seçilmiştir, böylelikle sadece Ana Sayfa HTML'inin içeriği test edilecektir. "Main sample and sub-samples" seçilseydi HTML sayfası ile birlikte HTML'den referans edilen JS ve CSS dosyalarının da response'ları test edilecekti. 2 ile gösterilen bölümde "Response Field to Test" olarak "Text Response"ı seçtik ve böylece HTML dosyasının içinde ilgili text'in aranmasını sağladık. "Response Code"u seçerek HTTP response'ın kodunu "Response Headers"ı seçerek de HTTP response header'ına göre test edilmesini sağlayabilirdik. 3 ile gösterilen bölümde 4 ile gösterilen bölümde pattern olarak verilen test'in hangi kritere göre yapılacağı belirtilmiştir. Burada "Contains" seçilerek verilen text'in gelen response'ın içinde olmasının yeterli olduğu ifade edilmiştir.

{% include image.html url="/resource/img/JMeterPart2/MainPageResponseTextAssertion.png" description="Main Page Response Text Assertion" %}

Assertion'ında verilen kriterin tutmadığı durumlarda JMeter'da ilgili Thread'de bir hata oluşturulur. Hata View Results Tree'de kırmızıya boyanır. Önceki blog'da belirtildiği gibi Thread hata aldığında JMeter tarafından alınacak aksiyon, Thread'i durdurma, testi durdurma, devam etme vb olabilir. Fonksiyon testleri için bu parametre Stop Test olarak belirlenmelidir.

Bir önceki örnekte test edilecek patern'e "How people build software" yerine "How build software" yazarak testi çalıştırdığımızda ilgili adımın kırmızıya boyandığını görürüz.

{% include image.html url="/resource/img/JMeterPart2/MainPageResponseTextAssertionFailure.png" description="Main Page Response Text Assertion Failure" %}

### Duration Assertion

Bir miktar performans testi kapsamına giriyor olsa da fonksiyon testlerinde de bazı fonksiyonlar için maksimum response süresi tanımlanabilir. Örneğin login senaryosunun 5 saniyeden fazla sürmesinin kabul edilmediği durumlarda Request Sampler'a Duration Assertion eklenerek Sampler'ın 5 saniyeden fazla sürdüğü durumlarda hata oluşması sağlanır. Login Request'ine 50 milisaniyelik (login için gerekenden az dolayısıyla da Assertion oluşacak) bir Duration Assertion ekleyerek testi çalıştıralım.

{% include image.html url="/resource/img/JMeterPart2/LoginPageDurationAssertionFailure.png" description="Login Page Duration Assertion Failure" %}

Benzer şekilde Size Assertion, gelen response'ın minimum ve maksimum boyutlarının belirlenebileceği bir bileşendir. Mevcut Assertion bileşenleri ile gerçekleştirilemeyecek logic'ler BeanShell Assertion ile Java kodu ile rahatlıkla gerçekleştirilebilir. 

## Sonuç

Bu blog'da JMeter'daki birçok özelliği kullanarak gerçek hayattan karmaşık bir test senaryosunu tamamlamış olduk. Önceki blog'da öğrendiğimiz bileşenlerin demo edilmiş halini görmenin yanında yeri geldikçe yeni bileşenleri de tanıma fırsatı bulduk ve onları da kullanarak konuyu bir bütün olarak ele almaya çalıştık.

Bir sonraki [blog'da](/jmeter-pratik-test-hazirlama/) JMeter'da daha pratik bir biçimde nasıl test senaryoları hazırlanabileceğini göreceğiz.

#### Teşekkür

Bu blog yazısını gözden geçiren ve düzeltmelerini yapan Dr. Mehmet Alper Uslu'ya ([alperuslu.net](http://alperuslu.net/)) teşekkür ederiz.
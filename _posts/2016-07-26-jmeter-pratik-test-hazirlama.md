---
layout: post
title: "JMeter Bölüm 3: Pratik Test Senaryosu Kaydı Nasıl Yapılır?"
level: Orta
progress: finished-not-reviewed
---

[Bir önceki blog yazısında](/jmeter-fonksiyon-testi-hazirlama/) JMeter kullanarak Github'da en çok kullanılan işlemleri bir fonksiyonel test senaryosu haline getirdik. Birçok komponenti bir arada etkili bir şekilde kullanmanın yanında, web uygulamaları için test senaryosu yazımında karşımıza çıkabilecek Cross Site Request Forgery (CSRF) ve başka bazı kavramları da öğrendik. O blog yazısının Yöntem başlığında da söz ettiğimiz gibi aslında JMeter script'lerini daha hızlı ve pratik bir şekilde hazırlamanın başka yolları da var. Bu blog yazısında bu yollardan web uygulamaları için kullanılabilecek en pratik yönteme bir göz atacağız.

JMeter ile önceden bir deneyiminiz yoksa öncelikle aşağıdaki blog yazısını okuyarak başlamanız önerilir. Önceden deneyiminiz varsa bile aşağıda verilen blog yazılarını okumanızda fayda bulunmaktadır.

[JMeter Bölüm 1: Nedir ve Ne İşe Yarar?](/jmeter-nedir-ve-ne-ise-yarar/)

[JMeter Bölüm 2: Fonksiyon Testi Nasıl Hazırlanır?](/jmeter-fonksiyon-testi-hazirlama/)

Bu blog yazısını okuduktan sonra aşağıdaki blog yazılarını da sırasıyla okumanız tavsiye edilir. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyoruz.

[JMeter Bölüm 4: Performans Testi Nasıl Hazırlanır??](/jmeter-performans-testi-hazirlama/)

[JMeter Bölüm 5: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

## Hızlı JMeter Script'i Hazırlama

### Hazırlık

JMeter, web uygulama testlerinde hızlı bir şekilde test senaryosu hazırlanmasına olanak tanımak için Recording Template'ini sunmaktadır. Bu Template'in detaylarına girmeden olayı daha iyi kavramanıza yardımcı olacak bazı bilgileri sizinle paylaşacağız.

#### HTTP Proxy'ler

Web uygulamalarını debug etmek için sıklıkla HTTP Proxy'lerden faydalanılır. Tarayıcıların geliştirici konsollarının son yıllarda oldukça gelişmesi ve birçok fonksiyonu bir arada sunması ile birlikte HTTP Proxy'lerin kullanım oranlarının ciddi miktarda düştüğü gözlemlemektedir. HTTP Proxy'ler temel olarak basit bir şekilde istemci ile sunucu arasına girerek istemciye kendilerini sunucu, sunucuya ise istemci olarak tanıtırlar. Böylelikle ne istemci ne de sunucu aradaki HTTP Proxy'den haberdar olmadan işlevlerini gerçekleştirmeye devam ederler. HTTPS'te durum biraz farklıdır, istemciye sunucu sertifikası yerine HTTP Proxy'nin (örneğin Fiddler'ın) sertifikası sunulacağı için aslında istemci HTTP Proxy kullanıldığında gerçek sunucu ile direkt iletişim kurmadığını anlayabilir. Aradaki bütün trafiği dinleme/kaydetme olanağına kavuşan HTTP Proxy'ler değişik amaçlarla bu bilgileri kullanıcılarına sunabilirler. HTTP Proxy'ler arasıda en çok bilinen ve kullanılanlardan biri olan [Fiddler](http://www.telerik.com/fiddler)'ın bilinen en popüler özelliği istemci ve sunucu arasındaki bütün trafiği dinlemesi ve bir arayüz üzerinden kullanıcılara Request ve response'larla ilgili detaylı bilgiler (zamanlama, içerik, vb) verebilmesidir. Çok bilinen bu özelliğine ek olarak Fiddler, istemciden sunucuya giden Request'leri durdurma, manuel ya da bir script vasıtası ile değiştirdikten sonra sunucuya iletme işlevini de görebilir. Fiddler, benzer şekilde sunucudan gelen response'ların da değiştirilmesine ve istemciye istenen şekilde iletilmesini amacı ile de kullanılabilir.

HTTP Proxy'ler genel olarak sistemin default Proxy'si olarak kendilerini ayarlarlar ve tarayıcılardan yapılan Request'lerin kendi üzerlerinden geçmesini sağlarlar. Bilinirliği yüksek olduğu için yine Fiddler'ı örnek olarak alalım. Fiddler, 8888 nolu TCP portu dinler, açılırken sistemde default Proxy olarak 8888 nolu portu konfigüre ederek 80 (http) ve 443 (https)'e yapılan bütün Request'lerin 8888 nolu port üzerinden geçmesini sağlar. Kapatıldığında ise sistemin default Proxy ayarını eski haline alır ve port yönlendirilmesi (Proxy) olmadan istemci ile sunucunun konuşması arada başka bir node (düğüm) olmadan devam eder.

Fiddler'ın sistemin default Proxy'sini değiştirmesi ve tarayıcı dahil bütün programların HTTP trafiğini yönlendirmesi bazı zamanlar istenen durum olmayabilir. Fiddler, açılışta sistemin default Proxy'sini otomatik değiştirme özelliğini opsiyonel olarak sunar, istenildiğinde bu özellik kapatılabilir. Bu durumda Fiddler açılırken kendi portunu (8888) dinlemeye alır ancak default Proxy ayarına dokunmaz. Trafiğini Fiddler üzerinden geçirmek istediğimiz uygulamalarda (çoğu zaman bu uygulamalar tarayıcılardır) Proxy ayarı olarak Fiddler'ın ilgili portu konfigüre edilir ve trafik akışını izlemek mümkün olur.

#### JMeter Recording Template

JMeter'ın sunduğu Recording Template aslında bir HTTP Proxy kullanmaktadır. JMeter Recording bileşeni bir HTTP Proxy başlatarak dinlediği porta Request'ler yapılmasını beklemekte ve Request'ler geldikçe bu Request'leri işleyerek JMeter HTTP Request Sampler ve Config Element'ler olarak hazırlamaktadır. JMeter Recording bileşeni başlatıldıktan sonra test koşulacak tarayıcıda JMeter Recording bileşeninin dinlediği IP (genelde localhost) ve port (8888) Proxy server olarak ayarlanır ve ilgili senaryo tarayıcıdan çalıştırılarak senaryonun JMeter tarafından kaydedilmesi sağlanır.

#### Yöntem

Önceki blog'larda JMeter'ın 2.13 versiyonunu kullanmıştık. Bu blog'da ise 3.0 versiyonunu kullanacağız. Görsel arayüzde 2.13 ve 3.0 arasında bazı ciddi farklar bulunmakla birlikte fonksiyon olarak bizim ilk iki blog'da kullandığımız ve bu blog'da kullanacağımız fonksiyonlar açısından pek bir fark bulunmamaktadır.

Bu blog'da kullanacağımız Recording Template 2.13'ten önceki versiyonlarda bulunmadığı için adımları takip edebilmek için minimum 2.13 versiyonunu kullanmalısınız.

Sadece yöntem farklılığına odaklanmak açısıdan [bir önceki blog'da](/jmeter-fonksiyon-testi-hazirlama/) kullandığımız örneğin (Github.com web uygulamasının testi) birkaç adımını tekrarlayacağız. 

#### Test Edilecek Fonksiyonlar

Bu blog yazısında test edeceğimiz fonksiyonlar aşağıdaki gibi olacak.

1. Github.com'un ana sayfasının çekilmesi.
2. Github.com'un login sayfasının çekilmesi.
3. Kullanıcı adı ve parola ile Github.com'a giriş yapılması.
4. Repository'lerin listelendiği sayfaya giriş yapılması
5. Github.com'dan çıkış yapılması.

### Adımlar

1. JMeter programını açtıktan sonra File > Templates menüsünden JMeter'ın bize sunduğu Template'ların listesine ulaşabiliriz. Siz de aşağıdakine benzer bir ekran görüntüsüne sahip olmalısınız.

    {% include image.html url="/resource/img/JMeterPart3/TemplateList.png" description="List of Templates" %}

    Görüldüğü gibi JMeter, Recording'in yanında birçok başka Template de sunmaktadır. Sıfırdan bir test plan oluşturmak yerine bu planlardan birinden başlamak akıllıca olacaktır. Biz Recording Template'ini seçerek ilerleyelim. Recording with Think Time Template'i adından da anlaşılabileceği gibi senaryoyu browser'da kaydederken mouse tıklamaları ve klavye girdileri arasındaki süreleri de test plana eklemektedir. Yük ve performans testi hazırlarken Think Time'la kayıt yapılması daha gerçekçi bir senaryo oluşturmamızı sağlayacaktır. Think Time ile ilgili detaylı bilgi [ilk blog'da](/jmeter-nedir-ve-ne-ise-yarar/) bulunabilir.

2. Recording Template aşağıdakine ekran görüntüsüne benzer bir Test Plan'ı hazır hale getirecektir. Test Plan'ı kaydedin.

    {% include image.html url="/resource/img/JMeterPart3/TestScriptRecorderComponent.png" description="Test Script Recorder Component" %} 

    1 ile gösterilen bölümde HTTP Proxy'nin dinleyeceği port 8888 olarak konfigüre edilmiştir. İsterseniz bu değeri değiştirebilirsiniz. Testi hazırlayacağınız bilgisayarda bu portta başka bir uygulamanın halihazırda çalışıyor olması durumunda bu değeri kesinlikle değiştirmeniz gerekli olacaktır. 2 ile gösterilen bölümde tarayıcının yaptığı isteklerin JMeter tarafından nasıl gruplanacağı konfigüre edilmektedir. Genel olarak seçili bulunan default değer daha yönetilebilir testler oluşturmasını sağlamaktadır. 3 ile gösterilen bölümde kayıt sırasında dahil etmek istemediğimiz URL pattern'lerini dahil edebiliriz. Yukarıdaki örnekte Template'in; bmp, css, js, jpeg, png ve font dosyalarını kaydetmemesi için gerekli konfigürasyon yapılmıştır. Eğer bu dosyalar için yapılan Request'lerin de test plana dahil olmasını isterseniz bu konfigürasyonu silmeniz gerekmektedir. 4 ile gösterilen bölümde JMeter'ın bütün HTTPS Request'ler yerine sadece test yapacağımız siteye (bizim için github.com) yapılan Request'leri kaydetmesini sağlamak için bir pattern girerek başka sitelerden gelen trafiğin test planına girmesini engellemiş oluruz. 5 ile gösterilen bölümdeki Capture HTTP Headers seçimi ile HTTP Header'ların Request bazlı olarak kaydedilmesi sağlanır. Bu sayede tarayıcının yaptığı Cache vb tercihleri rahatlıkla tekrarlamış oluruz. 6 ile gösterilen bölümdeki "Add Assertions" seçimi ile her bir Request'ten sonra bir Response Assertion otomatik olarak eklenir. Böylece kayıt sonrasında bu Assertion'ları doldurmak istediğimizde bize kolaylık sağlanmış olur.

3. Geçen blog'umuzda Mozilla Firefox kullanmıştık. Bu blog'da Google Chrome kullanalım. Ayrıca ayarların Windows için nasıl yapıldığını gösterelim. Chrome tarayıcıyı açarak adres çubuğunda `chrome://settings/` yazın ve ayarlar sayfasına erişin.

    Aşağıda gösterildiği gibi gelişmiş ayarları seçerek ağ ayarlarına ulaşın.

    {% include image.html url="/resource/img/JMeterPart3/ChromeSetupProxyPart1.gif" description="Chrome network settings part 1" %} 

    Ağ ayarlarında Proxy sunucusu olarak 127.0.0.1 (localhost) ve port olarak JMeter'ın dinlemeye başladığı 8888 portunu seçin. 

    {% include image.html url="/resource/img/JMeterPart3/ChromeSetupProxyPart2.gif" description="Chrome network settings part 2" %} 

4. İkinci adımda verilen şekilde detayları görülen Test Script Recorder bileşeninin en altında bulunan `start` butonuna basarak JMeter'ın 8888 portuna gelen isteklerini dinlemeye başlamasını sağlayın. Aşağıdaki gibi bir uyarı mesajı görmeniz gerekir. 

    {% include image.html url="/resource/img/JMeterPart3/NeedToInstallJMeterCertificateWarning.png" description="Warning: Need to install JMeter certificate" %} 

    JMeter, HTTPS Request'lerini de dinleyebilmek için bir Private Key ile birlikte bu Private Key'in Public Key'ini içeren bir Self-Signed sertifikayı issue ederek JMeter klasörünün altında bulunan `bin` klasörüne kopyalamıştır. Private Key, Public Key ve sertifika meseleleri konumuzun dışında olduğu için detaylı olarak ele almayacağız fakat ilerleyen blog'lardan birinin konusu olabilir. Bu blog'da sadece JMeter ile Recording yapabilmeye imkan tanıyacak derecede bu konular ile ilgili bilgi sahibi olmamız yeterli olacaktır.

5. Bu adımda yapmamız gereken, JMeter'ın ürettiği sertifika dosyasını bilgisayarımızda bulunan Root Certificate Authority'lerin arasına eklemek ve bilgisayarımızın dolayısıyla da kullandığımız tarayıcının JMeter'ın ürettiği sertifikaya güvenmesini ve bu sayede de tarayıcının JMeter ile 8888 numaralı port üzerinden konuşurken hata almamasını sağlamaktır. JMeter'ın kurulu olduğu dizinin altındaki `bin` klasörüne giderek `ApacheJMeterTemporaryRootCA.crt` dosyasına çift tıklayın ve aşağıdaki animasyonda gösterilen adımları takip edin.

    {% include image.html url="/resource/img/JMeterPart3/InstallSelfSignedCertificate.gif" description="Chrome network settings part 2" %}

    Siz de aşağıdakine benzer bir çıktı görmelisiniz.

    {% include image.html url="/resource/img/JMeterPart3/GithubRecordedHttpSamplers.png" description="Recorded Http Samplers" %} 

6. Elimizde testini hazırlamak istediğimiz senaryo için HTTP Sampler Request ve diğer elemanlar bulunan bir senaryo var artık. Bu senaryoyu JMeter'da olduğu gibi çalıştırırsak `/session` ve `/logout` Request'lerinin hata aldığını göreceksiniz. Bir önceki blog'da da bize ekstra iş çıkaran Cross Site Request Forgery (CSRF) önlemleri burada da karşımıza çıkıyor. Bir önceki blog'un dokuzuncu adımında yaptığımız gibi burada da hata alan POST Request'lerden önce çağrılan, POST Request'lerin yapıldığı (GET Request'leri ile alınan) sayfaların kaynağından Regular Expression Extractor ile `authenticity_token`'ı alıp bir değişkene atıp POST Request'lerde kullanmamız gerekecektir.

    Bir önceki ekran görüntüsünde bulunan `149 /login` GET Request'ine bir önceki blog'un dokuzuncu adımında yaptığımız ve bir önceki paragrafta özetlediğimiz işlemleri yapalım. Login Request'ine Post Processor olarak eklenen Regular Expression Extractor aşağıda verilmiştir.

    {% include image.html url="/resource/img/JMeterPart3/LoginRegularExpressionExtractor.png" description="Login Regular Expression Extractor" %} 

    Extract edilen değişken'in `154 /session` çağrısına nasıl beslendiğini aşağıdaki ekran çıktısından görebilirsiniz. JMeter ile kaydedilen diğer parametrelerin aksine `authenticity_token` için `Encode?` kolonunu işaretlediğimize dikkat edin. JMeter Request'lerdeki parametreleri zaten encode edip kaydettiği için o parametrelerde encode seçilmemiştir bizim extract ettiğimiz değişkende ise seçilmiştir. 

    {% include image.html url="/resource/img/JMeterPart3/LoginFeedExtractedAuthenticityToken.png" description="Login Give Extracted Authenticity Token" %}

7. Bir önceki adımda `/session` yani login için yaptığımız işlemleri `/logout` için de yapmamız gereklidir. Logout butonuna basmadan önce girdiğimiz son sayfadaki `authenticity_token`'ı kullanarak POST Request'ine vermemiz gerekiyor. Kayıt sırasında son olarak `repositories` tabına tıkladık fakat repository tabına tıklamamız sunucuya yeni bir istek göndermediği için `authenticity_token`'ı bir önceki Request'ten almamız gerekiyor. Yaptığımız kayıt dosyasındaki `166 /gokhansengun` GET Request'ine aynı şekilde bir Extractor ekleyip değişkene attığımız değeri `/logout` çağrısında kullanabiliriz.

    Regular Expression Extractor aşağıda verilmiştir.

    {% include image.html url="/resource/img/JMeterPart3/LogoutRegularExpressionExtractor.png" description="Logout Regular Expression Extractor" %} 

    POST Request'e beslenme şeklinde yine `Encode?` kolonunun seçili olmasına dikkat ediniz.

    {% include image.html url="/resource/img/JMeterPart3/LogoutFeedExtractedAuthenticityToken.png" description="Logout Give Extracted Authenticity Token" %}

8. Bu adımda test script'i çalıştırabilir ve testin başarı ile sonuçlandığını gözlemleyebilirsiniz.

JMX dosyasının son haline Github parolam haricinde [buradan](/resource/file/JMeterPart3/Github Recording.jmx) ulaşabilirsiniz. JMX dosyasını bu haliyle (parola değiştirildiği için) direkt olarak çalıştıramayacak olsanız bile inceleme amacı ile kullanabilirsiniz. 

## Sonuç

Bu blog'da JMeter'ın Recording Template'ini kullanarak bir önceki blog'da elle uzun uğraşlar sonucu hazırladığımız karmaşık test senaryosunun aynısını daha pratik bir şekilde tamamlamış olduk.

Bir sonraki [blog'da](/jmeter-performans-testi-hazirlama/) JMeter'la nasıl performans testi hazırlayabileceğimizi göreceğiz.
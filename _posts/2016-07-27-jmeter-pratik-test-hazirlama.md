---
layout: post
title: "JMeter Bölüm 3: Pratik Test Senaryosu Kaydı Nasıl Yapılır?"
level: Orta Düzey
---

[Bir önceki blog yazısında](/jmeter-fonksiyon-testi-hazirlama/) JMeter kullanarak Github'da en çok kullanılan işlemleri bir fonksiyonel test senaryosu haline getirdik. Birçok komponenti bir arada etkili bir şekilde kullanmanın yanında web uygulamaları için test senaryosu yazımında karşımıza çıkabilecek Cross Site Request Forgery (CSRF), vb başka bazı genel bilgiler de öğrendik. O blog yazısının Yöntem başlığında da söz ettiğimiz gibi aslında JMeter script'lerini daha hızlı ve pratik bir şekilde hazırlamanın başka yolları da var. Bu blog yazısında bu yollardan web uygulamaları için kullanılabilecek en pratik yönteme bir göz atacağız.

JMeter ile önceden bir deneyiminiz yoksa öncelikle aşağıdaki blog yazılarını okuyarak başlamanızı öneririm. Önceden deneyiminiz varsa bile aşağıda verilen blog yazılarını okumanızda fayda olduğunu düşünüyorum. 

[JMeter Bölüm 1: Nedir ve Ne İşe Yarar?](/jmeter-nedir-ve-ne-ise-yarar/)

[JMeter Bölüm 2: Fonksiyon Testi Nasıl Hazırlanır?](/jmeter-fonksiyon-testi-hazirlama/)

Bu blog yazılarını okuduktan sonra ise aşağıdaki blog yazısına da göz atmanızı tavsiye ederim. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı ümit ediyorum.

[JMeter Bölüm 4: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

## Hızlı JMeter Script'i Hazırlama
___

### Hazırlık

JMeter, web uygulama testlerinde hızlı bir şekilde test senaryosu hazırlanmasına olanak tanımak için Recording template'ini sunmaktadır. Bu template'in detaylarına girmeden olayı daha iyi kavramanıza yardımcı olacak bazı bilgileri sizinle paylaşacağım.

#### HTTP Proxy'ler

Web uygulamalarını debug etmek için sıklıkla HTTP Proxy'lerden faydalanılır. Tarayıcıların geliştirici konsollarının son yıllarda oldukça gelişmesi ve birçok fonksiyonu bir arada sunması ile birlikte kullanım oranlarının ciddi miktarda düştüğünü gözlemlemekteyim. HTTP Proxy'ler temel olarak basit bir şekilde istemci ile sunucu arasına girerek istemciye kendilerini sunucu, sunucuya ise istemci olarak tanıtırlar. Böylelikle ne istemci ne de sunucu aradaki HTTP Proxy'den haberdar olmadan işlevlerini gerçekleştirmeye devam ederler. HTTPS'te durum biraz farklıdır, istemciye sunucu sertifikası yerine Fiddler'ın sertifikası sunulacağı için aslında istemci HTTP Proxy kullanıldığında gerçek sunucu ile direkt iletişim kurmadığını anlayabilir. Aradaki bütün trafiği dinleme/kaydetme olanağına kavuşan HTTP Proxy'ler değişik amaçlarla bu bilgileri kullanıcılarına sunabilirler. HTTP Proxy'ler arasıda en çok bilinen ve kullanılanlardan biri olan [Fiddler](http://www.telerik.com/fiddler)'ın bilinen en popüler özelliği istemci ve sunucu arasındaki bütün trafiği dinlemesi ve bir arayüz üzerinden kullanıcılara request ve response'larla ilgili detaylı bilgiler (zamanlama, içerik, vb) verebilmesidir. Çok bilinen bu özelliğine ek olarak istemciden sunucuya giden request'leri durdurma, manuel ya da bir script vasıtası ile değiştirme sonra sunucuya iletme işlevi de görebilir. Fiddler, benzer şekilde sunucudan gelen response'ların da değiştirilmesine ve istemciye istenen şekilde iletilmesini amacı ile de kullanılabilir.

HTTP Proxy'ler genel olarak sistemin default proxy'si olarak kendilerini set ederler ve tarayıcılardan yapılan request'lerin kendi üzerlerinden geçmesini sağlarlar. Bilinirliği yüksek olduğu için yine Fiddler'ı örnek olarak alalım. Fiddler, 8888 nolu TCP portu dinler, açılırken sistemde default proxy olarak 8888 nolu portu set ederek 80 (http) ve 443 (https)'e yapılan bütün request'lerin 8888 nolu port üzerinden geçmesini sağlar. Kapatıldığında ise sistemin default proxy ayarını eski haline alır ve port yönlendirilmesi (proxy) olmadan istemci ile sunucunun konuşması arada başka bir node (düğüm) olmadan devam eder.

Fiddler'ın sistemin default proxy'sini değiştirmesi ve tarayıcı dahil bütün programların HTTP trafiğini yönlendirmesi bazı zamanlar istenen durum olmayabilir. Fiddler, açılışta sistemin default proxy'sini otomatik değiştirme özelliğini opsiyonel olarak sunar, istenildiğinde kapatılabilir. Bu durumda Fiddler açılırken kendi portunu (8888) dinlemeye alır ancak default proxy ayarına dokunmaz. Trafiğini Fiddler üzerinden geçirmek istediğimiz uygulamalarda (çoğu zaman bu uygulamalar tarayıcılardır) proxy ayarı olarak Fiddler'ın ilgili portu konfigüre edilir ve trafik akışını izlemek mümkün olur.

#### JMeter Recording Template

JMeter'ın sunduğu Recording template aslında bir HTTP Proxy kullanmaktadır. JMeter Recording bileşeni bir HTTP Proxy başlatarak dinlediği porta request'ler yapılmasını beklemekte ve request'ler geldikçe bu request'leri kaydedip JMeter HTTP Request Sampler ve Config Element'ler olarak hazırlamaktadır. JMeter Recording bileşeni başlatıldıktan sonra test koşulacak tarayıcıda JMeter Recording bileşeninin dinlediği IP (genelde localhost) ve port (8888) proxy server olarak ayarlandığında ilgili senaryo tarayıcıdan çalıştırılarak senaryonun JMeter tarafından kaydedilmesi sağlanmaktadır.

#### Yöntem

Önceki blog'larda JMeter'ın 2.13 versiyonunu kullanmıştık. Bu blog'da ise 3.0 versiyonunu kullanacağız. Görsel arayüzde 2.13 ve 3.0 arasında bazı ciddi farklar bulunmakla birlikte fonksiyon olarak bizim ilk iki blog'da kullandığımız ve bu blog'da kullanacağımız fonksiyonlar açısından pek fark bulunmamaktadır.

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

1. JMeter programını açtıktan sonra File > Templates menüsünden JMeter'ın bize sunduğu template'ların listesine ulaşabiliriz. Aşağıya benim ekranımda çıkan görüntüyü aldım.

    {% include image.html url="/resource/img/JMeterPart3/TemplateList.png" description="List of Templates" %}

    Görüldüğü gibi template'ler Recording'in yanında birçok başka template de bulumaktadır. Sıfırdan bir test plan oluşturmak yerine bu planlardan birinden başlamak akıllıca olacaktır. Biz Recording template'ini seçerek ilerleyelim. Recording with Think Time template'i adından da anlaşılabileceği gibi senaryoyu browser'da kaydederken mouse tıklamaları ve klavye girdileri arasındaki süreleri de test plana eklemektedir. Yük ve performans testi hazırlarken Think Time'la kayıt yapılması daha gerçekçi bir senaryo oluşturmamızı sağlayacaktır. Think Time ile ilgili detaylı bilgi [ilk blog'da](/jmeter-nedir-ve-ne-ise-yarar/) bulunabilir.

2. Recording template aşağıdakine ekran görüntüsüne benzer bir Test Plan'ı hazır hale getirecektir. Test Plan'ı kaydedin ve aşağıda detayları verilen Test Script Recorder bileşeninin en altında bulunan `start` butonuna basarak JMeter'ın 8888 portuna gelen isteklerini dinlemeye başlamasını sağlayın.

    {% include image.html url="/resource/img/JMeterPart3/TestScriptRecorderComponent.png" description="Test Script Recorder Component" %} 

    1 ile gösterilen bölümde HTTP Proxy'nin dinleyeceği port 8888 olarak konfigüre edilmiştir. İsterseniz bu değeri değiştirebilirsiniz. Testi hazırlayacağınız bilgisayarda bu portta başka bir uygulamanın halihazırda çalışıyor olması durumunda bu değeri kesinlikle değiştirmeniz gerekli olacaktır. 2 ile gösterilen bölümde tarayıcının yaptığı isteklerin JMeter tarafından nasıl gruplanacağı konfigüre edilmektedir. Genel olarak seçili bulunan default değer daha yönetilebilir testler oluşturmasını sağlamaktadır. 3 ile gösterilen bölümde kayıt sırasında dahil etmek istemediğimiz URL pattern'lerini dahil edebiliriz. Yukarıdaki örnekte template, bmp, css, js, jpeg, png ve font dosyalarının kaydedilmemesi için gerekli konfigürasyon yapılmıştır. Eğer bu dosyalar için yapılan request'lerin de test plana dahil olmasını isterseniz bu konfigürasyonu silmeniz gerekmektedir. 

3. Geçen blog'umuzda Mozilla Firefox kullanmıştık. Bu blog'da Google Chrome kullanalım. Ayrıca ayarların Windows için nasıl yapıldığını gösterelim. Chrome tarayıcıyı açarak adres çubuğunda `chrome://settings/` yazın ve ayarlar sayfasına erişin.

    Aşağıda gösterildiği gibi gelişmiş ayarları seçerek ağ ayarlarına ulaşın.

    {% include image.html url="/resource/img/JMeterPart3/ChromeSetupProxyPart1.gif" description="Chrome network settings part 1" %} 

    Ağ ayarlarında proxy sunucusu olarak 127.0.0.1 (localhost) ve port olarak JMeter'ın dinlemeye başladığı 8888 portunu seçin. 

    {% include image.html url="/resource/img/JMeterPart3/ChromeSetupProxyPart2.gif" description="Chrome network settings part 2" %} 


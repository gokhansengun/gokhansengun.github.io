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

#### Test Edilecek Fonksiyonlar

Github.com bir blog yazısında fonksiyonel olaral test edilemeyecek kadar fazla fonksiyon içermektedir. Bu blog yazısında test edeceğimiz fonksiyonlar aşağıdaki gibi olacak.

1. Github.com'un ana sayfası ve ana sayfası altında referans verilen bütün imaj, css ve js dosyalarının çekilmesi.
2. Github.com'un login sayfası ve yine bu sayfadaki bütün resource dosyalarını çekilmesi.
3. Kullanıcı adı ve parola ile Github.com'a giriş yapılması.
4. İlgili kullanıcının bütün repository'lerinin listelenmesi.
5. Rastgele seçilen bir repository'deki bütün commit'lerin listelenmesi.
6. Seçilen bir commit'in comment kısmının okunması.
7. Github.com'dan çıkış yapılması.

#### Yöntem

JMeter'da test senaryosu hazırlamak için test edeceğimiz senaryoyu öncelikle bir web browser'da (tarayıcı) test edip yapılan request'leri tarayıcımızın geliştirici araçları veya Fiddler, Burp Suite gibi Web Debugging Proxy araçları ile yakalayıp aynı düzende ve sırada JMeter'da konfigüre etmemiz gereklidir. Bu yönteme alternatif ve daha pratik olarak JMeter tarafından sağlanan ve tarayıcıdan yapılan bütün request'lerin JMeter üzerinden geçirilmesi (JMeter'ın proxy olarak kullanılması) sağlanarak kaydedilen request'ler düzenlenmek sureti ile de JMeter test senaryosu hazırlanabilir. İlk methodu anlamadan ikinci methodu etkili kullanmak pek mümkün olmadığı için ben test edilecek 7 fonksiyonun ilk 3 adımını ilk yöntemle son 4 adımını ise ikinci yöntemle yapmayı planladım.

### Adımlar

1. JMeter'da yeni bir Test Plan oluşturarak adını "Github Functional Test" olarak belirleyin ve Test Plan'ı kaydedin. Aşağıdaki gibi bir ekran görüntüsü görmelisiniz.

    ![New Test Plan](/resource/img/JMeterPart2/CreateANewTestPlan.png "New Test Plan")

2. Test Plan üzerinde sağ tıklayarak Add > Threads (Users) > Thread Group menüsünü izleyerek yeni bir Thread Group ekleyin. Thread Group'un ismini istediğiniz gibi güncelleyerek "Action to be taken after a Sampler error" bölümünden "Stop Test"i seçin, böylece adımların herhangi birinde bir hata oluştuğunda testin diğer adımları koşturulmaz ve test sonlandırılır. Fonksiyonel test koşturduğumuz için Test Plan'ın hiçbir hata olmadan koşturulması gerekecektir. Değişikliği yaptıktan sonra aşağıdakine benzer bir ekran görüntüsü görmelisiniz.

    ![New Thread Group](/resource/img/JMeterPart2/CreateANewThreadGroup.png "New Thread Group")

3. Thread Group üzerinde sağ tıklayarak aşağıdaki bileşenleri ekleyin. 
    * Add > Config Element > HTTP Request Defaults
    * Add > Config Element > HTTP Cookie Manager
    * Add > Config Element > HTTP Cache Manager

    HTTP Request Defaults, Test Plan'ımıza ekleyeceğimiz bütün HTTP Request'lerde geçerli olacak default değerleri belirlememize yardımcı olacak. HTTP Request Defaults bileşenini açarak "Server Name or IP" bölümüne "github.com", Protocol [http] bölümüne ise "https" yazın.

    HTTP Cookie Manager, JMeter'ın web sunucudan gönderilen cookie'leri almasını ve sonraki request'lerde web sunucuya göndermesini sağlayacaktır.

    HTTP Cache Manager, JMeter'ın web sunucu tarafından HTTP header'da set edilen cache direktiflerine uymasını ve cache kontrolü bakımından bir browser gibi davranmasını sağlayacaktır. Örneğin, ilk request sonucunda sunucudan çekilen bir JavaScript dosyası server tarafından bir saat boyunca cache'lenebilir olarak ifade edilmişse JMeter tarafından ikinci request'te aynı JavaScript dosyasının gerekli olduğu durumda sunucudan istenmeyecek ve lokal olarak cache'lenen versiyon kullanılacaktır. Bu da testin gerçeğe yakın olmasını sağlayacaktır. Eğer testi HTTP Cache Manager kullanmadan yaparsak normal senaryoda browser tarafından cache'lendiği için sunucudan istenmeyen kaynaklar JMeter tarafından istenecek ve sunucu açısından test koşullarının normal koşullardan daha zor olmasına ve testin gerçeklikten uzaklaşmasına neden olacaklardır.

    Aşağıdaki gibi bir görüntüsü görmelisiniz.

    ![Add Http Config Elements](/resource/img/JMeterPart2/AddHttpConfigElements.png "Add Http Config Elements")

4. TODO: gseng - continue from here!
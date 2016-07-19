---
layout: post
title: "JMeter Bölüm 1: Nedir ve Ne İşe Yarar?"
level: Başlangıç
---

Bu blog yazımda Apache Software Foundation (Apache Yazılım Vakfı) tarafından geliştirilmekte olan JMeter uygulaması ile ilgili genel bilgiler vermeye çalışacağım. Bu blog'da kısaca tanıtılacak olan JMeter'i, sonraki iki blog'da detaylı olarak işlemeye çalışacağım. JMeter uygulamasının kullanım alanları ile birlikte sağladığı farklı bileşenleri ekran görüntüleri ile birlikte paylaşarak siz okuyucuların kafasında net bir JMeter imajı oluşturmaya çabalayacağım.

Bu blog yazısını okuduktan sonra aşağıdaki iki blog yazısını da sırasıyla okumanızı tavsiye ederim. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyorum.

[JMeter Bölüm 2: Performans Testi Nasıl Yapılır?](/jmeter-performans-testi/)

[JMeter Bölüm 3: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

Şimdi isterseniz ufaktan başlayalım.

## JMeter Nedir?
___

JMeter başlangıçta web uygulamalarının test edilebilmesi için tasarlanmış fakat sonrasında farklı test fonksiyonlarını gerçekleştirecek şekilde geliştirilmiştir.

JMeter web uygulamalarında html, resim, css ve js gibi statik dosyaları test edebilmenin yanı sıra SOAP ve REST bazlı içeriği dinamik olarak üretilen web servisleri test etme amaçlı olarak da kullanılabilir. Gerçek kullanıcıların bir web uygulamasını kullanırken sunuculardan talep ettikleri kaynaklar JMeter yardımı ile sanki gerçek kullanıcılar bu kaynakları talep ediyormuşcasına simüle edilir. JMeter ile simüle edilen kullanıcı senaryoları (kullanıcıların web uygulamasını kullanma şekilleri), web uygulamasının isteği girdiler (input) farklılaştırılarak sanki birden fazla kullanıcı aynı anda aynı senaryoyu çalıştırıyormuş gibi simüle edilir ve sistemde istenen büyüklükte bir yük oluşturulabilir. Bir kullanıcı senaryosu oluşturma ve bir kullanıcı için oluşturulan senaryonun farklı kullanıcılar oluşturacak şekilde hazırlanmasını, yani JMeter'ın temel fonksiyonu diyebileceğimiz özelliği, ilerleyen bölümlerde bir demo olarak gösterip pekiştirmenizi sağlamaya çalışacağım.

JMeter %100 Java ile yazılan bir araç olduğu için Java Runtime Environment (JRE) veya Java Development Environment (JDK) kurulu olmak kaydı ile Windows, Linux veya Mac işletim sistemine sahip herhangi bir bilgisayarda problemsiz çalıştırılabilmektedir. Ben bu blog yazısında Mac OS X işletim sistemi kurulu bir bilgisayar kullanacağım ve ekran görüntülerini Mac OS X işletim sisteminde alacağım fakat siz herhangi bir işletim sisteminde adımları takip edebilirsiniz. GUI'nin Java olması ve görünümün platformdan platforma pek fazla farklılık göstermemesinin adımları takip ederken işinizi kolaylaştıracağını düşünüyorum.

JMeter kurulumu çok iyi bir şekilde dokümante edildiği ve blog'umuzu uzatacağı için burada yer vermek istemiyorum. JMeter kurulumu için platformunuza göre [bu linkten](http://jmeter.apache.org/usermanual/get-started.html#install) yardım alabilirsiniz.

## Çalışma Özeti ve Yöntem
___

Aşağıdaki adımları tamamlayarak JMeter hakkında genel anlamda fikir sahibi olarak hangi amaçlarla kullanıldığını anlamaya çalışacağız.

* JMeter GUI (Graphical User Interface - Grafik Kullanıcı Arayüzü), JMeter terminolojisi ve performans testi terminolojisi ile ilgili bilgiler vererek JMeter dilinde ve test konseptinde konuşmayı öğreneceğiz.
* Basit bir kullanıcı senaryosunu script ile yazarak bir kullanıcı için koşturacağız.
* Hazırladığımız senaryoyu farklı kullanıcılar için farklı input'lar verecek şekilde ayarlayıp küçük çaplı bir performans testi yapacağız.
* Performans testimizle ilgili grafik çıktıları alacağız farklı şartlarda yük testini tekrarlayacak ve değişimi grafikteki değişikliği göreceğiz.

## Test ve JMeter Terminolojisi
___

Bu blog ve sonraki iki blog'da aynı dili konuşabilmek için test ve JMeter terminolojisine hakim olmamız gereklidir. Bu bölümde teorik olarak açıklayacağım bazı kavramlar konunun daha iyi anlaşılmasını diğer bir kısmı ise JMeter bileşenlerinin kullanım alanlarının öğrenilmesini sağlayacaktır. Ayrıca bu bölümde yer verilen JMeter bileşenlerini ilerleyen bölümlerde demo'larda kullanacak ve daha iyi anlayacağız.

### Test Çeşitleri

#### Fonksiyon Testi



## JMeter GUI
___

Başlangıç yapabilmemize olanak tanıyacak kadar JMeter kullanıcı arayüzüne kısa bir bakış atarak başlayalım.

![JMeter GUI](/img/blog/JMeterPart1/JMeterGuiDefault.png "JMeter GUI")

Yukarıdaki şekilde yeni bir JMeter test planı hazırlanmak üzere JMeter programı komut satırından başlatılmıştır. Görüleceği üzere 1 oku ile gösterilen bölümde Test Plan bulunmaktadır. Bu bölümde hiyerarşik olarak test plan adımları bir ağaç yapısı şeklinde sıralanacak ve JMeter tarafından koşturulacaktır. 

Kullanıcı senaryolarını daha gerçekçi olarak test edebilmek için JMeter farklı adımlar arasında belirli süre beklemek üzere Timer kullanılmasına izin vermektedir. Örneğin formu submit etmeden kullanıcının formu doldurması için geçecek süreyi bir Timer ile simüle edebilirsiniz. 2 oku ile gösterilen "Oynat" butonları Test Plan'ın koşturulmaya başlanmasını sağlanmaktadır. Sol taraftaki "Oynat" butonuna basıldığında JMeter, Test Plan'ın arasına serpiştirilmiş olan Timer'ları dikkate alacak şekilde testi başlatacaktır. Sağ taraftaki Play butonu ise ilgili Timer'ları dikkate almadan testi başlatacaktır.

JMeter sunduğu geniş component setinin yanı sıra çok güçlü data toplama ve raporlama araçlarına sahiptir. Performans/yük testi yapılırken koşturumlar arasında sistemden alınan performans metriklerinin görülmesi, raporlanması ve saklanması kritiktir. JMeter data toplanması işlevi için bir önceki bölümde detaylı olarak ele aldığımız ve sonraki bölümlerde demo edeceğimiz pek çok Listener sağlamaktadır. 3 oku ile gösterilen "Süpürge" butonlarından sol tarafta olanına iki test koşturumu arasında basıldığında o anda ekranda görülen listener'da biriktirilmiş olan dataset'i sıfırlar. Sağ tarafta bulunan Süpürge butonu ise Test Plan'da bulunan bütün dataset'leri sıfırlar.

JMeter'da gerçek kullanıcıları simüle eden sanal kullanıcılar Thread Group olarak adlandırılırlar. Bir Test Plan'ın farklı aşamalarında farklı sayıda kullanıcı veya farklı girdi set'leri kullanman isteyebiliriz. Dolayısıyla farklı kullanıcı senaryolarını aynı Test Plan'da test etmek üzere bir Test Plan'da birden fazla Thread Group konumlandırılabilir. 4 oku ile gösterilen bölümde bu Thread Group'lar ile ilgili konfigürasyonlar verilmiştir. "Run Thread Groups consecutively"ın seçilmesi ile Test Plan'daki Thread Group'lar paralel koşturulmanın aksine ardı ardına koşturulur. 

JMeter, Thread Group'ların çalıştırılmaya başlamasından önce Thread Group'un doğru bir biçimde koşturulabilmesi için gerekli ön ayarlamaların yapılmasına imkan tanıyan "setUp Thread Group"lar ve Thread Group'un işi bittikten sonra gerekli kaynak temizleme işlemlerinin yapılabileceği "tearDown Thread Group"lar sağlamaktadır. "Run tearDown Thread Groups after shutdown of main threads" ayarı seçildiğinde "tearDown Thread Group"lar sadece Threa Group'ların başarılı koşturumlarından sonra çalıştırılırlar fakat Test Plan koşturum devam ederken durdurulursa çalıştırılmazlar. 

"Functional Test Mode" ayarı seçildiğinde ise JMeter herbir test adımında Sampler'ların request ve response'larını kaydeder ve sistemin fonksiyonu test edilirken yanlış giden bir şey olduğunda ilgili input ve output görülebilir. Performans testlerinde bu ayarın seçili olmaması gerekir çünkü Sampler'lar aracılığıyla sisteme verilen request'lerin ve alınan bütün response'ların dosyaya kaydedilmesi JMeter'ın kaynaklarını loglama için tüketecek ve daha az kullanıcıyı gerçek zamanlı olarak simüle edebilmesine neden olacaktır. Bu durumda hedeflenen toplam kullanıcı sayısına ulaşabilmek için daha fazla test sunucusuna ihtiyaç duyulacaktır.
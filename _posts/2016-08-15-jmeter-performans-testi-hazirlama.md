---
layout: post
title: "JMeter Bölüm 4: Performans Testi Nasıl Hazırlanır?"
level: Orta
published: false
progress: only-planned
---

JMeter'ın en çok kullanıldığı alan şüphesiz Performans Testidir. Günümüz sistemlerinin geldiği noktada zengin fonksiyonlar sağlamak artık farklılık yaratan bir unsur olmaktan yavaş yavaş çıkmaktadır. Kullanıcılar üç aşağı beş yukarı benzer fonksiyonları sunan servisler arasında daha performanslı ve daha kararlı çalışan sistemleri tercih etmektedirler. Bu tarz sistemleri kullanıma sunmak için sistemin dar boğazlarını, yani performans problemi yaratacak bölümleri, henüz gerçek kullanıcılar görmeden yakalamak ve çözmek için gerçek senaryolara yakın senaryolarda performans testleri yapmak gereklidir. JMeter sunduğu pratik test senaryosu hazırlama olanakları ve bu senaryoları farklı girdilerle paralel olarak istenen sayıda kullanıcı ile koşturabilme özellikleri ile Performans Testi yapmak için mükemmel bir alternatif olarak ortaya çıkmaktadır. JMeter, paralel şekilde koşturulan sanal kullanıcılar kendilerine verilen senaryoları icra ederek sistemin verdiği cevapları ve metrikleri test sonrası kullanılmak üzere kaydederler. Oluşan bu bilgiler hemen test sonrası incelenebildiği gibi 

JMeter ile önceden bir deneyiminiz yoksa öncelikle aşağıdaki blog yazılarını okuyarak başlamanızı öneririz. Önceden deneyiminiz varsa bile aşağıda verilen blog yazılarını okumanızda fayda bulunmaktadır.

[JMeter Bölüm 1: Nedir ve Ne İşe Yarar?](/jmeter-nedir-ve-ne-ise-yarar/)

[JMeter Bölüm 2: Fonksiyon Testi Nasıl Hazırlanır?](/jmeter-fonksiyon-testi-hazirlama/)

[JMeter Bölüm 3: Pratik Test Senaryosu Kaydı Nasıl Yapılır?](/jmeter-pratik-test-hazirlama/)

Bu blog yazısını okuduktan sonra aşağıdaki blog yazısını da okumanız tavsiye edilir. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyoruz.

[JMeter Bölüm 5: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

### Çalışma Özeti

Bu blog'da JMeter'ı bir Performans Testi aracı olarak kullanacağız. Kurgulayacağımız .NET tabanlı basit bir sistemde birkaç senaryo üzerinden sistemi JMeter ile test edeceğiz. Sistemde iyileştirmemiz gereken kısımları belirleyeceğiz ve sistemi iteratif olarak iyileştirerek testler yapmaya devam edeceğiz.

* Docker Compose kullanarak oluşturduğumuz sistemimi tanıtarak başlayacağız.
* Sistemimizin kullanım senaryolarını özetleyeceğiz 
* JMeter'da ilgili kullanım senaryolarını tek bir kullanıcı için koşturan bir Test Plan oluşturacağız.
* Input dosyası vererek oluşturduğumuz sistemi birçok kullanıcı için paralel olarak koşturacak ve test sonuçlarını inceleyeceğiz.
* Sistemimizde bir iyileştirme yaparak testi tekrar koşturacağız ve test sonuçlarını karşılaştırmalı olarak göreceğiz.
* Yüksek sayıda kullanıcıyı simüle etmek için JMeter Test Planlarını bulut (Cloud) üzerinde birçok makinada koşturmaya olanak tanıyan [Blazemeter](https://www.blazemeter.com)'a kısa bir bakış atarak bu blog'u noktalayacağız.

### Ön Koşullar

Bu blog'da yer verilen adımları takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker Compose ile oluşturulan sistemi çalıştırabilmek, bu konuda bilgi için [Docker Compose Blog'una](/docker-compose-nasil-kullanilir/) göz atabilirsiniz.

### Test Edilecek Sistemin Mimarisi


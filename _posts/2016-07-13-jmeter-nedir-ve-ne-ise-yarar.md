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

## JMeter GUI
___


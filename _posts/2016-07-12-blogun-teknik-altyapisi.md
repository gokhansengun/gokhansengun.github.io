---
layout: post
title: Blog'un Teknik Altyapısı
---


Bu blog'da blog'umu hazırlarken ve sizlere sunarken kullanıdığım yöntemler, araçlar ve teknik altyapı ile ilgili detaylı bilgiler vermeye çalışacağım. Bu yazıyı okuyup referans verdiğim linkleri de takip ederek siz de kendi blog sitenizi oluşturabilirsiniz. Önceden web sitesi oluşturma, yayınlama ve web programlama tecrübeniz varsa hem yazıyı daha rahat takip edebilirsiniz hem de blog üzerinde yapmak istediğiniz değişiklikleri daha rahat yapabilirsiniz.

## Web Sitelerinin Gelişimi
___

Birçoğumuzun bildiği gibi web siteleri sunucular tarafından hazırlanan html dosyalarının bilgisayarlarımız ve akıllı telefonlarımızda kullandığımız tarayıcı'lar (browser) tarafından talep edilmesi ile ulaşılabilir hale gelir. İnternet'in ilk yıllarında bütün web siteleri her bir kullanıcı için kullanıcıya göre ayrı ayrı hazırlanmayan statik sayfaların önceden hazırlanıp kullanıcı talep ettiğinde kullanıcıya ulaştırılması ile sunuluyordu. Örnek olarak Apple'ın 1996 yılındaki [sitesine](https://web.archive.org/web/19961022105458/http://www.apple.com/) baktığımızda oldukça sade tasarlanmış ve kullanıcıya özel olmayan bir site olduğunu görebiliriz.

Günümüzde kullanıcı ile etkileşime girmeyen ve içeriğini kullanıcıya göre belirlemeyen bir web sitesi bulmamız neredeyse imkansız. Güncel web siteleri kullanıcı deneyimini artırmak için sunucu tarafında çalışan uygulamalarla, kullanıcıları sistemlerine dahil edip kullanıcıya özel içerik oluşturup hedefledikleri amaca daha kolay ulaşabiliyorlar. Sayfa içeriklerinin her bir kullanıcı için sunucu tarafında oluşturulması bir takım performans problemleri ve bakım ihtiyacı yaratmaktadır. Sayfa içeriklerinin dinamik olarak hazırlanması sunucu tarafında çalışması gereken bir web sunucunun yanında bir uygulama sunucusu ile birlikte çoğu zaman bir de veri tabanı sunucusunu gerekli kılmaktadır.  

## Platform
___

Sunucu tarafında çalışan uygulamalar, web sitesi geliştiricilerin işlerini o denli kolaylaştırmakta ve ürettikleri platformun esnek olmasını sağlamaktadır ki, günümüzde statik (kullanıcıdan kullanıcıya değişmeyen) içeriğe sahip birçok web sitesi sunucu tarafında çalışan uygulamalar tarafından üretilmektedir. Birçok blog sitesi de doğası gereği okuyucudan okuyucuya değişen bilgiler vermedikleri halde sayfaları sunucu tarafında çalışan uygulamalara ürettirmektedirler. 

Blog sitelerinin çok büyük bir bölümünde servis sağlayıcı olarak kullanılan [WordPress](https://wordpress.com/) ve [Ghost](https://ghost.org/) da sayfalarını sunucu tarafında çalışan uygulamalar ile üretmektedirler. Son kullanıcıya yönelik olarak hazırlanan ve son kullanıcının mail yazar gibi kolaylıkla blog yazısı hazırlamasına olanak tanıyan bu platformlar doğal olarak kullanıcıların büyük beğenisini topluyor, blog yazarları birkaç fare tıklaması ile yeni blog'ları kitlelerle buluşturabiliyorlar. 

Ben bu blog'u hazırlarken bir önceki bölümde anlattığım internet'in ilk yıllarına giderek statik sayfalar oluşturup kullanıcılara bu sayfaları sunmayı tercih ettim. Bu seçimi yapma sebeplerimden bazıları;

* Oluşturulan statik web sayfalarının platform bağımsız olarak herhangi bir web sunucusunda çalıştırılabilecek olması.
* Dinamik oluşturulan blog'lara göre daha az kaynak gerektirmesi.
* Dinamik oluşturulan blog'lara göre daha performanslı olması.
* Dinamik oluşturulan blog'lara göre hata olasılığının (sistem basitliğinden dolayı) daha düşük olması.
* İşletme maliyetinin dinamik oluşturulan blog'lara göre daha düşük olması, aslında bedava olması/olabilmesi :)

## Araç
___

Statik web sayfaları İnternet'in ilk zamanlarındaki gibi direkt html, css, js dosyaları *doğrudan* hazırlanarak yapılabileceği gibi bu dosyaların hazırlanmasını *dolaylı* olarak yapan araçlardan da yardım alınabilir. Bu araçlar "Static Site Generator" olarak adlandırılmaktadır. [http://staticgen.com ](https://www.staticgen.com/) web sitesi açık kaynak kodlu statik site üreten araçları karşılaştırmalı olarak tanıtmakta, popülerlik ve başka kriterlere göre sıralama ve filtrelemeye olanak tanımaktadır.

Birçok opsiyon arasında benim kendi blog'um için tercih ettiğim araç birkaç nedenden dolayı [Jekyll](https://jekyllrb.com/) oldu. Bunlardan en önemlisi Jekyll ile hazırladığım template'lerin [Github Pages](https://pages.github.com/) tarafından render edilebilmesi, ücretsiz, açık kaynaklı ve yüksek oranda erişilebilir olarak yayınlanabilmesiydi.

## Jekyll'la Blog Sitesi Hazırlamak
___

### Ön Koşullar

Bu blog'da yer verilen adımları takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* [Github](https://www.github.com) hesabına sahip olmak veya [yeni](https://github.com/join) bir hesap oluşturmak.
* Git versiyon kontrol sistemine clone/commit/pull/push komutlarını kullanabilecek kadar hakim olmak.
* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* [Markdown](https://en.wikipedia.org/wiki/Markdown) biçimlendirme dili ile bir metin editörü ya da bir WYSIWYG editörü yardımıyla blog yazıları oluşturmak. Markdown Github tarafından da README ve dokümantasyon dosyaları oluşturmada tercih ve tavsiye edilen çok güçlü, öğrenmesi ve kullanması kolay bir biçimlendirme dilidir.
* Scaffold edilecek blog'u özelleştirmek için başlangıç düzeyde HTML, CSS ve Template Engine biliyor olmak.

### Çalışma Özeti ve Yöntem

Aşağıdaki adımları tamamlayarak Jekyll yardımı ile bir blog sitesi hazırlayacağız.

* Denemeler yaparken zamandan kazanmak adına kendi bilgisayarımıza Jekyll kuracağız böylelikle blog'umuzu oluşturan statik sayfaları test amaçlı olarak kendi bilgisayarımızda hazırlayıp sunabileceğiz.
* Sıfırdan bir site oluşturmak yerine zamandan kazanmak adına mevcut bir Jekyll teması kullanacağız, bu tema bize scaffold edilmiş, görselliği ve fonksiyonalitesi iyileştirilmiş bir blog verecek.
* Kullandığımız temanın verdiği scaffold blog'u özelleştirerek isteklerimize göre konfigüre edeceğiz.
* Blog sitemizi Github Pages'te yayınlayacağız.
* Github Pages'te yayınladığımız blog sitemize başka bir URL'den nasıl yönlendirme yapacağımızı göreceğiz.

### Jekyll Kurulumu

Blog boyunca ben komutları yazarken ve ekran görüntülerini alırken işletim sistemi olarak Mac OS X kullanacağım. Aşağıda verilen linklerden Windows ve Linux için Jekyll kurulumu tamamlanıp blog'daki adımlar takip edilebilir.   

Jekyll, Ruby ile yazılan bir araç olduğu için geliştiricileri, Jekyll'ı bir Ruby paketi gibi dağıtmayı uygun görmüşler. Dolayısıyla Jekyll kurulumu, RubyGems (Ruby'nin paket yöneticisi, .NET platformundaki Nuget ve Node.js'teki npm benzeri) ile sağlanmakta. Kullandığınız işletim sistemine göre aşağıdaki yönergeleri takip ederek Jekyll kurulumunu tamamlayıp demo blog'umuzu hazırlamaya başlayalım.

* [Linux, Mac OS X ve Unix](https://jekyllrb.com/docs/installation/)
* [Windows Kurulum Adımları](https://jekyllrb.com/docs/windows/#installation)

### Isınma Turları

Blog'umuz hazırlamaya başlamadan hem yaptığımız seçimlerin daha iyi anlaşılması hem de elimizin alışması ve ısınmak için Jekyll kullanarak çok basit bir web sitesi scaffold edelim ve bunu kendi bilgisayarımızdan lokal olarak sunup tarayıcıda görüntüleyelim.

Daha önce de yazdığım gibi, komut satırından `$ jekyll new MyBlogSite` komutunu vererek çok basit anlamda bir blog sitesi scaffold ederek onun üzerinde çalışmaya başlayabiliriz. Eğer özgün bir tasarımı hedefliyorsanız bu yolla başlamalısınız fakat benim gibi daha kısa sürede tasarımını çok büyük oranda başkaları ile paylaşacağınız bir tasarıma razıysanız Jekyll temalarından birini seçerek başlamanız gerekecektir.

1. Komut satırını açıp web sitenizi yaratmak istediğiniz klasöre gidip `$ jekyll new MyBlogSite` komutunu çalıştırın. Aşağıdaki çıktıda da görebileceğiniz üzere Jekyll tek bir sayfadan `2016-07-15-welcome-to-jekyll.markdown` oluşan bir siteyi oluşturdu.

        Gokhans-MacBook-Pro:Garbage gsengun$ jekyll new DemoBlog
        New jekyll site installed in /Users/gsengun/Desktop/Garbage/DemoBlog.
        Gokhans-MacBook-Pro:DemoBlog gsengun$ tree
        .
        ├── _config.yml
        ├── _includes
        │   ├── footer.html
        │   ├── head.html
        │   ├── header.html
        │   ├── icon-github.html
        │   ├── icon-github.svg
        │   ├── icon-twitter.html
        │   └── icon-twitter.svg
        ├── _layouts
        │   ├── default.html
        │   ├── page.html
        │   └── post.html
        ├── _posts
        │   └── 2016-07-15-welcome-to-jekyll.markdown
        ├── _sass
        │   ├── _base.scss
        │   ├── _layout.scss
        │   └── _syntax-highlighting.scss
        ├── about.md
        ├── css
        │   └── main.scss
        ├── feed.xml
        └── index.html

2. Henüz Jekyll'a siteyi oluşturmak için bir komut vermedik dolayısıyla yukarıdaki çıktıda site ile ilgili html, css ve js dosyaları göremiyoruz. Jekyll'ın siteyi oluşturması için `$ jekyll build` ya da kısaca `$ jekyll b` komutlarını çalıştırabiliriz. Siteyi hem build etmek hem de sunmaya başlamak için ise `$ jekyll serve` ya da yine kısaca `$ jekyll s` komutlarını verebiliriz. Çıktıdan da görebileceğimiz üzere Jekyll yeni oluşturduğumuz blog sitemizi önce build ederek `http://127.0.0.1:4000/` adresinden (yani lokal olarak 4000 portundan) yayınlamaya başladı

        Gokhans-MacBook-Pro:DemoBlog gsengun$ jekyll s
        Configuration file: /Users/gsengun/Desktop/Garbage/DemoBlog/_config.yml
                    Source: /Users/gsengun/Desktop/Garbage/DemoBlog
            Destination: /Users/gsengun/Desktop/Garbage/DemoBlog/_site
        Incremental build: disabled. Enable with --incremental
            Generating...
                            done in 0.242 seconds.
        Auto-regeneration: enabled for '/Users/gsengun/Desktop/Garbage/DemoBlog'
        Configuration file: /Users/gsengun/Desktop/Garbage/DemoBlog/_config.yml
            Server address: http://127.0.0.1:4000/
        Server running... press ctrl-c to stop.

3. Favori tarayıcımızı açarak adres satırına blog'umuzun sunulduğu adresi `http://127.0.0.1:4000/` girerek sonucu görelim. Eğer aynı adımları takip ettiyseniz siz de aşağıdaki gibi bir çıktı görmelisiniz.

	![Jekyll Scaffolded Site](https://github.com/gokhansengun/gokhansengun.github.io/raw/master/img/blog/JekyllScaffolded.png "Jekyll Scaffolded Site")

4. `Ctrl + C` tuş kombinasyonu ile Jekyll'ın mini web sunucusunu durduralım. Blog sitesinin bulunduğu ana klasörde artık `_site` adlı klasör dikkatinizi çekecek. Jekyll konfigürasyon dosyalarındaki ayarlar, template'ler ve blog'ların yazıldığı markdown (ya da md) uzantılı dosyalardaki içeriği statik site olarak bu klasörün altında oluşturuyor. Blog'u oluşturduğunuz klasörde `tree _site` komutunu koşturarak statik sitenizin dosya yapısına göz atabilirsiniz.


        Gokhans-MacBook-Pro:DemoBlog gsengun$ tree _site
        _site
        ├── about
        │   └── index.html
        ├── css
        │   └── main.css
        ├── feed.xml
        ├── index.html
        └── jekyll
            └── update
                └── 2016
                    └── 07
                        └── 15
                            └── welcome-to-jekyll.html

### Kurulum Adımları

Ben bir demo hazırlayabilmek için yeni bir email ve yeni bir Github hesabı açtım. Aşağıdaki demo'larda kullanacağım Github kullanıcı adım `gsengundemo` olacak. Aşağıdaki adımları takip ederken bu kullanıcı adını gördüğünüz yerlerde kendi Github kullanıcı adınızı yazmanız gerektiğini tekrar hatırlatıp adımlara geçelim. 

Bir önceki adımda Jekyll'in scaffold ettiği basit bir blog sitesini oluşturduk fakat sanırım sitenin görselliği ve fonksiyonalitesi benim gibi sizi de pek memnun etmedi. Daha önce de belirttiğim gibi blog sitemizi oluştururken yukarıdaki template'den başlamak yerine görsellik ve fonksiyonalitesi güçlendirilmiş ve ücretsiz olarak kullanıma sunulan Jekyll temalarından faydalanabiliriz. Birçok temanın ön izleme seçeneği ile sunulduğu [Jekyll Themes](http://themes.jekyllrc.org)'e göz atarak kendi beğeninize ve amacınıza yönelik bir tema seçebilirsiniz. Biz bu blog'da [Beautiful Jekyll](http://themes.jekyllrc.org/beautiful-jekyll/) adlı temayı kullanacağız. Başlamadan önce isterseniz tema'nın [tema'nın demo site](http://deanattali.com/beautiful-jekyll/)'sine ve bu blog yazısı sonunda oluşturacağımız [blog demo](https://gsengundemo.github.io) sitesine göz atabilirsiniz.

1. [https://github.com/daattali/beautiful-jekyll](https://github.com/daattali/beautiful-jekyll) sayfasına giderek aşağıda görülen `fork` butonuna basın. Github'daki Beautiful Jekyll reposunu kendi account'unuz altına fork etmiş olacaksınız. Böylece o repository'nin bir kopyasını size özel bir biçimde oluşturup değiştirebileceksiniz.

	![Fork Beautiful Jekyll](https://github.com/gokhansengun/gokhansengun.github.io/raw/master/img/blog/JekyllGithubFork.png "Fork Beautiful Jekyll")

2. Halihazırda Github'a giriş yapmadıysanız kullanıcı adı ve şifrenizi girerek login olun. account'unuz ile [https://github.com](https://github.com/) sitesine giriş yapın ve `fork` butonuna tekrar basın. Tarayıcınızın adres satırının `https://github.com/gsengundemo/beautiful-jekyll` olarak değiştiğini ve kendi hesabınızda `beautiful-jekyll` adlı bir repo oluştuğunu göreceksiniz.

3. Aşağıdaki ekranda bulunan `Settings` butonuna basarak repo'nun ayarlar bölümünü açın.

	![Repo Settings](https://github.com/gokhansengun/gokhansengun.github.io/raw/master/img/blog/JekyllRepoSettings.png "Repo Settings")

	Açılan aşağıdaki ekranda bulunan `Repository Name` metin kutusuna `gsengunblog.github.io` yazarak `Rename` butonuna basın.

	![Repo Rename](https://github.com/gokhansengun/gokhansengun.github.io/raw/master/img/blog/JekyllChangeRepoName.png "Repo Rename")
	
4. Birkaç saniye bekleyip Github Pages tarafından blog'un oluşturulup yayınlanmasına izin verdikten sonra [https://gsengundemo.github.io/](https://gsengundemo.github.io/) adresini ziyaret ederek birkaç adımda oluşturduğumuz blog sitesini inceleyebilirsiniz.

	![Demo Site Layout](https://github.com/gokhansengun/gokhansengun.github.io/raw/master/img/blog/JekyllDemoSiteLayout.png "Demo Site Layout")


### Özelleştirme




























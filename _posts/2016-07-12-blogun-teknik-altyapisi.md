---
layout: post
title: Blog'un Teknik Altyapısı
level: Başlangıç
---

Bu blog'da, okuduğunuz bu blog'u hazırlarken ve sizlere sunarken kullanılan yöntemler, araçlar ve teknik altyapı ile ilgili detaylı bilgiler vermeye çalışacağız. Bu yazıyı okuyup, referans verilen linkleri takip ederek siz de kendi blog sitenizi oluşturabilirsiniz. Önceden web sitesi oluşturma, yayınlama ve web programlama tecrübeniz varsa hem yazıyı daha rahat takip edebilirsiniz hem de blog üzerinde yapmak istediğiniz değişiklikleri daha rahat yapabilirsiniz.

## Web Sitelerinin Gelişimi

Birçoğumuzun bildiği gibi web siteleri sunucular tarafından hazırlanan html dosyalarının bilgisayarlarımız ve akıllı telefonlarımızda kullandığımız tarayıcı'lar (browser) tarafından talep edilmesi ile ulaşılabilir hale gelir. İnternet'in ilk yıllarında bütün web siteleri her bir kullanıcı için kullanıcıya göre ayrı ayrı hazırlanmayan statik sayfaların önceden hazırlanıp kullanıcı talep ettiğinde kullanıcıya ulaştırılması ile sunuluyordu. Örnek olarak Apple'ın 1996 yılındaki [sitesine](https://web.archive.org/web/19961022105458/http://www.apple.com/) baktığımızda oldukça sade tasarlanmış ve kullanıcıya özel olmayan bir site olduğunu görebiliriz.

Günümüzde kullanıcı ile etkileşime girmeyen ve içeriğini kullanıcıya göre belirlemeyen bir web sitesi bulmamız neredeyse imkansız. Güncel web siteleri kullanıcı deneyimini artırmak için sunucu tarafında çalışan uygulamalarla (ya da SPA'lar ile sunucuya web servis çağrıları yaparak), kullanıcıları sistemlerine dahil edip kullanıcıya özel içerik oluşturup hedefledikleri amaca daha kolay ulaşabiliyorlar. Sayfa içeriklerinin her bir kullanıcı için sunucu tarafında oluşturulması bir takım performans problemleri ve bakım ihtiyacı yaratmaktadır. Sayfa içeriklerinin dinamik olarak hazırlanması sunucu tarafında çalışması gereken bir web sunucunun yanında bir uygulama sunucusu ile birlikte çoğu zaman bir de veri tabanı sunucusunu gerekli kılmaktadır. Görüleceği üzere bir site için iki ya da üç sunucunun varlığı söz konusudur.

## Platform

Sunucu tarafında çalışan uygulamalar, web sitesi geliştiricilerin işlerini o denli kolaylaştırmakta ve ürettikleri platformun esnek olmasını sağlamaktadır ki, günümüzde statik (kullanıcıdan kullanıcıya değişmeyen) içeriğe sahip birçok web sitesi, sunucu tarafında çalışan uygulamalar tarafından üretilmektedir. Birçok blog sitesi de doğası gereği okuyucudan okuyucuya değişen bilgiler vermedikleri halde sayfaları sunucu tarafında çalışan uygulamalara ürettirmektedirler. 

Blog sitelerinin çok büyük bir bölümünde servis sağlayıcı olarak kullanılan [WordPress](https://wordpress.com/) ve [Ghost](https://ghost.org/) da sayfalarını sunucu tarafında çalışan uygulamalar ile üretmektedirler. Son kullanıcıya yönelik olarak hazırlanan ve son kullanıcının mail yazar gibi kolaylıkla blog yazısı hazırlamasına olanak tanıyan bu platformlar doğal olarak kullanıcıların büyük beğenisini topluyor, blog yazarları birkaç fare tıklaması ile yeni blog'ları kitlelerle buluşturabiliyorlar. 

Okuduğunuz bu blog hazırlanırken bir önceki bölümde anlatılan internet'in ilk yıllarına gidilerek statik sayfalar oluşturup kullanıcılara bu sayfaları sunma yöntemi tercih edilmiştir. Bu seçimin yapılma nedenlerinden bazıları:

Oluşturulan statik web sayfalarının

* Platform bağımsız olarak herhangi bir web sunucusunda çalıştırılabilecek olması.
* Dinamik oluşturulan blog'lara göre daha az kaynak gerektirmesi.
* Dinamik oluşturulan blog'lara göre daha performanslı olması.
* Dinamik oluşturulan blog'lara göre hata olasılığının (sistem basitliğinden dolayı) daha düşük olması.
* İşletme maliyetinin dinamik oluşturulan blog'lara göre daha düşük olması, aslında bedava olması/olabilmesi :)

## Araç

Statik web sayfaları İnternet'in ilk zamanlarındaki gibi direkt html, css, js dosyaları *doğrudan* hazırlanarak yapılabileceği gibi bu dosyaların hazırlanmasını *dolaylı* olarak yapan araçlardan da yardım alınabilir. Bu araçlar "Static Site Generator" olarak adlandırılmaktadır. [http://staticgen.com ](https://www.staticgen.com/) web sitesi açık kaynak kodlu statik site üreten araçları karşılaştırmalı olarak tanıtmakta, popülerlik ve başka kriterlere göre sıralama ve filtrelemeye olanak tanımaktadır.

Birçok opsiyon arasında okuduğunuz bu blog için tercih edilen araç birkaç özelliğinden dolayı [Jekyll](https://jekyllrb.com/) olmuştur. Bu özelliklerden en önemlisi Jekyll ile hazırlanan template'lerin [Github Pages](https://pages.github.com/) tarafından render edilebilmesi, ücretsiz, açık kaynaklı ve yüksek oranda erişilebilir olarak yayınlanabilmesidir.

## Jekyll'la Blog Sitesi Hazırlamak

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
* Blog sitemizi Github Pages'te yayınlayacağız.
* Kullandığımız temanın verdiği scaffold blog'u özelleştirerek isteklerimize göre konfigüre edeceğiz.

### Jekyll Kurulumu

Blog boyunca komutlar yazılırken ve ekran görüntüleri alınırken işletim sistemi olarak Mac OS X kullanılacaktır. Aşağıda verilen linklerden Windows ve Linux için Jekyll kurulumu tamamlanıp blog'daki adımlar takip edilebilir.   

Jekyll, Ruby ile yazılan bir araç olduğu için geliştiricileri, Jekyll'ı bir Ruby paketi gibi dağıtmayı uygun görmüşlerdir. Dolayısıyla Jekyll kurulumu, RubyGems (Ruby'nin paket yöneticisi, .NET platformundaki Nuget ve Node.js'teki npm benzeri) ile sağlanmaktadır. Kullandığınız işletim sistemine göre aşağıdaki yönergeleri takip ederek Jekyll kurulumunu tamamlayıp demo blog'umuzu hazırlamaya başlayalım.

* [Linux, Mac OS X ve Unix](https://jekyllrb.com/docs/installation/)
* [Windows Kurulum Adımları](https://jekyllrb.com/docs/windows/#installation)

### Isınma Turları

Blog'umuzu hazırlamaya başlamadan hem yaptığımız seçimlerin daha iyi anlaşılması hem de elimizin alışması ve ısınmak için Jekyll kullanarak çok basit bir web sitesi scaffold edelim ve bunu kendi bilgisayarımızdan lokal olarak sunup tarayıcıda görüntüleyelim.

Daha önce de yazıldığı gibi, komut satırından `$ jekyll new MyBlogSite` komutu verilerek çok basit anlamda bir blog sitesi scaffold ederek onun üzerinde çalışmaya başlayabiliriz. Eğer özgün bir tasarımı hedefliyorsanız bu yolla başlamalısınız fakat bu blog'daki gibi daha kısa sürede tasarımını çok büyük oranda başkaları ile paylaşacağınız bir tasarıma razıysanız Jekyll temalarından birini seçerek başlamanız gerekecektir.

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

2. Henüz Jekyll'a siteyi oluşturmak için bir komut vermedik dolayısıyla yukarıdaki çıktıda site ile ilgili html, css ve js dosyaları göremiyoruz. Jekyll'ın siteyi oluşturması için `$ jekyll build` ya da kısaca `$ jekyll b` komutlarını çalıştırabiliriz. Siteyi hem build etmek hem de sunmaya başlamak için ise `$ jekyll serve` ya da yine kısaca `$ jekyll s` komutlarını verebiliriz. Çıktıdan da görebileceğimiz üzere Jekyll yeni oluşturduğumuz blog sitemizi önce build ederek `http://127.0.0.1:4000/` adresinden (yani lokal olarak 4000 portundan) yayınlamaya başladı.

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

    {% include image.html url="/resource/img/Jekyll/JekyllScaffolded.png" description="Jekyll Scaffolded Site" %}

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

### Şablon Kurulum Adımları

Bu blog'da bir demo hazırlayabilmek için yeni bir email ve yeni bir Github hesabı açılmıştır. Aşağıdaki demo'larda kullanılacak Github kullanıcı adı `gsengundemo` olacak. Aşağıdaki adımları takip ederken bu kullanıcı adını gördüğünüz yerlerde kendi Github kullanıcı adınızı yazmanız gerektiğini tekrar hatırlatıp adımlara geçelim. 

Bir önceki adımda Jekyll'in scaffold ettiği basit bir blog sitesini oluşturduk fakat sanırım sitenin görselliği ve fonksiyonalitesi sizi de pek memnun etmedi. Daha önce de belirtildiği gibi blog sitemizi oluştururken yukarıdaki template'den başlamak yerine görsellik ve fonksiyonalitesi güçlendirilmiş ve ücretsiz olarak kullanıma sunulan Jekyll temalarından faydalanabiliriz. Birçok temanın ön izleme seçeneği ile sunulduğu [Jekyll Themes](http://themes.jekyllrc.org)'e göz atarak kendi beğeninize ve amacınıza yönelik bir tema seçebilirsiniz. Biz bu blog'da [Beautiful Jekyll](http://themes.jekyllrc.org/beautiful-jekyll/) adlı temayı kullanacağız. Başlamadan önce isterseniz tema'nın [tema'nın demo site](http://deanattali.com/beautiful-jekyll/)'sine ve bu blog yazısı sonunda oluşturacağımız [blog demo](https://gsengundemo.github.io) sitesine göz atabilirsiniz.

1. [Beautiful Jekyll Github](https://github.com/daattali/beautiful-jekyll) sayfasına giderek aşağıda görülen `fork` butonuna basın. Github'daki Beautiful Jekyll reposunu kendi account'unuz altına fork etmiş olacaksınız. Böylece o repository'nin bir kopyasını size özel bir biçimde oluşturup değiştirebileceksiniz.

	{% include image.html url="/resource/img/Jekyll/JekyllGithubFork.png" description="Fork Beautiful Jekyll" %}

2. Halihazırda Github'a giriş yapmadıysanız kullanıcı adı ve şifrenizi girerek login olun. account'unuz ile [https://github.com](https://github.com/) sitesine giriş yapın ve `fork` butonuna tekrar basın. Tarayıcınızın adres satırının `https://github.com /gsengundemo/beautiful-jekyll` olarak değiştiğini ve kendi hesabınızda `beautiful-jekyll` adlı bir repo oluştuğunu göreceksiniz.

3. Aşağıdaki ekranda bulunan `Settings` butonuna basarak repo'nun ayarlar bölümünü açın.

    {% include image.html url="/resource/img/Jekyll/JekyllRepoSettings.png" description="Repo Settings" %}
	
	Açılan aşağıdaki ekranda bulunan `Repository Name` metin kutusuna `gsengunblog.github.io` yazarak `Rename` butonuna basın.

    {% include image.html url="/resource/img/Jekyll/JekyllChangeRepoName.png" description="Repo Rename" %}
	
4. Birkaç saniye bekleyip Github Pages tarafından blog'un oluşturulup yayınlanmasına izin verdikten sonra [https://gsengundemo.github.io/](https://gsengundemo.github.io/) adresini ziyaret ederek birkaç adımda oluşturduğumuz blog sitesini inceleyebilirsiniz.

	{% include image.html url="/resource/img/Jekyll/JekyllDemoSiteLayout.png" description="Demo Site Layout" %}


### Şablonu Özelleştirme Adımları

Yuklarıdaki adımlarla Beautiful Jekyll temasını kullanarak kendimize bir şablon (template) oluşturduk. Şimdi bu template'i nasıl özelleştirebileceğimizi adım adım inceleyelim.

Öncelikle blog üzerinde daha rahat değişiklik yapabilmek için blog'umuzun kaynak kodunu lokal bilgisayarımıza alacağız ve blog'umuzu daha önce bilgisayarımıza yüklediğimiz Jekyll yardımıyla sunacağız. Sonra blog üzerinde değişiklikler yapıp bu değişiklikleri lokal sunucumuz ile test edip değişikliklerden memnun kaldıktan sonra Github'daki repo'muza push ederek yayınlanmasını bekleyeceğiz.

1. Favori Git istemcimiz (komut satırı, SourceTree, Github Desktop, SmartGit, GitKraken, vb) ile Git repo'muzu Github'dan lokal klasörümüze alalım. Biz daha kolay gösterim sağlayacağı için komut satırını tercih edeceğiz ve `git clone` komutunu kullanacağız. Bu komut Github'da bulunan repo'yu bire bir olarak lokal klasörüme kopyalayacak.

        Gokhans-MacBook-Pro:Garbage gsengun$ git clone https://github.com/gsengundemo/gsengundemo.github.io.git
        Cloning into 'gsengundemo.github.io'...
        remote: Counting objects: 1069, done.
        remote: Total 1069 (delta 0), reused 0 (delta 0), pack-reused 1069
        Receiving objects: 100% (1069/1069), 3.12 MiB | 1.48 MiB/s, done.
        Resolving deltas: 100% (613/613), done.
        Checking connectivity... done.
        Gokhans-MacBook-Pro:Garbage gsengun$ ls

	Bilgisayarınızın dosya sisteminde klonladığınız repo isminizle uyumlu olarak oluşturulacaktır. `tree` komutunu kullanarak repo içeriğini görebilirsiniz.

        Gokhans-MacBook-Pro:Garbage gsengun$ tree gsengundemo.github.io/
        gsengundemo.github.io/
        ├── 404.html
        ├── Gemfile
        ├── Gemfile.lock
        ├── LICENSE
        ├── README.md
        ├── Vagrantfile
        ........
        ........
        
2. Isınma Turları bölümünde yaptığımıza benzer şekilde blog'umuzu klonladığımız klasöre giderek `$ jekyll serve` ya da `$ jekyll s` komutunu verin. Jekyll `serve` veya kısaca `s` komutu ile blog sitenizi `http://127.0.0.1:4000/` adresinden yayınlamaya başlayacaktir. Bu sitenin `https://gsengundemo.github.io` adresi ile aynı içeriği verdiğini göreceksiniz.

        Gokhans-MacBook-Pro:gsengundemo.github.io gsengun$ jekyll s
        Configuration file: /Users/gsengun/Desktop/Garbage/gsengundemo.github.io/_config.yml
                    Source: /Users/gsengun/Desktop/Garbage/gsengundemo.github.io
            Destination: /Users/gsengun/Desktop/Garbage/gsengundemo.github.io/_site
        Incremental build: disabled. Enable with --incremental
            Generating...
                            done in 0.323 seconds.
        Auto-regeneration: enabled for '/Users/gsengun/Desktop/Garbage/gsengundemo.github.io'
        Configuration file: /Users/gsengun/Desktop/Garbage/gsengundemo.github.io/_config.yml
            Server address: http://127.0.0.1:4000/
        Server running... press ctrl-c to stop.

    {% include image.html url="/resource/img/Jekyll/JekyllDemoSiteLayoutLocal.png" description="Demo Site Local" %}
        
3. Favori metin editörünüz ya da entegre geliştirme aracınız (IDE) ile klonladığınız klasörü açın. Biz demo'da Windows, Linux ve Mac üzerinde de çalışan Visual Studio Code metin editörünü kullanacağız. Ana klasörde bulunan `_config.yml` dosyasını açarak gerekli değişiklikleri yapmaya hazır hale gelin. Jekyll bazı değişiklikleri yeniden başlatılmaya gerek duymadan tarayıcınıza yansıtacaktır. Tarayıcınıza yansımayan değişiklikler için sunucuyu `ctrl + C` ile durdurup `$ jekyll s` komutu ile tekrar başlatabilirsiniz.

	3.1. Linklerle ilgili düzenlemeler:
	
	3.1.1. `url: "http://username.github.io"` yazan kısmı `url: "http://gsengundemo.github.io"` olarak değiştirin. Bu değişiklik sayesinde sayfa içinde kullanılan ve ana sayfaya dönmeye yarayan linkler doğru bir şekilde yönlenecektir.
	
	3.1.2. Sağ üst tarafta bulunan linkleri düzenlemek için `navbar-links:` bölümünü değiştirebilirsiniz.
	
	3.1.3. `footer-links-active:` bölümünü kullanarak blog sitenizin altında hangi linklerin bulunacağını belirleyebilirsiniz. Bu örnekte sadece email, github ve twitter linklerini aktif bırakacağız aşağıda.

        footer-links-active:
            rss: false
            facebook: false
            email: true
            twitter: true
            github: true
            linkedin: false
            stackoverflow: false
            
    3.1.4. Yukarıda aktif bıraktığınız linkler için aşağıda gerekli bilgileri girin
            
        author:
            name: Gsengun Demo
            email: "gsengundemo@gmail.com"
            facebook: yourname
            github: gsengundemo
            twitter: gsengundemo
            linkedin: yourlink
            stackoverflow: yourlink


	3.2. Metadata düzenlemeleri:
	
	3.2.1. `title: My website` kısmı blog'unuzun başlığı ile değiştirin. Örneğin: `title: Gsengun Jekyll Demo Site`
	
	3.2.2. `description:` kısmında blog'unuzla ilgili kısa bilgi verin. 
	
	3.3. Ana Sayfa düzenlemeleri
	
	3.3.1. Ana klasörde bulunan index.html dosyasını açarak aşağıdaki satırları ana sayfada görünmesini istediğiniz bilgilere göre düzenleyin.
	
		title: My website
		subtitle: This is where I will tell my friends way too much about me

	Biz aşağıdaki bilgileri girdik.
	
		title: Gsengun Jekyll Demo Site
		subtitle: Bu blog Jekyll ile yapılmıştır.
		
	3.3.2. Ana klasördeki `_posts` klasöründe bulunan bloglardan bir kısmını silip örnek olarak kullanılacak iki tane post bırakın. Aşağıdaki gibi özelleştirilmiş bir içerik görmelisiniz.
	
    {% include image.html url="/resource/img/Jekyll/JekyllDemoSiteLayoutCustomized.png" description="Demo Site Local Customized" %}

4. En son adım olarak yeni bir blog yazısının nasıl oluşturulacağını görelim. `_posts` klasörünün altındaki blog'lardan birini yine aynı klasöre kopyalayarak ona blog'unuza dair bir isim verin. Bizim oluşturduğumuz dosyanın adı `2016-07-12-ozellestirilmis-ilk-post.md` oldu. Vereceğiniz tarihin bugün veya bugünden önce olması gerektiğini belirterek içinde bulunulan günün sonrasındakilerin ana sayfada görüntülenmeyeceğini belirtelim. Kopyalama yoluyla yeni oluşturduğunuz dosyayı açarak ilk post'unuzu yazın. Sayfayı yenilediğinizde aşağıdakine benzer bir görüntü elde etmelisiniz.

	{% include image.html url="/resource/img/Jekyll/JekyllFirstPost.png" description="Demo Site First Post" %}

## Sonuç ve Sonraki Adımlar

Bu blog'da `Jekyll` statik site oluşturma aracı ve `Beautiful Jekyll` temasını kullanarak bir blog sitesi oluşturduk ve bu siteyi konfigürasyonda verilen parametreleri değiştirerek basit bir şekilde özelleştirdik. `Beautiful Jekyll` temasının verdiği baz kodda daha fazla değişiklik yaparak, blog'u daha da fazla özelleştirebilriz. Bu [blog sitesinin Github reposu](https://github.com/gokhansengun/gokhansengun.github.io)nu bilgisayarınıza klonlayıp, kendi bilgisayarınızda Jekyll ile çalıştırabilir ve `Beautiful Jekyll` temasına yapılan eklemeleri gözlemleyebilirsiniz.

Jekyll'da blog sitenizi daha interaktif ve çekici kılabilecek, ücretsiz olarak hizmete sunulan birçok plugin bulunmaktadır. Blog sitenize kullanıcı yorumlarını [DISQUS](https://disqus.com/) aracılığıyla ekleyebileceğiniz bir plugin bulabileceğiniz gibi blog post'larınızı tag'leyebileceğiniz bir plugin de bulabilirsiniz. Farklı plugin'ler için [http://www.jekyll-plugins.com/](http://www.jekyll-plugins.com/) ve [http://jekyll.tips/jekyll-plugins/](http://jekyll.tips/jekyll-plugins/) sitelerini ziyaret edebilirsiniz.
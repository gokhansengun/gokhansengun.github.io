---
layout: post
title: "Docker Bölüm 1: Nedir, Nasıl Çalışır, Nerede Kullanılır?"
level: Başlangıç
progress: continues
---

Popüler tabirle "Geleceğin Teknolojisi"ne detaylı bir şekilde göz atacağız. Bu blog'da ilerleyen zamanlarda yer vereceğim post'ların neredeyse tamamının demo'larında Docker kullanacak olduğumdan post'ların anlaşılabilmesi açısından siz değerli okuyucuların "Yeter Derece"de Docker'a hakim olması gerektiğini düşünüyorum. Bu blog serisini başlatma sebebim tam olarak da bu. Başka kaynaklarda Docker ile ilgili bulunamayacak bilgilerin bu blog serisinde bulunacağı iddiasında değilim ancak derli toplu, pratik bilgilere ağırlık veren pragmatik bir yaklaşımla konuyu ele alacağımızı söyleyebilirim.

Docker blog serisinde okumaya başladığınız bu blog'a ek olarak aşağıdaki iki blog daha yer alacaktır.

[Docker Bölüm 2: Yeni bir Docker İmajı Nasıl Hazırlanır?](/docker-yeni-imaj-hazirlama/)

[Docker Bölüm 3: Docker Compose Hangi Amaçlarla ve Nasıl Kullanılır?](/docker-compose-nasil-kullanilir/)

## Çalışma Özeti
___

Aşağıdaki adımları tamamlayarak Docker hakkında genel anlamda fikir sahibi olarak nasıl çalıştığını ve hangi amaçlarla nerelerde kullanıldığını anlamaya çalışacağız.

* Docker'ın doğuş hikayesini anlatarak başlayacağız.
* Docker'ın mimarisi hakkında bilgiler vererek kurulumla ilgili doğru kaynakları göstereceğiz.
* Docker terminolojisine göz atacağız.
* Docker CLI (Command-Line Interface - Komut Satırı)'la tanışacağız.
* İlerleyen bölümlerde referans olması açısından Docker CLI - Cheat Sheet (Kopya Kağıdı) oluşturacağız.
* Docker'ın kullanım alanlarını inceleyeceğiz ve yazıyı böylece kapatağız.

### Doğuş Hikayesi

#### Tarihçe

Klasik olarak bir tanımla başlamamız gerekirse Docker, dünyada en çok kullanılan yazılım konteynerleştirme platformudur. Konteynerleştirme konteyner içine koyma anlamına gelir. Docker, Linux Kernel'e 2008 yılında eklenen Linux Containers (LXC) üzerine kurulu bir teknolojidir. LXC, Linux'da aynı işletim sistemi içerisinde birbirinden izole olmuş bir biçimde çalışan container'lar (Linux tabanlı sistemler) sağlamaktadır. Anlaşıldığı üzere LXC, işletim sistemi seviyesinde bir sanallaştırma (virtualization) altyapısı sunmaktadır. Container'lar içerisinde aynı işletim sistemi tarafından çalıştırılan process'lere, LXC tarafından işletim sisteminde sadece kendileri koşuyormuş gibi düşünmeleri için bir sanallaştırma ortamı sağlanmıştır. LXC, container'lara işletim sistemi tarafından sunulan dosya sistemi, ortam değişkenleri (Environment Variable), vb fonksiyonları her bir container'a özgü olarak sağlar. Aynı işletim sistemi içerisinde çalışmalarına rağmen container'lar birbirlerinden izole edilmişlerdir ve birbirleri ile istenmediği müddetçe iletişime geçemezler. Bütün bu özelliklerin nasıl pek yararlı fonksiyonlara dönüştürüleceği noktasına birazdan geleceğiz. Biraz daha LXC, Docker ve klasik sanallaştırma üzerinden devam edelim.

VMware, Xen, Hyper-V gibi Hypervisor'ler (sanallaştırma platformları), yönettikleri fiziksel veya sanal bilgisayarlar üzerine farklı işletim sistemleri kurulmasına olanak tanımaktadırlar. Günümüzde veri merkezleri (data center) çok büyük oranda sayılan Hypervisor'ler tarafından sanallaştırılmışlardır, Cloud (Bulut) olarak adlandırılan kavramın altyapı kısmını oluşturan geniş veri merkezleri tamamıyla Hypervisor'ler tarafından yönetilmektedir. Hypervisor platformları sayesinde fiziksel olarak işletilen güçlü sunucular, ihtiyaç ölçüsünde farklı işletim sistemleri (kimi zaman hem Windows hem de Linux aynı fiziksel sunucuda) kurularak kolaylıkla işletilebilmektedir. Sanallaştırılan farklı işletim sistemlerinin, Hypervisor tarafından fiziksel sunucu üzerinde kendisine sağlanan disk bölümlerine kurulması gerekmektedir. LXC'nin Hypervisor'e göre sağladığı avantajların en önemlilerinden birisi aynı işletim sistemi içerisinde sunabilmesidir. Böylelikle sanallaştırma için gerekli disk alanından önemli bir tasarruf sağlanmaktadır. Sanal olarak koşturulan işletim sistemlerinin her birinin 7GB disk alanı gerektirdiğini düşünelim. Hypervisor'lerle 64 core'luk işlemciye sahip bir bilgisayara 20 adet sanal sunucu kurmak istediğimizde 20 x 7GB = 140GB bir disk alanına ihtiyacımız olacaktır. 20 adet sanal sunucu kurmak yerine LXC ile sanallaştırma yaptığımızda ise sadece 7GB'lık bir disk alanı bize yeterli olacaktır.

Hyporvisor'lerle yapılan sanallaştırma herbir işletim sisteminin ayrı ayrı bakımının (güncellenmelerin ve güvenlik yamalarının) yapılması gerekmektedir. Tek işletim sistemi içerisinde LXC kullanılarak yapılan sanallaştırmada ise bir işletim sisteminin bakımı yapılarak daha ekonomik bir biçimde bakım yapılabilir. LXC ile Hyporvisor'ler arasındaki farklar biraz daha uzatılabilir ancak bizi esas konumuzdan uzaklaştırır. Temel olarak LXC, container açısından standart bir Linux kurulumundan hiçbir farklı olmayan fakat aynı çekirden (kernel) üzerinde koşan bir ortam sağlamaktadır. LXC 2008 yılında ortaya çıkmasına ve kendisine farklı alanlarda ciddi kullanım alanı bulmasına rağmen onu hakettiği geniş kitlelerle buluşturan 2013 yılında ortaya çıkan Docker'dır.

#### LXC'den Docker'a Geçiş

Açık konuşmak gerekirse Docker, LXC'nin zengin mirasının üzerine oturmuştur fakat LXC'de manuel olarak yapılan işlemleri ustaca paketleyerek standardize etmiştir. Docker, LXC'nin sunduğu kapsamlı fonksiyonları ve konfigürasyonları detaylarından arındırarak tabiri caizse halka indirmiştir. Docker'ın getirdiği en önemli özellik container'ın yapısını metin bazlı imaj formatı ile (detaylarına sonradan değineceğiz) tanımlamasıdır. Bu sayede aynı imaj formatı kullanılarak aynı özellikteki container'lar kolaylıkla yaratılabilir, başka kişilerle Docker Registery üzerinden paylaşılabilir ve kolaylıkla genişletilebilir (farklı fonksiyonlar eklenebilir). Docker'ın LXC'ye göre getirdiği temel farklılıklardan bir başkası Docker'ın kullanıcılarını aynı container'da sadece ve sadece tek process çalıştırmaya adeta zorlamasıdır. Birçoğumuz aşağıdaki caps'i görmüşüzdür. Kod silerek bug çözdüğünü iddia eden biri var. Aslında burada Docker'ın yaptığı da benzer bir şey bana göre. Docker, LXC'nin kullanıcıya sunduğu fonksiyonu daraltarak aslında daha kullanılabilir ve daha çok işe yarar bir yapı elde etmiştir. Aynı container'ın birden çok process yerine tek process çalıştırması container'ların tekrar tekrar, kolaylıkla, genişletilebilir ve daha anlaşılabilir bir biçimde kullanılmasını sağlamaktadır. Bu kısmı ilerleyen blog'larda detaylı bir şekilde defalarca örnekleyeceğiz, şimdilik küçük bir örnek olarak, oluşturacağımız sistemde bir web server, bir app server ve bir database server olduğunu düşünelim. Docker'ın önerdiği yapı bu üç bileşenin tek bir container içine konması yerine ayrı ayrı container'larda çalıştırılmasıdır. 

{% include centeredImage.html url="/resource/img/DockerPart1/FixedABugByDeletingCode.jpg" description="New Test Plan" %}

Ayrı ayrı container'lar içinde çalıştırılan bileşenler (app server, web server, vb) gerektiği durumlarda teker teker genişletilebilir. Örneğin web server'ın istekleri karşılamada yetersiz olduğu görülürse web server container'ından bir veya daha fazla ekstra container yaratılarak gerekli işlem gücü diğer bileşenlerden (app server ve database server) bağımsız olarak sağlanmış olur. Eğer üç bileşeni aynı container'a koysaydık ek web server isteğinde bu üç bileşeni birden içeren yeni bir container'ı ayağa kaldırıp burada sadece web server'ın çalışması için gerekli konfigürasyon ve kod değişikliğinin yapılması gerekecekti. Bu yapı aslında gün geçtikçe daha da popüler hale gelen Microservices trendini destekleyici bir özelliktir. Mikro servisler temellerini 1970'lerde Unix'ten "Do one thing and do it well" yani "Sadece bir şey yap ve iyi yap" olarak tercüme edilebilecek felsefeden almaktadır. Unix/Linux komut satırı fonksiyonlarını detaylı bir biçimde kullananlar ne demek istediğimi eminim daha iyi anlamışlardır. 

Son olarak Docker geliştirmesinin en başlarında bence çok doğru bir kararla LXC bağımlılığını kaldırarak kendi bünyesinde LXC'yi yeniden kodlayarak libcontainer adında kendisi ile birlikte dağıtmaya başlamıştır. Bu kararı almalarındaki en önemli iki neden Docker'ın hızlı geliştirilebilmesi için Linux Kernel'den ayrı ve seçimleri Linux Çekirdeği geliştiricileri yerine kendilerinin alabileceği bir proje yaratmak ve mümkün olduğunca Linux Distro bağımlılıklarını kaldırmak olarak sıralanabilir. Bu konuyu daha fazla uzatmadan burada bağlayarak devam edelim.

### Kurulum ve Mimari

Başlık biraz yanıltıcı olabilir. Docker'ın kurulum detayları aşağıdaki linklerde çok detaylı ve ek izaha gerek bırakmayacak kadar güzel açıklanmış. Kullanıdığınız platforma göre aşağıdaki linklerden kurulum yapabilirsiniz. Ben burada biraz daha büyük resmi göstermeye çabalayacağım.

#### Kurulum

- [Windows](https://docs.docker.com/engine/installation/windows)
- [Mac OS X](https://docs.docker.com/engine/installation/mac/)
- [Linux](https://docs.docker.com/engine/installation/)

#### Mimari

Baştan beri Docker'ın Linux Kernel'inden destek alarak ortaya çıkan ve Linux İşletim Sistemi üzerinde çalışan bir sistem olduğunu yazdık. Peki nasıl oluyor da Docker Linux dışında hem Windows hem de Mac OS X'te kullanılabiliyor? Docker temel iki parçadan oluşmaktadır. Birincisi Linux Kernel'la direkt iletişim halinde olan Docker Engine, ikincisi ise bu Engine (Motor) ile iletişim kurmamıza olanak tanıyan Docker CLI (Command-Line Interface)'dır. Linux'ta hem Docker Engine hem de Docker CLI doğal olarak direkt Linux üzerinde koşmaktadır. Windows ve Mac OS X'te ise Docker CLI Windows ve Mac OS X işletim sistemleri üzerinde koşmakta, Docker Engine ise bu işletim sistemlerinde bir Hypervisor (duruma göre VMware, VirtualBox, Hyperkit, Hyper-V) yardımıyla çalıştırılan Linux üzerinde koşmaktadır.

Windows ve Mac OS X'te (konfigüratif olarak aynı zamanda Linux'ta da) Docker CLI ve Docker Engine TCP ile haberleşmektedirler. Docker CLI'dan verilen komutlar TCP ile Engine'e iletilmekte ve işlenip cevaplanmaktadır. Aralarında TCP haberleşmesi bulunduğundan aralarında TCP bağlantısı kurulabilen herhangi bir Docker CLI (Client) ile Docker Engine'i konuşturmak mümkündür. İşte anlatılan bu yöntemle Windows ve Mac OS X'te Docker çalıştırmak mümkün hale gelmektedir. Bu kadar anlatmışken Linux'ta default olarak aynı makine üzerindeki CLI ile Engine'in Unix socket'ler üzerinden konuştuğunu ve daha hızlı çalıştığını vurgulamakta fayda var.

Windows ve Mac OS X'teki mimari aşağıdaki şekilde resmedilmiştir.

{% include centeredImage.html url="/resource/img/DockerPart1/DockerOnWindows.svg" description="Docker on Windows" %}
 
### Terminoloji

Docker yepyeni ve Linux bazlı bir teknoloji olduğu için hem kendi terimleri hem de bazı Linux terimleri birçoğumuza ilk bakışta biraz yabancı gelecek fakat çabucak ısınacağımızı umuyorum.

#### Container

Docker Engine tarafından Linux çekirdeği içerisinde birbirinden izole olarak çalıştırılan process'lerin her birine verilen isimdir. Virtual Machine (Sanal Makina) analojisinde Docker'ı Hypervisor'e benzetirsek fiziksel sunucu üzerinde halihazırda koşturulmakta olan herbir işletim sisteminin Docker'daki karşılığı Container'dır. Milisaniyeler içerisinde başlatılabilir, istenen herhangi bir anda duraklatılabilir (Pause), tamamen durdurulabilir (Stop) ve yeniden başlatılabilirler. 

#### Image ve Dockerfile

Docker Engine ile çalıştırılacak Container'ların baz alacağı işletim sistemi veya başka imajı, dosya sisteminin yapısı ve içerisindeki dosyaları, koşturacağı programı (veya bazen çok tercih edilmemekle birlikte programları) belirleyen ve içeriği metin bazlı bir Dockerfile (yazımı tam olarak böyle, ne dockerfile ne DockerFile ne de DOCKERFILE) ile belirlenen binary'ye verilen isimdir.

Hatırlarsanız Docker'ın doğuşunu anlattığımız ilk bölümde Docker'ın oyunu değiştiren bir hamle yaparak LXC'ye göre fonksiyon kıstığınını ve böylece başarılı olduğunu söylemiştik. İşte Docker, koşturulacak container'ların iskeletini oluşturan her bir imajın bir Dockerfile ile tanımlanmasını gerekli kılar. Bu Dockerfile içerisinde imajın hangi imajı baz aldığı, hangi dosyaları içerdiği ve hangi uygulamayı hangi parametrelerle koşturacağı açık açık verilir. Dockerfile'ın içeriğini ve yeni bir Dockerfile dolayısıyla da yeni bir Image oluşturmayı [bir sonraki](/docker-yeni-imaj-hazirlama/) blog'da ziyade detayda ele alacağız. Bu blog'un amaçları doğrultusunda bu kadar açıklama yeterli duruyor.

#### Docker Engine (Docker Daemon)

Docker ekosistemindeki Hypervisor'ün tam olarak karşılığıdır. Linux Kernel'inde bulunan LXC'nin yerini almıştır. İşlevi Container'ların birbirlerinden izole bir şekilde, Image'larda tanımlarının yapıldığı gibi çalışmaları için gerekli yardım ve yataklığı yani ortamı sağlamaktır. Container'ın bütün yaşam döngüsünü, dosya sistemini, verilen CPU ve RAM sınırlamaları ile çalışması vb bütün karmaşık (işletim sistemine yakın seviyelerdeki) işlerin halledildiği bölümdür.

#### Docker CLI (Command-Line Interface)

Kullanıcının Docker Engine ile konuşabilmesi için gerekli komut setini sağlar. Registry'den yeni bir Image indirilmesi, Image'dan yeni bir Container ayağa kaldırılması, çalışan Container'ın durdurulması, yeniden başlatılması, Container'lara işlemci ve RAM sınırlarının atanması vb komutların kullanıcıdan alınarak Docker Engine'e teslim edilmesinden sorumludur. Bu blog'un ilerleyen bölümlerinde sık sık Docker CLI'ı kullanarak Docker'ı tanımaya devam edeceğiz.

#### Docker Registery

Zaten bir teknoloji harikası olan Docker'ı daha da kullanılabilir ve değerli kılan bir özellik bütün açık kaynak sistemler gibi paylaşımı özendirmesi, adeta işin merkezine koymasıdır. [DockerHub](https://hub.docker.com)'da topluluğun ürettiği Image'lar ücretsiz ve sınırsız indirilebilir, oluşturulan yeni Image'lar gerek topluluk ile gerekse kişisel veya şirket referansı için açık kaynaklı (ücretsiz) veya kapalı kaynaklı (ücretli) yüklenebilir ve sonradan indirilebilir. Cloud'da hizmet veren DockerHub'ın yanında Image'larını kendi Private Cloud'unda tutmak isteyenler için Docker'ın sunduğu Private Registery hizmeti de vardır.

Sözün özü Container'lar Image'lardan oluşturulur. Image'larsa ortak bir eforun sonucu olarak meydana gelir ve Docker Registery'lerde tutulur. Örnek olarak, Ubuntu'nun üreticisi [Canonical](http://www.canonical.com/) DockerHub'da Official Repository'ler tutmakta ve Ubuntu versiyonlarını [bu repository](https://hub.docker.com/r/library/ubuntu/)'lerde yayınlamaktadır. Ubuntu Image'ını kullanarak bir container oluşturmak isteyen kişiler direkt olarak bu imajı kullanabilirler. İkinci bir kullanım senaryosu olarak, sağlanan bu Ubuntu Image'ını kullanarak başka bir işlev gerçekleştiren, örneğin Nginx ile statik web server hizmeti veren, bir Image yaratıp bunu DockerHub'da yayınlamak, yani hem kendi hem de başkalarının kullanımına sunmak verilebilir.

#### Docker Repository

Bir grup Image'ın oluşturduğu yapıdır. Bir repository'deki değişik Image'lar tag'lanarak etiketlenir böylece değişik versiyonlar yönetilebilir. İlerleyen bölümlerde Image versiyonlama konusunda örnekler vereceğiz.

### Docker CLI - Uzun Bir Tur

Bu bölümde Docker CLI'ı kullanarak yukarıda anlattığımız bileşenler ve terminolojileri örnekleyerek pekiştirmeye çalışacağız. Ben komutları Mac OS X'te çalıştırıp çıktılarını paylaşacağım ancak bütün komutlar Windows ve Linux sistemlerde de aynen çalışacaktır fakat üzerinde çalışılan sisteme göre farklı çıktılar üretecektir.

1. Öncelikle Docker kurulumumuzun doğru çalışıp çalışmadığını kontrol edebilmek için `docker version` komutunu verin.

        Gokhans-MacBook-Pro:~ gsengun$ docker version
        Client:
        Version:      1.12.0
        API version:  1.24
        Go version:   go1.6.3
        Git commit:   8eab29e
        Built:        Thu Jul 28 21:04:48 2016
        OS/Arch:      darwin/amd64
        Experimental: true

        Server:
        Version:      1.12.0
        API version:  1.24
        Go version:   go1.6.3
        Git commit:   8eab29e
        Built:        Thu Jul 28 21:04:48 2016
        OS/Arch:      linux/amd64
        Experimental: true

    Çıktıtan görebileceğiniz üzere `docker version` komutu hem Client (Docker CLI) hem de Server (Docker Engine) için ayrı ayrı versiyon bilgisi dönmektedir. Burada önceki bölümlerde anlattığımız bir konuya dikkatinizi çekmek istiyorum. Client'ta Mac OS X kullandığım için `darwin/amd64` olan `OS/Arch` tipi Docker Engine'de `linux/amd64` görünüyor çünkü Daemon Mac OS X içindeki bir Hypervisor tarafından çalıştırılan Linux makinede koşturuluyor.

2. İlk adımda Docker kurulumumuzun başarılı olduğu tespitini yaptıktan sonra [DockerHub](http://hubs.docker.com)'dan ilk Image'ımızı download edelim ve Image'ımızı listeleyelim.

    `hello-world` isimli Image'ın DockerHub'dan bir kopyasını indirmek için `docker pull hello-world` komutunu verin. Aşağıdaki gibi bir çıktı elde etmelisiniz.

        Gokhans-MacBook-Pro:~ gsengun$ docker pull hello-world
        Using default tag: latest
        latest: Pulling from library/hello-world
        c04b14da8d14: Pull complete
        Digest: sha256:0256e8a36e2070f7bf2d0b0763dbabdd67798512411de4cdcf9431a1feb60fd9
        Status: Downloaded newer image for hello-world:latest

    Dikkat ettiyseniz `hello-world` Image'ı için herhangi bir versiyon belirtmedik. Bu sebeple Docker, ilk satırda, `latest` tag'li Image'ı seçip download ediyor. Sonra da Image'ın SHA256 Hash'ini (Digest) alarak onu ekranda gösteriyor.

    `docker images` komutunu verin, daha önceden başka bir Image indirmediyseniz aşağıdakine benzer bir çıktı elde etmeniz gerekir.

        Gokhans-MacBook-Pro:~ gsengun$ docker images
        REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
        hello-world               latest              c54a2cc56cbb        5 weeks ago         1.848 kB

3. Şimdi indirdiğimiz `hello-world` Image'ını çalıştırarak bir Container yaratalım. `docker run hello-world` komutunu verin. Önceki adımları eksiksiz tamamladıysanız aşağıdakine benzer bir çıktı elde etmeniz gerekir.

        Gokhans-MacBook-Pro:~ gsengun$ docker run hello-world

        Hello from Docker!
        This message shows that your installation appears to be working correctly.

        To generate this message, Docker took the following steps:
        1. The Docker client contacted the Docker daemon.
        2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
        3. The Docker daemon created a new container from that image which runs the
            executable that produces the output you are currently reading.
        4. The Docker daemon streamed that output to the Docker client, which sent it
            to your terminal.

        To try something more ambitious, you can run an Ubuntu container with:
        $ docker run -it ubuntu bash

        Share images, automate workflows, and more with a free Docker Hub account:
        https://hub.docker.com

        For more examples and ideas, visit:
        https://docs.docker.com/engine/userguide/

    Aslında çıktıda ne olup bittiği özetleniyor fakat biz bu Image'ı hazırlayanların düşündüğünden farklı hareket ettiğimiz için çıktıda belirtilen 1 ve 2 numaralı işlemleri biz bir önceki adımda `docker pull hello-world` adımı ile tamamlamıştık. Image'ı hazırlayanlar önce `docker pull hello-world` yerine direkt `docker run hello-world` komutunu çalıştıracağımızı öngörmüşler. `docker run` Image eğer daha önceden Pull edilmediyse öncelikle Image'ı Pull etmekte ve sonra çalıştırmaktadır.

    `docker run hello-world` komutunu verdiğimizde Daemon ilgili Image'dan yeni bir Container oluşturdu ve Container'ı çalıştırmaya başladı. Container da yukarıda okuduğumuz çıktıyı oluşturdu ve bu çıktı Daemon'dan Client'a gönderildi ve ekrana basıldı.

    Burada yavaş yavaş Docker gerçekleri ile yüzleşmeye başlıyoruz. Farklı bir açıdan bakarak olayı tekrar yorumlarsak aslında `hello-world` Image'ının tek işlevinin yukarıdaki `Hello from Docker!` ile başlayan çıktıyı oluşturmak olduğunu söyleyebiliriz. Bu Image tam olarak Docker'ın esansını (essence) ortaya koymaktadır. Her bir Image tek bir iş yapmak üzere hazırlanır, çalıştırıldığında o işi bir kere (`hello-world` Image'ının yaptığı gibi) ya da sürekli olarak (bir web sunucunun yapacağı gibi) yapar. İlerleyen bölümlerde bu konunun üzerinde çok çok detaylı duracağız çünkü burası bütün meselenin esansı, burayı anlarsak kalan kısımları anlamakta zorlanmayız.

4. Bu adımda çalıştırdığımız Container ile ilgili biraz bilgi edinmeye çalışalım. `docker ps` komutunu vererek çalışan Container'ları listeleyebiliriz. Bu komutu vererek devam edelim.

        Gokhans-MacBook-Pro:~ gsengun$ docker ps
        CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

    Eğer her şeyi doğru yaptıysanız siz de benim gibi ekranda sadece başlıkları görmelisiniz. Bu çıktıda bir hata yok çünkü `hello-world` Container'ımız bir kereye mahsus çalıştı, kendisine verilen misyonu (ekrana metin yazdırma) tamamladı ve çıktı (exited).

    Çalıştırılan koşan ve çıkış (exit) yapan Container'ları görmek için `docker ps -a` komutunu kullanabiliriz, kullanalım ve çıktıya bakalım.

        Gokhans-MacBook-Pro:~ gsengun$ docker ps -a
        CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
        e139e975009f        hello-world         "/hello"            2 minutes ago      Exited (0) 2 minutes ago                       angry_sammet

    Yukarıda görebileceğiniz gibi `e139e975009f` ID ile `angry_sammet` adında `/hello` komutunu çalıştıran bir Container 2 dakika önce koşturulmuş ve 2 dakika önce çıkış yapmış.

    Container ile ilgili daha detaylı bilgileri `docker inspect <container_id>` yani örneğimizde `docker inspect e139e975009f` komutu ile öğrenebiliriz ancak bu çaba bizi bu blog'daki pragmatik yaklaşımımızdan uzaklaştırır.

5. Bir önceki adımda çıkış yapan Container'ı tekrar başlatabiliriz. `docker start -a e139e975009f` komutu ile Container'ı tekrar çalıştırın ve çıktıyı gözlemleyin. `-a` parametresi stop durumda olan Container'ın tekrar başlatılırken terminal'in (komut satırı input/output'unun) Container'a tekrar attach edilmesinin (bağlanmasının) istendiğini belirtmektedir.

    `docker start -a e139e975009f` komutunu `-a` parametresi olmadan vermeyin deneyelim şimdi yani  `docker start e139e975009f` komutunu verin. Bu kez ekranda çıktı olmadığını sadece Container ID'nin yani `e139e975009f` ekrana tekrar basıldığını göreceksiniz. Bunun anlamı Container'ın başlatıldığı fakat bu kez terminal'in attach edilmediğidir. Peki terminal attach etmediğimiz için Container çalışmadı mı? Hayır çalıştı ve yine aynı çıktıyı üretti. `Detached` modda çalışan Container'ların çıktıları `docker logs <container_id>` komutu ile görülebilir. `docker logs e139e975009f` komutunu vererek çıktıyı gözlemleyin. Çıktıda `hello-world` Image'ının çıktısı birden fazla kereler basıldı ise nedenini bakalım bulabilecek misiniz?

6. Bu adımda çalıştırdığımız ve birkaç kere tekrar başlattığımız `hello-world` Container'ın silmeye çalışalım. `docker rm <container_id>` komutu ile çıkış yapmış Container'lar silinebilir. `docker rm -f <container_id>` komutu ile yani `-f` Force parametresi ile bir Container çalışır durumda bile olsa onu silebiliriz. Force opsiyonunu kullanmak yerine önce `docker stop <container_id>` ile Container'ı durdurmayı da seçebiliriz.

    `docker rm e139e975009f` komutu ile Container'ı silin. Aşağıdakine benzer bir çıktı elde etmelisiniz ve `docker ps -a` komutu artık çıktısında hiçbir Container'ı listelememeli.

        Gokhans-MacBook-Pro:~ gsengun$ docker rm e139e975009f
        e139e975009f

7. `hello-world` Image'ı 2MB'ın altında pek fazla faydalı bir şey yapmamıza imkan tanımayan fakat Container yaşam döngüsü ve Docker'ın çalışma prensibini güzel özetleyen bir Image'dı. Şimdi biraz daha göze hoş gelen işlemler yapmak için bir `Nginx` Image'ı başlatalım fakat bu kez önce Pull etmek yerine direkt çalıştıralım. Önceki bölümde direkt çalıştırdığımızda Docker'ın önce lokal Image'lara baktığını, eğer istenen Image lokalde yoksa DockerHub'dan çektiğini söylemiştik. `Nginx` Image'ını indirmek ve bu Image'dan Image içinde konfigüre edilmiş default web sitesini 8080 nolu portta sunmaya başlamak için `docker run -p 8080:80 nginx` komutunu koşturun.

    `hello-world` Image'ına benzer şekilde `Nginx` Image'ının download edildiği sonrasında çalıştırıldığı ve istekler beklemeye başladığını göreceksiniz.

    Image'ın download edilmesi bittikten sonra tarayıcınızı açarak adres satırına `http://localhost:8080` yazın. Aşağıdaki gibi bir ekran (`Nginx` test sayfası) görmelisiniz.

    {% include centeredImage.html url="/resource/img/DockerPart1/WelcomeToNginx.png" description="Nginx Output" %}
    
    Merakla son verdiğimiz komuttaki `-p 8080:80` parametrelerinin ne anlama geldiğini sormanızı bekliyordum nihayet sordunuz. `-p` parametresi kendisinden sonra verilen parametredeki portlar arasında port forwarding yani port yönlendirme yapar. İlk verilen port, örneğimizde 8080, host üzerindeki portu ikinci verilen port, örneğimizde 80, Container üzerindeki portu temsil eder. Yukarıdaki komutta Docker Engine'e Host'un 8080 numaralı portuna gelen isteklerin Container'ın 80 numaralı portuna göndermesini ifade ettik. Burada Host tahmin ettiğiniz gibi Docker komutlarını koşturduğumuz bilgisayarımız Container ise yeni oluşturduğumuz `Nginx` Container'ıdır. 

    Burada yine kafamızı kaldıralım ve ne olup bittiğine bir göz atalım. Daha önce yaptığımız gibi yeni bir Image'dan bir Container ürettik, burada enteresan bir şey yok. Host'un 8080 numaralı portuna gelen istekleri Container'ın 80 numaralı port'una yönlendirdik ve Container tarafından sunulan Nginx test sayfasına erişmiş olduk. Peki bu ikinci kısım nasıl gerçekleşti? Yani Nginx Container'ına 80 numaralı port'u dinlemesi gerektiğini kim söyledi ve 80 numaralı port'a gelen request'lerde test sayfasını göndermesini kim salık verdi?

    İşte Docker mucizesi yine tam da burada karşımıza çıkmaktadır. Official `Nginx` Image'ını hazırlayan arkadaşlar Nginx'i default olarak 80 numaralı portu dinlemeye ve bu porta gelen web isteklerini test web sitesine yönlendirmeye dolayısıyla da test ana sayfasını sunmak üzere ayarlamıştır. Dolayısıyla `Nginx` Image'ından oluşturulan Container'ın yegane amacı budur. Bu Nginx Image'ı başka bir görevi, daha anlamlı olarak kendi web sitemizi, sunmak üzere ayarlanabilir. [Bir sonraki blog](/docker-yeni-imaj-hazirlama/)'da bu konuya detaylı olarak eğileceğimizi tekrar söyleyerek devam edelim. 

8. Olayı biraz daha ilginçleştirelim ve bir önceki adımda çalıştırdığımız `Nginx` Container'ının 80 numaralı portu dinlemeye ve default web site'ı sunmak üzere nasıl ayarlandığına göz atalım.

    Yeni bir terminal açarak (mevcut terminalimiz Nginx Container'ına attach durumda olduğu için onu kullanamıyoruz) önceki adımlarda yaptığımız gibi çalışan Container'ları `docker ps` komutu ile sorgulayalım. Aşağıdakine benzer bir çıktı elde etmeniz gerekir.

        Gokhans-MacBook-Pro:~ gsengun$ docker ps
        CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                           NAMES
        54bad6cec3c4        nginx               "nginx -g 'daemon off"   4 minutes ago       Up 4 minutes        443/tcp, 0.0.0.0:8080->80/tcp   angry_bell

    Yukarıdaki çıktıdan çalıştırılan Container'ın ID'sinin `54bad6cec3c4` olduğu, komutunun `nginx -g 'daemon off` ile başladığı (komutun tamamını göremediğimize dikkat edin), 4 dakikadır çalıştığı ve host'un 8080 portundan Container'ın 80 portuna forwarding yapıldığı görülebilir.

    Açtığımız bu yeni terminalden Container'a attach olarak bazı komutlar çalıştırarak sistemi deşifre etmeye devam edelim. `docker exec -it <container_id> /bin/bash` komutu ile Container'a bir Bash Shell açabiliriz. `-i` interaktif terminali `-t` ise terminalin attach olmasını istediğimizi belirtir. `docker exec -it 54b /bin/bash` komutunu çalıştırın (Container ID'nin sadece baştan birkaç harfini vermemizin yettiğine -çakışma olmadığı müddetçe- dikkat edin). Aşağıdakine benzer bir görüntü elde edeceksiniz. Prompt'un nasıl değiştiğine ve Container ID'yi içerdiğine dikkat edin.

        Gokhans-MacBook-Pro:~ gsengun$ docker exec -it 54b /bin/bash
        root@54bad6cec3c4:/# ###### Kullanıcı root oldu bilgisayar adı da Container ID oldu

    Container'ın Bash'inde iken `ps -ef` komutunu verin ve Container içinde çalışan bütün process'leri listeleyin. Bende oluşan çıktı aşağıda.

        root@54bad6cec3c4:/# ps -ef
        UID        PID  PPID  C STIME TTY          TIME CMD
        root         1     0  0 00:06 ?        00:00:00 nginx: master process nginx -g daemon off;
        nginx        6     1  0 00:06 ?        00:00:00 nginx: worker process
        root         7     0  0 00:07 ?        00:00:00 /bin/bash
        root        14     7  0 00:13 ?        00:00:00 ps -ef    

    Gördüğünüz gibi Container tam olarak `nginx -g daemon off` ile çalıştırılmış dolayısıyla bir konfigürasyon dosyası verilmemiş. `more /etc/nginx/nginx.conf` komutunun çıktısından başka bir konfigürasyon dosyasının (`more /etc/nginx/conf.d/default.conf`) eklendiğini göreceksiniz. Bu konfigürasyon dosyasının içeriğine baktığınızda sunucunun localhost üzerinde 80 nolu portu dinlediği, root dizin olarak kendisine `/usr/share/nginx/html` klasörünü aldığını ve index dosyası olarak index.html ve index.htm dosyalarını sunmak üzere ayarlandığını görebilirsiniz.

        root@54bad6cec3c4:/# more /etc/nginx/conf.d/default.conf
        server {
            listen       80;
            server_name  localhost;

            location / {
                root   /usr/share/nginx/html;
                index  index.html index.htm;
            }

            # redirect server error pages to the static page /50x.html
            #
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   /usr/share/nginx/html;
            }
        }

    Son olarak isterseniz `more /usr/share/nginx/html/index.html` komutu ile tarayıcıdan gördüğümüz sayfanın kaynak koduna erişebilirsiniz.

9. `Nginx` Container'ı terminal'e Attached bir şekilde ayağa kalktı. Bu çoğu zaman istenen durum değildir. `-d` parametresi ile Container'ı Detached modda çalıştırabilir ve terminali bloklanmaktan kurtarabiliriz. Detached modda çalışan Container'ların ID'lerini `docker ps` komutu ile elde edebilir, `docker kill <container_id>` komutu ile de Container'ı acil çıkışa zorlayabiliriz.

Şimdilik bu kısımda anlatacaklarım bu kadar. Bir sonraki bölümde bulunan Cheat Sheet çok işimize yarayacak. Orada da yeri geldikçe ekstra açıklamalar yapacağım.

### Docker CLI - Cheat Sheet (Kopya Kağıdı)


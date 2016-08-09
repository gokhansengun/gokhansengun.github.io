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
* Docker'ın kullanım alanlarını inceleyeceğiz ve yazıyı böylece kapatağız.

## Doğuş Hikayesi

### Tarihçe

Klasik olarak bir tanımla başlamamız gerekirse Docker, dünyada en çok kullanılan yazılım konteynerleştirme platformudur. Konteynerleştirme konteyner içine koyma anlamına gelir. Docker, Linux Kernel'e 2008 yılında eklenen Linux Containers (LXC) üzerine kurulu bir teknolojidir. LXC, Linux'da aynı işletim sistemi içerisinde birbirinden izole olmuş bir biçimde çalışan container'lar (Linux tabanlı sistemler) sağlamaktadır. Anlaşıldığı üzere LXC, işletim sistemi seviyesinde bir sanallaştırma (virtualization) altyapısı sunmaktadır. Container'lar içerisinde aynı işletim sistemi tarafından çalıştırılan process'lere, LXC tarafından işletim sisteminde sadece kendileri koşuyormuş gibi düşünmeleri için bir sanallaştırma ortamı sağlanmıştır. LXC, container'lara işletim sistemi tarafından sunulan dosya sistemi, ortam değişkenleri (Environment Variable), vb fonksiyonları her bir container'a özgü olarak sağlar. Aynı işletim sistemi içerisinde çalışmalarına rağmen container'lar birbirlerinden izole edilmişlerdir ve birbirleri ile istenmediği müddetçe iletişime geçemezler. Bütün bu özelliklerin nasıl pek yararlı fonksiyonlara dönüştürüleceği noktasına birazdan geleceğiz. Biraz daha LXC, Docker ve klasik sanallaştırma üzerinden devam edelim.

VMware, Xen, Hyper-V gibi Hypervisor'ler (sanallaştırma platformları), yönettikleri fiziksel veya sanal bilgisayarlar üzerine farklı işletim sistemleri kurulmasına olanak tanımaktadırlar. Günümüzde veri merkezleri (data center) çok büyük oranda sayılan Hypervisor'ler tarafından sanallaştırılmışlardır, Cloud (Bulut) olarak adlandırılan kavramın altyapı kısmını oluşturan geniş veri merkezleri tamamıyla Hypervisor'ler tarafından yönetilmektedir. Hypervisor platformları sayesinde fiziksel olarak işletilen güçlü sunucular, ihtiyaç ölçüsünde farklı işletim sistemleri (kimi zaman hem Windows hem de Linux aynı fiziksel sunucuda) kurularak kolaylıkla işletilebilmektedir. Sanallaştırılan farklı işletim sistemlerinin, Hypervisor tarafından fiziksel sunucu üzerinde kendisine sağlanan disk bölümlerine kurulması gerekmektedir. LXC'nin Hypervisor'e göre sağladığı avantajların en önemlilerinden birisi aynı işletim sistemi içerisinde sunabilmesidir. Böylelikle sanallaştırma için gerekli disk alanından önemli bir tasarruf sağlanmaktadır. Sanal olarak koşturulan işletim sistemlerinin her birinin 7GB disk alanı gerektirdiğini düşünelim. Hypervisor'lerle 64 core'luk işlemciye sahip bir bilgisayara 20 adet sanal sunucu kurmak istediğimizde 20 x 7GB = 140GB bir disk alanına ihtiyacımız olacaktır. 20 adet sanal sunucu kurmak yerine LXC ile sanallaştırma yaptığımızda ise sadece 7GB'lık bir disk alanı bize yeterli olacaktır.

Hyporvisor'lerle yapılan sanallaştırma herbir işletim sisteminin ayrı ayrı bakımının (güncellenmelerin ve güvenlik yamalarının) yapılması gerekmektedir. Tek işletim sistemi içerisinde LXC kullanılarak yapılan sanallaştırmada ise bir işletim sisteminin bakımı yapılarak daha ekonomik bir biçimde bakım yapılabilir. LXC ile Hyporvisor'ler arasındaki farklar biraz daha uzatılabilir ancak bizi esas konumuzdan uzaklaştırır. Temel olarak LXC, container açısından standart bir Linux kurulumundan hiçbir farklı olmayan fakat aynı çekirden (kernel) üzerinde koşan bir ortam sağlamaktadır. LXC 2008 yılında ortaya çıkmasına ve kendisine farklı alanlarda ciddi kullanım alanı bulmasına rağmen onu hakettiği geniş kitlelerle buluşturan 2013 yılında ortaya çıkan Docker'dır.

### LXC'den Docker'a Geçiş

Açık konuşmak gerekirse Docker, LXC'nin zengin mirasının üzerine oturmuştur fakat LXC'de manuel olarak yapılan işlemleri ustaca paketleyerek standardize etmiştir. Docker, LXC'nin sunduğu kapsamlı fonksiyonları ve konfigürasyonları detaylarından arındırarak tabiri caizse halka indirmiştir. Docker'ın getirdiği en önemli özellik container'ın yapısını metin bazlı imaj formatı ile (detaylarına sonradan değineceğiz) tanımlamasıdır. Bu sayede aynı imaj formatı kullanılarak aynı özellikteki container'lar kolaylıkla yaratılabilir, başka kişilerle Docker Registery üzerinden paylaşılabilir ve kolaylıkla genişletilebilir (farklı fonksiyonlar eklenebilir). Docker'ın LXC'ye göre getirdiği temel farklılıklardan bir başkası Docker'ın kullanıcılarını aynı container'da sadece ve sadece tek process çalıştırmaya adeta zorlamasıdır. Birçoğumuz aşağıdaki caps'i görmüşüzdür. Kod silerek bug çözdüğünü iddia eden biri var. Aslında burada Docker'ın yaptığı da benzer bir şey bana göre. Docker, LXC'nin kullanıcıya sunduğu fonksiyonu daraltarak aslında daha kullanılabilir ve daha çok işe yarar bir yapı elde etmiştir. Aynı container'ın birden çok process yerine tek process çalıştırması container'ların tekrar tekrar, kolaylıkla, genişletilebilir ve daha anlaşılabilir bir biçimde kullanılmasını sağlamaktadır. Bu kısmı ilerleyen blog'larda detaylı bir şekilde defalarca örnekleyeceğiz, şimdilik küçük bir örnek olarak, oluşturacağımız sistemde bir web server, bir app server ve bir database server olduğunu düşünelim. Docker'ın önerdiği yapı bu üç bileşenin tek bir container içine konması yerine ayrı ayrı container'larda çalıştırılmasıdır. 

{% include centeredImage.html url="/resource/img/DockerPart1/FixedABugByDeletingCode.jpg" description="New Test Plan" %}

Ayrı ayrı container'lar içinde çalıştırılan bileşenler (app server, web server, vb) gerektiği durumlarda teker teker genişletilebilir. Örneğin web server'ın istekleri karşılamada yetersiz olduğu görülürse web server container'ından bir veya daha fazla ekstra container yaratılarak gerekli işlem gücü diğer bileşenlerden (app server ve database server) bağımsız olarak sağlanmış olur. Eğer üç bileşeni aynı container'a koysaydık ek web server isteğinde bu üç bileşeni birden içeren yeni bir container'ı ayağa kaldırıp burada sadece web server'ın çalışması için gerekli konfigürasyon ve kod değişikliğinin yapılması gerekecekti. Bu yapı aslında gün geçtikçe daha da popüler hale gelen Microservices trendini destekleyici bir özelliktir. Mikro servisler temellerini 1970'lerde Unix'ten "Do one thing and do it well" yani "Sadece bir şey yap ve iyi yap" olarak tercüme edilebilecek felsefeden almaktadır. Unix/Linux komut satırı fonksiyonlarını detaylı bir biçimde kullananlar ne demek istediğimi eminim daha iyi anlamışlardır. 

Son olarak Docker geliştirmesinin en başlarında bence çok doğru bir kararla LXC bağımlılığını kaldırarak kendi bünyesinde LXC'yi yeniden kodlayarak libcontainer adında kendisi ile birlikte dağıtmaya başlamıştır. Bu kararı almalarındaki en önemli iki neden Docker'ın hızlı geliştirilebilmesi için Linux Kernel'den ayrı ve seçimleri Linux Çekirdeği geliştiricileri yerine kendilerinin alabileceği bir proje yaratmak ve mümkün olduğunca Linux Distro bağımlılıklarını kaldırmak olarak sıralanabilir. Bu konuyu daha fazla uzatmadan burada bağlayarak devam edelim.

## Kurulum ve Mimari

Başlık biraz yanıltıcı olabilir. Docker'ın kurulum detayları aşağıdaki linklerde çok detaylı ve ek izaha gerek bırakmayacak kadar güzel açıklanmış. Kullanıdığınız platforma göre aşağıdaki linklerden kurulum yapabilirsiniz. Ben burada biraz daha büyük resmi göstermeye çabalayacağım.

### Kurulum

- [Windows](https://docs.docker.com/engine/installation/windows)
- [Mac OS X](https://docs.docker.com/engine/installation/mac/)
- [Linux](https://docs.docker.com/engine/installation/)

### Mimari

Baştan beri Docker'ın Linux Kernel'inden destek alarak ortaya çıkan ve Linux İşletim Sistemi üzerinde çalışan bir sistem olduğunu yazdık. Peki nasıl oluyor da Docker Linux dışında hem Windows hem de Mac OS X'te kullanılabiliyor? Docker temel iki parçadan oluşmaktadır. Birincisi Linux Kernel'la direkt iletişim halinde olan Docker Engine, ikincisi ise bu Engine (Motor) ile iletişim kurmamıza olanak tanıyan Docker CLI (Command-Line Interface)'dır. Linux'ta hem Docker Engine hem de Docker CLI doğal olarak direkt Linux üzerinde koşmaktadır. Windows ve Mac OS X'te ise Docker CLI Windows ve Mac OS X işletim sistemleri üzerinde koşmakta, Docker Engine ise bu işletim sistemlerinde bir Hypervisor (duruma göre VMware, VirtualBox, Hyperkit, Hyper-V) yardımıyla çalıştırılan Linux üzerinde koşmaktadır.

Windows ve Mac OS X'te (konfigüratif olarak aynı zamanda Linux'ta da) Docker CLI ve Docker Engine TCP ile haberleşmektedirler. Docker CLI'dan verilen komutlar TCP ile Engine'e iletilmekte ve işlenip cevaplanmaktadır. Aralarında TCP haberleşmesi bulunduğundan aralarında TCP bağlantısı kurulabilen herhangi bir Docker CLI (Client) ile Docker Engine'i konuşturmak mümkündür. İşte anlatılan bu yöntemle Windows ve Mac OS X'te Docker çalıştırmak mümkün hale gelmektedir. Bu kadar anlatmışken Linux'ta default olarak aynı makine üzerindeki CLI ile Engine'in Unix socket'ler üzerinden konuştuğunu ve daha hızlı çalıştığını vurgulamakta fayda var.

Windows ve Mac OS X'teki mimari aşağıdaki şekilde resmedilmiştir.

{% include centeredImage.html url="/resource/img/DockerPart1/DockerOnWindows.svg" description="Docker on Windows" %}
 
## Terminoloji

Docker yepyeni ve Linux bazlı bir teknoloji olduğu için hem kendi terimleri hem de bazı Linux terimleri birçoğumuza ilk bakışta biraz yabancı gelecek fakat çabucak ısınacağımızı umuyorum.

### Container

Docker Engine tarafından Linux çekirdeği içerisinde birbirinden izole olarak çalıştırılan process'lerin her birine verilen isimdir. Virtual Machine (Sanal Makina) analojisinde Docker'ı Hypervisor'e benzetirsek fiziksel sunucu üzerinde halihazırda koşturulmakta olan herbir işletim sisteminin Docker'daki karşılığı Container'dır. Milisaniyeler içerisinde başlatılabilir, istenen herhangi bir anda duraklatılabilir (Pause), tamamen durdurulabilir (Stop) ve yeniden başlatılabilirler. 

### Image ve Dockerfile

Docker Engine ile çalıştırılacak Container'ların baz alacağı işletim sistemi veya başka imajı, dosya sisteminin yapısı ve içerisindeki dosyaları, koşturacağı programı (veya bazen çok tercih edilmemekle birlikte programları) belirleyen ve içeriği metin bazlı bir Dockerfile (yazımı tam olarak böyle, ne dockerfile ne DockerFile ne de DOCKERFILE) ile belirlenen binary'ye verilen isimdir.

Hatırlarsanız Docker'ın doğuşunu anlattığımız ilk bölümde Docker'ın oyunu değiştiren bir hamle yaparak LXC'ye göre fonksiyon kıstığınını ve böylece başarılı olduğunu söylemiştik. İşte Docker, koşturulacak container'ların iskeletini oluşturan her bir imajın bir Dockerfile ile tanımlanmasını gerekli kılar. Bu Dockerfile içerisinde imajın hangi imajı baz aldığı, hangi dosyaları içerdiği ve hangi uygulamayı hangi parametrelerle koşturacağı açık açık verilir. Dockerfile'ın içeriğini ve yeni bir Dockerfile dolayısıyla da yeni bir Image oluşturmayı [bir sonraki](/docker-yeni-imaj-hazirlama/) blog'da ziyade detayda ele alacağız. Bu blog'un amaçları doğrultusunda bu kadar açıklama yeterli duruyor.

### Docker Engine (Docker Daemon)

Docker ekosistemindeki Hypervisor'ün tam olarak karşılığıdır. Linux Kernel'inde bulunan LXC'nin yerini almıştır. İşlevi Container'ların birbirlerinden izole bir şekilde, Image'larda tanımlarının yapıldığı gibi çalışmaları için gerekli yardım ve yataklığı yani ortamı sağlamaktır. Container'ın bütün yaşam döngüsünü, dosya sistemini, verilen CPU ve RAM sınırlamaları ile çalışması vb bütün karmaşık (işletim sistemine yakın seviyelerdeki) işlerin halledildiği bölümdür.

### Docker CLI (Command-Line Interface)

Kullanıcının Docker Engine ile konuşabilmesi için gerekli komut setini sağlar. Registry'den yeni bir Image indirilmesi, Image'dan yeni bir Container ayağa kaldırılması, çalışan Container'ın durdurulması, yeniden başlatılması, Container'lara işlemci ve RAM sınırlarının atanması vb komutların kullanıcıdan alınarak Docker Engine'e teslim edilmesinden sorumludur. Bu blog'un ilerleyen bölümlerinde sık sık Docker CLI'ı kullanarak Docker'ı tanımaya devam edeceğiz.

### Docker Registery

Zaten bir teknoloji harikası olan Docker'ı daha da kullanılabilir ve değerli kılan bir özellik bütün açık kaynak sistemler gibi paylaşımı özendirmesi, adeta işin merkezine koymasıdır. [DockerHub](https://hub.docker.com)'da topluluğun ürettiği Image'lar ücretsiz ve sınırsız indirilebilir, oluşturulan yeni Image'lar gerek topluluk ile gerekse kişisel veya şirket referansı için açık kaynaklı (ücretsiz) veya kapalı kaynaklı (ücretli) yüklenebilir ve sonradan indirilebilir. Cloud'da hizmet veren DockerHub'ın yanında Image'larını kendi Private Cloud'unda tutmak isteyenler için Docker'ın sunduğu Private Registery hizmeti de vardır.

Sözün özü Container'lar Image'lardan oluşturulur. Image'larsa ortak bir eforun sonucu olarak meydana gelir ve Docker Registery'lerde tutulur. Örnek olarak, Ubuntu'nun üreticisi [Canonical](http://www.canonical.com/) DockerHub'da Official Repository'ler tutmakta ve Ubuntu versiyonlarını [bu repository](https://hub.docker.com/r/library/ubuntu/)'lerde yayınlamaktadır. Ubuntu Image'ını kullanarak bir container oluşturmak isteyen kişiler direkt olarak bu imajı kullanabilirler. İkinci bir kullanım senaryosu olarak, sağlanan bu Ubuntu Image'ını kullanarak başka bir işlev gerçekleştiren, örneğin Nginx ile statik web server hizmeti veren, bir Image yaratıp bunu DockerHub'da yayınlamak, yani hem kendi hem de başkalarının kullanımına sunmak verilebilir.

### Docker Repository

Bir grup Image'ın oluşturduğu yapıdır. Bir repository'deki değişik Image'lar tag'lanarak etiketlenir böylece değişik versiyonlar yönetilebilir. İlerleyen bölümlerde Image versiyonlama konusunda örnekler vereceğiz.
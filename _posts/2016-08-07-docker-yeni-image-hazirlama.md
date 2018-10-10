---
layout: post
title: "Docker Bölüm 2: Yeni bir Docker Image'ı Nasıl Hazırlanır?"
level: Başlangıç
lang: tr
ref: docker-part-2
blog: yes
---

Docker blog serimizin ilk bölümünde Docker nedir, nasıl çalışır ve nerede kullanılır sorularına cevap aramış ve Docker'a detaylı bir giriş yapmıştık. Önceki blog'da bahsettiğimiz gibi [DockerHub](https://hub.docker.com) gerek official (Ubuntu, Nginx, Redis, vb) gerekse de bu Image'lardan türetilen ve farklı özellikler barındıran birçok farklı ve çok faydalı Image içermektedir. Bu Image'lar ihtiyaçlarımızı çok büyük oranda karşılasa da kısa sürede gerek official gerekse de diğer repository'lerdeki Image'ları özelleştirme ihtiyacı ortaya çıkmaktadır. Blog serimizin ikinci bölümü olan bu blog'da Docker'ın sunduğu zengin özelleştirme araçlarını kullanarak mevcut Docker Image'larını özelleştirerek ihtiyaçlarımıza uygun hale getireceğiz ve bir yandan da Docker'ı bu vesile ile daha yakından tanımış olacağız. 

Docker blog serisinin ilki aşağıda verilmiştir. Eğer daha önce okumadıysanız bu blog'u da okumanız tavsiye edilir.

[Docker Bölüm 1: Nedir, Nasıl Çalışır, Nerede Kullanılır?](/docker-nedir-nasil-calisir-nerede-kullanilir/)

Docker Image hazırlamayı gösteren bu ikinci blog'da da günlük kullanım örneklerine pek değinemeyeceğiz. Docker'ın pratik kullanım alanlarını aşağıda linki verilen blog'da özetlemeye gayret edeceğiz. Bu blog'u okuduktan sonra onu okumanızı tavsiye ederim.

[Docker Bölüm 3: Docker Compose Hangi Amaçlarla ve Nasıl Kullanılır?](/docker-compose-nasil-kullanilir/)

### Çalışma Özeti

Bu blog'da aşağıdaki adımları tamamlayarak Docker'ı daha etkili kullanmak ve ihtiyaçlarımız için özelleştirme ile ilgili detaylı bilgileri tanıtmaya ve örneklemeye çalışacağız.

* Motivasyon olması açısından basit bir Image oluşturup, çalıştırıp DockerHub'a Push edip başkalarının kullanımına sunarak başlayacağız.
* Dockerfile'ın yapısını ve Instruction'ları (komut) inceleyerek devam edeceğiz.
* Ubuntu baz Image'ını özelleştirerek üzerine Nginx kuracağız ve Nginx ile basit bir web sayfasını sunacağız.

### Ön Koşullar

Bu blog'da yer verilen adımları takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker CLI ile ilgili genel bilgi sahibi olmak.
* Ubuntu paket yükleme (apt-get) sistemine başlangıç düzeyinde aşinalık.
* Docker ile ilgili [blog serisinin ilk blogunda'da](/docker-nedir-nasil-calisir-nerede-kullanilir/) anlatılan düzeyde bilgi sahibi olmak.

### Dockerfile - Giriş

Önceki blog'da Docker'ın LXC'ye göre getirdiği en önemli özelliklerden birisinin koşturduğu Container'ın yapısını metin bazlı bir dosya ile tutması ve böylece Image'dan Container oluşturma işlemini standardize ve tekrarlanabilir kılması olduğunu belirtmiştik. Container yapısının metin bazlı olarak tutulduğu dosya Dockerfile'dır. Dosya sistemine eklenen Dockerfile (tam olarak böyle yazılmalıdır çünkü Docker CLI büyük küçük harf duyarlıdır) içindeki Instruction'lar (yönergeler) Docker Daemon tarafından okunur, değerlendirilir ve yeni bir Image bu Instruction'lar çerçevesinde oluşturulur.

### Basit Image Hazırlama ve DockerHub'a Push Etme

Yeni bir Image oluşturmak çok basittir. Yeni Image'ın nasıl oluşturulacağını özetleyen Dockerfile bir klasöre konulur ve terminalde bu klasöre gidilerek `docker build .` komutu çalıştırılır. Oluşan Image `docker images` komutu ile görülebilir.

1. Hemen çok basit bir Image oluşturarak başlayalım. Dosya sistemi üzerinde düzenli olması açısından yeni bir klasör oluşturun ve bu klasör içinde Dockerfile adında bir dosya oluşturun. Dockerfile'ın uzantısı olmadığına lütfen dikkat edin. Windows kullanıyorsanız klasör görünümünde dosya uzantılarının göründüğünden ve yeni oluşturduğunuz dosyaya default `.txt` uzantısının verilmediğinden emin olun. En güzeli dosyayı komut satırından veya metin editörü ile yaratmaktır. Komut satırından Windows'ta `echo. 2>Dockerfile`, Mac OS X ve Linux'ta ise `touch Dockerfile` yazarak ilgili klasörde bir Dockerfile yaratabilirsiniz.

2. Oluşturduğunuz Dockerfile'ı bir metin editörü ile açarak aşağıdaki satırları girin.

        FROM ubuntu:latest

        MAINTAINER Gokhan Sengun <gokhansengun@gmail.com>

    Yukarıda verilen iki satırla yeni oluşturacağımız Image'ın official `ubuntu` Image'ının `latest` Tag'inden türetileceğini yani o Image'ı baz alacağını `FROM ubuntu:latest` Instruction'ı ile belirtiyoruz. Image'ı hazırlayan kişi olarak da önce ad soyad sonra da `<>` işaretleri arasında email'imizi yazıyoruz.

    Oluşturacağımız bu Image'ın DockerHub tarafından dağıtılan official `ubuntu` Image'ından hiçbir farkı olmayacak. 

3. Şimdi Docker CLI'dan `docker build .` komutunu verin, aşağıdaki gibi bir çıktı elde etmelisiniz.

        Gokhans-MacBook-Pro:DockerfileBlog gsengun$ docker build .
        Sending build context to Docker daemon 2.048 kB
        Step 1 : FROM ubuntu:latest
        ---> 2fa927b5cdd3
        Step 2 : MAINTAINER Gokhan Sengun <gokhansengun@gmail.com>
        ---> Running in 471e40634b23
        ---> a748835505b2
        Removing intermediate container 471e40634b23
        Successfully built a748835505b2 

    Çıktının ilk satırında `Sending build context to Docker daemon`'dan DockerCLI'ın yapmak istediğimiz build işlemi için mevcut bilgileri Docker Daemon'a gönderdiğini görebiliyoruz. Sonraki çıktılar Daemon'dan gelen ve Dockerfile'daki Instruction'ların uygulanması ile ilgili. Docker Daemon Dockerfile içerisindeki her bir Instruction'ı birer Step (adım) olarak değerlendirmiş ve Image'ı başarılı bir şekilde oluşturmuştur. Komut satırından `docker images` komutunu verin, aşağıdakine benzer bir çıktı elde etmelisiniz. Aşağıdaki çıktıda `IMAGE ID` kolonunda verilen değerin (a748835505b2) yukarıdaki çıktıdaki en son satırda verilen Image ID olduğuna dikkat edin.  

        REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
        <none>                    <none>              a748835505b2        4 minutes ago       122 MB
        gsengun/jmeter3.0         1.7.1               055a31dd0034        2 days ago          736.6 MB
        mono                      4.4.0.182-onbuild   15129f680b3b        13 days ago         771.7 MB

    `docker images` çıktısında yeni oluşturduğumuz bu Image'ın diğer Image'lardan biraz farklı olduğu dikkatinizi çekecek. `REPOSITORY` ve `TAG` kolonları boş kalmıştır. Yukarıdaki çıktıda yeni oluşturduğumuz Image'a ek olarak daha önceden kullanılan Host'ta bulunan iki farklı Image daha göreceksiniz. Bu Image'lardan `mono` direkt olarak ifade edilmiş, `gsengun/jmeter3.0` ise bir namespace (gsengun) ile gösterilmiştir. Önceki blog'da da açıkladığımız gibi official repository'ler başlarında bir namespace `gsengun` olmadan verilirler yani global namespace'delerdir, DockerHub'da bulunan diğer Image'larda ise örnek verdiğim Image gibi başında bir namespace (gsengun gibi) bulunması zorunludur. Böylelikle Image'lar arasındaki isim çakışmaları önlenmektedir. 

4. Yukarıda oluşturduğumuz Image'a Tag ve Repository eklemek için `docker tag` komutunu kullanabiliriz. Aşağıdakine benzer bir komutu `gsengun`'ü kendi namespace'iniz ile değiştirerek komut satırından verin. Image'ları DockerHub'a gönderecekseniz namespace'in DockerHub kullanıcı adınız (Docker Hub ID) olması gerektiğini unutmayın.

        docker tag a748835505b2 gsengun/myubuntu:0.1

    Burada `a748835505b2`'nin önceki adımlarda build ettiğimiz Image'ın ID'si olduğuna dikkatinizi çekerim. Şimdi tekrar `docker images` komutunu vererek çıktıyı gözlemleyin. Artık `REPOSITORY` ve `TAG` kolonlarının da verdiğimiz bilgilerle doldurulmuş olduğunu göreceksiniz.

        Gokhans-MacBook-Pro:DockerfileBlog gsengun$ docker images
        REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
        gsengun/myubuntu          0.1                 a748835505b2        About an hour ago   122 MB
        gsengun/jmeter3.0         1.7.1               055a31dd0034        3 days ago          736.6 MB
        mono                      4.4.0.182-onbuild   15129f680b3b        13 days ago         771.7 MB

    Bu arada Image'ı ayrı ayrı build etmek ve Tag'lemek yerine Tag'leme işlemini build sırasında yapabilirdik. Bunun için vermemiz gereken komut `docker build myubuntu .` yerine `docker build -t gsengun/myubuntu:0.1 .` komutunu olacaktı.

5. Bu adımda oluşturduğumuz Image'ı çalıştırarak test etmemiz ve her şeyin istediğimiz gibi olduğunu kontrol etmemiz gerekiyor. Tabii bizim ilk Image'ımız Ubuntu'nun bire bir aynısı olduğu için aslında bu adımı pas geçebilirdik ancak yine de deneyelim. Ekrana "Ubuntu'dan Merhaba Docker" yazıp çıkan (Exit eden) bir Container yaratalım.

        Gokhans-MacBook-Pro:DockerfileBlog gsengun$ docker run gsengun/myubuntu:0.1 echo "Ubuntu'dan Merhaba Docker"
        Ubuntu'dan Merhaba Docker

6. Oluşturduğumuz ve başarılı bir şekilde test ettiğimiz bu Image'ı şimdi DockerHub'a gönderelim. Tahmin ettiğiniz gibi öncelikle bu işlem için DockerHub'da kaydınız olması gerekiyor. [DockerHub](https://hub.docker.com/) adresine giderek `New to Docker?` başlığı altında bulunan bilgileri girerek `Sign Up` butonuna tıklayın. Burada seçtiğiniz Docker Hub ID sizin Image'larınıza vereceğiniz namespace olacak.

    Kayıt işlemini tamamladıktan sonra komut satırından `docker login` komutunu vererek önce Docker Hub ID'nizi sonra da şifrenizi vererek kimliğinizi doğrulayıp login işlemini tamamlayın. Aşağıdakine benzer bir çıktı göreceksiniz.

        Gokhans-MacBook-Pro:DockerfileBlog gsengun$ docker login
        Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
        Username (gsengun): gsengun
        Password: ****************
        Login Succeeded

7. Komut satırında DockerHub kimlik doğrulama işlemini gerçekleştirdikten sonra şimdi yeni oluşturduğumuz Image'i Push edebiliriz. Aşağıdaki komutta `gsengun`'ü kendi DockerHub ID'nizle değiştirerek verin ve işlemin bitmesini bekleyin.

        Gokhans-MacBook-Pro:DockerfileBlog gsengun$ docker push gsengun/myubuntu:0.1
        The push refers to a repository [docker.io/gsengun/myubuntu]

    Tarayıcınızdan [DockerHub](https://hub.docker.com)'a girerek login olduğunuzda aşağıdaki gibi Image'ımızın DockerHub'dan insanlığın kullanımına sunulduğunu göreceksiniz.

    {% include image.html url="/resource/img/DockerPart2/ImagePushedToDockerHub.png" description="Image pushed to DockerHub" %}

### Dockerfile'ın Yapısı ve Instruction'ları

Dockerfile metin bazlı fakat YAML, JSON, XML tarzı herhangi bir serializasyon formatı içermeyen satır bazlı olarak Instruction'ları (komut) ayıran bir dosyadır. Genel olarak Instruction'ların formatı aşağıdaki gibidir. `#` ile başlayan bütün satırlar yorum olarak değerlendirilmektedir.

    INSTRUCTION argümanlar

Bir önceki bölümde `FROM` ve `MAINTAINER` Instruction'larını kullanmış ve işlevlerini dile getirmiştik. Şimdi diğer Instruction'lara sırayla bakalım.

##### RUN 

Build işlemi sırasında koşturulması gereken komutları belirtmek için kullanılır. Örneğin baz `ubuntu` Image'ında bulunmayan bir paketin (örneğin `ping`) oluşturulacak Image'a eklenmesi isteniyorsa `RUN apt-get install -y iputils-ping` Instruction'ı Dockerfile'a eklenerek Image oluşturulması sırasında Image'a bu paket eklenmiş olur.

##### CMD

İlk blog'da üzerinde defalarca durulduğu gibi Docker Daemon bir Image'dan Container oluşturulması sürecinde, Image'ı çalıştırmaya hazırladıktan ve gerekli sanallaştırmayı yaptıktan sonra kontrolü Container'ın belirlediği bir komutu çalıştırarak Container'a devretmektedir. `CMD` ile Image için çalışacak default komut belirlenmektedir. Docker CLI, Image'da belirtilen `CMD`'nin komut satırından yeni bir Container çalıştırılırken ezilmesine (override edilmesine) izin vermektedir. Tahmin edebileceğiniz gibi Dockerfile içerisinde sadece bir adet `CMD` komutu bulunabilir. `CMD` birçok formatta verilebilir.

1. İlk format (tercih edilen) `exec form` olarak adlandırılır ve istenen herhangi bir çalıştırılabilir dosya (executable) ve ona verilen parametreleri içerir. Aşağıdaki gibi kullanılır.

        CMD [ "executable", "param1", "param2" ]

    Google'ın DNS sunucusuna sürekli ping atan (`ping 8.8.8.8`) bir Image oluşturmak istediğimizi düşünelim. Bu Image'da verilmesi gereken `CMD` aşağıdadır.

        CMD [ "/bin/ping", "8.8.8.8" ]

2. İkinci format sadece parametrelerin sağlandığı çalıştırılabilir dosyanın (executable) ise biraz sonra tanıtacağımız `ENTRYPOINT`'den alındığı formattır. Aşağıdaki gibi kullanılır.

        CMD [ "param1", "param2" ]

    Google'ın DNS sunucularına sürekli ping atan bir Image'da aşağıdaki gibi Instruction'lar bulunmalıdır.

        ENTRYPOINT [ "ping" ]
        CMD [ "8.8.8.8" ]
    
3. Üçüncü format ise `shell form` olarak adlandırılır. Verilen komut `/bin/sh -c`'a parametre olarak verilerek koşturulur. Bu formatın kullanılabilmesi için oluşturulan Image'da mutlaka Shell'in eklenmiş olması gereklidir. Bir önceki blog'da örnek olarak verdiğimiz `hello-world` Image'ında örneğin bir Shell bulunmamaktadır. Aşağıdaki gibi kullanılır.

        CMD command param1 param2

    Ping örneğini tekrarlamamız gerekirse Dockerfile'a aşağıdaki Instruction'ların eklenmesi gerekir.

        CMD ping 8.8.8.8

##### ENTRYPOINT

Bir önceki `CMD` Instruction'ı da anlatılırken belirtildiği gibi `ENTRYPOINT` çalıştırılabilir bir dosya (executable) gibi kullanılmak üzere bir Image yaratılmasına olanak tanır. Ideal olarak `docker run <image_name>` komutu ile birlikte çalıştırılacak programa ek parametre'ler verilerek kullanılabilecek Image'lar için uygundur. Örneğin sadece `Ping` fonksiyonu için bir Image yaratılarak `ENTRYPOINT` olarak `ping` tanımlanır. Container çalıştırılırken sadece ping edilecek adres sağlanarak kullanılır.

`CMD`'ye benzer şekilde iki formatı vardır.

1. İlk format (tercih edilen) `exec form` olarak adlandırılır ve aşağıdaki gibi kullanılır.

        ENTRYPOINT ["executable", "param1", "param2"]

    Ping örneği için yine `CMD`'ye benzer şekilde aşağıdaki gibi kullanılır.

        ENTRYPOINT [ "/bin/ping" ]

    Docker CLI'da çalıştırılırken (8.8.8.8'den önce ping komutunu vermediğimize dikkat edin)

        docker run gsengun/myubuntu:0.2 8.8.8.8

2. İkinci format `shell form` olarak adlandırılır ve aşağıdaki gibi kullanılır.

        ENTRYPOINT command param1 param2

[Stackoverflow](http://stackoverflow.com)'daki sorulardan dikkatimi çeken `ENTRYPOINT` ve `CMD`'nin sıklıkla birbiri ile karıştırılması veya farklarının tam olarak nerede olduğunun anlaşılmaması ancak sanırım yukarıdaki detaylı açıklamalar sizin kafanızda bir netleşme sağlamıştır.

Bu arada `ENTRYPOINT` ve `CMD` birlikte çok sade bir kullanım sunmak üzere kullanılabilirler. Aşağıdaki Dockerfile Instruction'larını ele alalım. Container'ın çalıştıracağı executable `/bin/ping` olarak belirlenmiştir ve kullanıcı bir parametre sağlamadığında `-help` parametresi verilmesi sağlanmıştır, dolayısıyla parametre verilmeden Container'ın çalıştırılmak istendiği durumda Image'ın kullanımı özetlenecektir.

        ENTRYPOINT [ "/bin/ping" ]
        CMD ["-help"]

Container parametre verilmeden başlatılmak istendiğinde Container içinde `ping -help` komutu koşturularak aşağıdaki çıktı oluşur.

        docker run gsengun/myubuntu:0.3
        Usage: ping [-aAbBdDfhLnOqrRUvV] [-c count] [-i interval] [-I interface]
                [-m mark] [-M pmtudisc_option] [-l preload] [-p pattern] [-Q tos]
                [-s packetsize] [-S sndbuf] [-t ttl] [-T timestamp_option]
                [-w deadline] [-W timeout] [hop1 ...] destination

Container parametre verilerek başlatıldığında ise verilen parametre `ping` komutuna geçirilir ve `ping 8.8.8.8` komutu koşturularak aşağıdaki çıktı oluşur.

        docker run gsengun/myubuntu:0.3 8.8.8.8
        PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
        64 bytes from 8.8.8.8: icmp_seq=1 ttl=37 time=0.197 ms
        64 bytes from 8.8.8.8: icmp_seq=2 ttl=37 time=0.334 ms
        64 bytes from 8.8.8.8: icmp_seq=3 ttl=37 time=0.333 ms

##### EXPOSE

Docker Container'ları yönetmek için oldukça kompleks bir Networking modulü barındırmaktadır. Networking modülü başlı başına uzun bir blog konusu olabilir. Networking modülü gerek aynı Daemon içindeki Container'lar arasındaki bağlantıyı sağlamakta gerekse de Host ile iletişimi yönetmektedir. 

Default olarak Networking modülü Container'ların birbirlerinin UDP/TCP port'larına bağlanmalarına izin vermez. Başka Container'larla bir PORT üzerinden iletişim kurmak isteyen Container'lar ya Image'larında `EXPOSE` komutu ile ilgili portu (default TCP) belirtirler ya da Docker CLI'da `--expose <port_number>` ile başlatılmaları gereklidir.

`ÖNEMLİ NOT:` Belirtilen port Networking modülü tarafından sadece aynı Daemon içerisindeki Container'ların bağlanabileceği şekilde erişime açılmaktadır. Docker'ın koşturulduğu host üzerinden Container'ların port'larına ulaşmak için Docker CLI'da Container başlatılırken `-p <port_number>` parametresinin verilmesi gereklidir. Uygun olan durumlarda Host'a bütün portları görünür kılmak için `EXPOSE` edilen portları parametre olarak teker teker `-p 80 -p 443` ile vermek yerine `-P` (büyük P) ile tek parametre ile verebiliriz.

##### ADD

Oluşturacağımız Image'e Host dosya sisteminden veya internetten yeni bir dosya/klasör eklemek için kullanılır `ADD` komutu. Aşağıdaki gibi iki formatta kullanılabilir, src (source - kaynak) ve dest (destination - hedef) path'lerde boşluk bulunması ihtimaline karşın ikinci formatın kullanılması daha uygun görünmektedir.

    ADD <src>... <dest>
    ADD ["<src>",... "<dest>"]

Örnekler:

Host'tan Image'a klasör kopyalanması

    ADD [ "./BuildDir/", "/app/bin"]

İnternetten Image'a dosya kopyalanması

    ADD [ "https://curl.haxx.se/download/curl-7.50.1.tar.gz", "/tmp/curl.tar.gz" ]

`ÖNEMLİ NOT:` Host klasörde bulunan ve Image'a kopyalanmak istenmeyen dosyalar `.dockerignore` dosyasının içinde belirtilebilir. Bu dosya tıplı `.gitignore`'a benzemektedir.

##### COPY

`ADD` komutu ile aynı şekilde kullanılır fakat İnternetten dosya indiremez sadece Host üzerindeki dosya ve klasörleri kopyalayabilir.

##### WORKDIR

`WORKDIR` Instruction'ı kendisinden sonra gelen `RUN`, `CMD`, `ENTRYPOINT`, `COPY` and `ADD` Instruction'larını etkiler ve bu Instruction'lar Daemon tarafından koşturulurken relatif olarak kullanılan path'lerin başına bu Instruction'la sağlanan path'i ekler. Bu açıklama komut satırını sıklıkla kullanmamış olan kişilere biraz karmaşık gelmiş olabilir. Bir örnek vererek açıklayalım.

Dockerfile'ımızda aşağıda iki Instruction'ın bulunduğunu düşünelim.

    WORKDIR /app/src
    ADD [ "./BuildDir/", "binaries/"]

`/app/src` Container'da `WORKDIR` olarak belirlendikten sonra `ADD` Instruction'ı ile Host üzerindeki `./BuildDir/` klasörünün altındaki bütün dosyalar `binaries` klasörü altına kopyalanmak istenmektedir. `WORKDIR` olarak `/app/src` sağlandığı için dosyalar Host'tan `/app/src/binaries` klasörü altına kopyalanacaklardır.

##### HEALTHCHECK

Hepimiz çalışır göründüğü halde gerçek işlevini getirmeyen bir servis ve process ile karşılaşmışızdır. Servisi koşturan process'in karşılaştığı içsel bir hata (infinite loop - sonsuz döngü, ilgili Thread'in Exit etmesi, vb) ile aslında dışarıdan sorunsuz görünmesine rağmen işlevini yerine getiremediği durumlardan bahsediyoruz. Docker bu soruna bir çözüm üretmeye çalışmıştır. `HEALTHCHECK` Instruction'ı tam olarak bu işe yaramaktadır. Bir servis (web sunucu, vb) vermek üzere oluşturulan Image'ın sağlıklı çalışıp çalışmadığının Daemon tarafından sorgulanmasına olanak tanır. Image'ı oluşturarak dışarıya bir servis sunan kişi bu servisin çalışıp çalışmadığını anlamaya yarayacak bir utility sağlayarak sayılan istenmeyen durumdan kaçınmış olur. 

Aşağıda verilen örnekte 10 saniyede bir koşturulan `curl -f http://localhost:9876` komutu -curl ile yerel olarak 9876 portunda çalıştırılan web sunucudan ana sayfayı isteyen komut- ile maksimum 60 saniyede bir çıktı alıp alamadığına bakar eğer alamıyorsa Container'ın `health status`'unu `unhealthy` olarak işaretler, eğer cevap alırsa container'ı bu kaz `success` ile işaretler.

    HEALTHCHECK --interval=10s --timeout=60s --retries=1 CMD curl -f http://localhost:9876/ || exit 1

Birçok Instruction öğrendik, şimdi bu Instruction'larla çok faydalı bir Image üretip pratiğimizi geliştirmeye çalışalım.

### Nginx Image'ı Hazırlayarak Basit Bir Web Sitesi Sunmak

Vereceğimiz ilk örnek basit bir web sitesi hazırlayarak bunu Nginx ile sunmak olacak. Aslında [Nginx](https://hub.docker.com/_/nginx/) Image'ı DockerHub'da official olarak kullanıma sunulmaktadır. Biz pratik yapma amaçlı olarak bu örneği seçtik. Gösterdiğimiz Dockerfile Instruction'larının birçoğunu kullanacak olmamız bu örneği seçmemizde etkili oldu. 

1. Öncelikle internette küçük bir araştırma ile standart `ubuntu`'da `Nginx`'in nasıl kurulacağını öğrenmemiz gerekiyor. Ailemizin VPS'i DigitalOcean tarafından yayınlanan [bu harika tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04)'da ihtiyacımız olan bilgilerin tamamı var.

    Özetle yapmamız gerekenler, aşağıdaki komutları çalıştırmak olacak. Bu komutların ne yaptığı tamamen konumuz dışında çünkü bu blog Nginx'ten ziyade Docker ile ilgili.

    - `apt-get update` komutunu çalıştırmak 
    - `apt-get install -y nginx` komutunu çalıştırmak
    - Web sitemizin içeriğini Image içerisindeki `/var/www/html` klasörüne taşımak
    - Nginx web sunucumuza gelen istekler HTTP yani 80 numaralı port üzerinden geleceği için Container'ın bu portunu `EXPOSE` etmek 
    - Container'ın `ENTRYPOINT`'i olarak `nginx -g 'daemon off;' vererek ` Nginx'i çalıştırmak

2. Yeni bir Image oluştururken doğru yöntem baz alınacak Image'ı interactive modda çalıştırarak terminal'i attach etmek, komutları öncelikle burada çalıştırıp istenen fonksiyonun gerçekleşip gerçekleşmediğini kontrol ederek iteratif ilerlemek olmalıdır fakat biz burada bu adımı zaten gerçekleştirdiğimizi düşünelim çünkü bir önceki adımda verilen bilgiler de aslında bu yöntemle öğrenildi.

    Öncelikle bu projeyi saklayacağınız bir klasör yaratarak boş bir `Dockerfile` ve aşağıdaki içeriğe sahip bir `index.html` dosyasını bu klasörün içerisine koyun.

    `index.html` içeriği:

        <html>
        <head>
            <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
            <title>Ana Sayfa</title>
        </head>
        <body>
            <div style="text-align: center;"> 
                <h1>Web Sitemize Hoşgeldiniz</h1>
                <h2>Nginx ve Docker İşbirliği Sunar</h2>
            </div>
        </body>
        </html>

3. Dockerfile'ımızı yazmaya başlayalım. Öncelikle `ubuntu:latest` Image'ını baz alacağımızı zaten söylemiştik. `MAINTAINER` olarak da kendi bilgilerinizi vererek Dockerfile'a aşağıdaki iki satırı ekleyin.

        FROM ubuntu:latest

        MAINTAINER Gokhan Sengun <gokhansengun@gmail.com>

4. Nginx'i baz `ubuntu` Image'ına kurmak için birinci adımda verilen iki komutu çalıştırmamız gerekiyor. Bunları çalıştırmak için Dockerfile'a aşağıdaki Instruction'ları ekleyin. Bu iki komut Image'ımıza Nginx kurulumunu sağlayacaktır.

        # Paket listelerini download et
        RUN apt-get update

        # Nginx paketini yükle
        RUN apt-get install -y nginx

5. Birinci adımda verilen listeden devam edersek sıradaki iş Web Sitemizin içeriğini `/var/www/html` klasörüne taşımak. Bu işlemi gerçekleştirmek için `ADD` Instruction'ını kullanacağız. Aşağıdaki satırı Dockerfile'a ekleyin.

        ADD [ "./index.html", "/var/www/html/" ]

6. Sondan bir önceki adım Nginx'in dinlediği HTTP (80) numaralı portun Docker Networking modulü üzerinden erişilmek üzere `EXPOSE` edilmesidir. Bu işlem için aşağıdaki satırı Dockerfile'a ekleyin.

        EXPOSE 80

7. Son adımda ise Image'ın `ENTRYPOINT`'i olarak `nginx -g 'daemon off;'` verecek ve Container'ın başlatılırken bu komutu çalıştırmasını sağlayacağız. Bu satırı da Dockerfile'a ekleyerek bir sonraki adıma geçin.

        ENTRYPOINT nginx -g 'daemon off;'

8. Dockerfile'ımızın kümüle görüntüsü aşağıdaki gibi olmalıdır.

        FROM ubuntu:latest

        MAINTAINER Gokhan Sengun <gokhansengun@gmail.com>

        # Paket listelerini download et
        RUN apt-get update

        # Nginx paketini yükle
        RUN apt-get install -y nginx

        ADD [ "./index.html", "/var/www/html/" ]

        EXPOSE 80

        ENTRYPOINT nginx -g 'daemon off;'

9. `docker build -t gsengun/mywebsite:0.1 .` komutunu vererek Image'ı build edin. `docker images` komutu ile Image'ın doğru bir şekilde build olduğunu kontrol edin.

10. Artık Image'ımızı oluşturduk. Şimdi Host üzerindeki 8080 numaralı portu Image'ın dinlediği 80 numaralı porta yönlendirerek oluşturduğumuz Image'dan yeni bir Container yaratalım. Bir önceki blog'da ve bu blog'un önceki bölümlerinde port forwarding işleminin `-p 8080:80` parametresi ile yapılabildiğini söylemiştik. Aşağıdaki komutu vererek Container'ı yaratın.

        docker run -p 8080:80 gsengun/mywebsite:0.1

11. Tarayıcınızı açarak adres çubuğuna `http://localhost:8080` yazın aşağıdaki gibi bir sayfa görmelisiniz.

    {% include image.html url="/resource/img/DockerPart2/ServeWebSiteWithNginx.png" description="Serve Web Site with Nginx using Docker" %}

### Bu Blog'da Değinilmeyen Konular

Docker Daemon'ın Dockerfile ile Image oluşturma process'i başlı başına bir sanat eseridir ve entellektüel kaygılarla muhakkak incelenmeli ve iyi bir şekilde anlaşılmalıdır. Bu blog dizisinde Docker'ı pragmatik bir yaklaşımla ele almaya çabaladığımız için bu bölümü şimdilik atladık. Belki ileride başka bir blog'da Docker Image katmanları ve Image oluşturma işleminin mekaniklerine detaylı bir bakış atabiliriz. 

### Sonuç

Bu blog'da Dockerfile kullanarak yeni bir Image yaratmak için gerekli olan teknik altyapıyı kazanmış olduk.

Bir sonraki [blog'da](/docker-compose-nasil-kullanilir/) artık Docker'ı nasıl kolay setup'lar hazırlamak için kullanacağımızı ve nimetlerinden pratik olarak nasıl faydalanabileceğimizi göreceğiz. 

#### Teşekkür

Bu blog yazısını gözden geçiren ve düzeltmelerini yapan Burak Sarp'a ([@Sarp_burak](https://twitter.com/Sarp_burak)) teşekkür ederiz.
---
layout: post
title: "Docker Bölüm 3: Docker Compose Hangi Amaçlarla ve Nasıl Kullanılır?"
level: Başlangıç
progress: finished-not-reviewed
---

Docker blog serimizin ilk iki bölümünde Docker'ı günlük hayatta kullanmaya başlamak için gerekli bilgi seviyesini oluşturmak için Docker ve sunduğu olanakları yakından tanımaya çalıştık. Bu blog'da ise Docker'ı gerek geliştirme, gerek test ve gerekse de üretim ortamında nasıl kullanabileceğimiz ile ilgili çok pratik ve genellikle demo'lardan oluşan bilgileri elde edeceğiz. Eminim verilen örnekler sizin kafanızda da farklı çağrışımlar uyandıracak ve siz de kendinizi her gün uğraştığınız işlerde Docker kullanarak nasıl daha verimli olabileceğinize dair düşünceler içinde bulacaksınız.

Docker blog serisinin ilk ikisi aşağıda verilmiştir. Eğer daha önce okumadıysanız bu blog'ları da okumanız tavsiye edilir.

[Docker Bölüm 1: Nedir, Nasıl Çalışır, Nerede Kullanılır?](/docker-nedir-nasil-calisir-nerede-kullanilir/)

[Docker Bölüm 2: Yeni bir Docker Image'ı Nasıl Hazırlanır?](/docker-yeni-image-hazirlama/)

### Çalışma Özeti

Öncelikle bu blog'da anlatılacak özellikler Docker-Compose'un 1.6 versiyonu ve sonrasında desteklenmektedir. Komut satırında `docker-compose version` komutunu vererek kullandığınız versiyon ile ilgili bilgi alabilirsiniz. Eğer bu komutun çıktısında görülen versiyon 1.6 altındaysa bu blog'da yazılanları takip edebilmek için kullandığınız versiyonu yükseltmeniz gereklidir. 

Bu blog'da aşağıdaki adımları tamamlayarak Docker'ın günlük hayatta kullanımı ve getirdiği kolaylıkları daha yakından tanıma fırsatı bulacağız.

* Öncelikle Docker Compose'un ne işe yaradığı ve hangi problemi çözdüğü üzerinde duracağız.
* Motivasyon olması açısından en basit haliyle bir docker-compose.yml dosyası oluşturarak basit bir sistemi ayağa kaldıracağız.
* Docker Compose CLI (docker-compose) tanıtımı ile devam edeceğiz.
* docker-compose.yml dosya yapısını ve konfigürasyon opsiyonlarını detaylı bir şekilde inceleyeceğiz.
* Docker Compose ile kurgulanmış görece karmaşık bir yapıyı çalıştıracak, satır satır açıklayacak ve bu blog'u kapatacağız.

### Ön Koşullar

Bu blog'da yer verilen adımları takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker CLI ile ilgili genel bilgi sahibi olmak.
* YAML (Yamıl diye okunur) data serializasyon diline aşinalık.
* Docker ile ilgili [blog serisinin ilk blogunda'da](/docker-nedir-nasil-calisir-nerede-kullanilir/) anlatılan düzeyde bilgi sahibi olmak.
* Dockerfile hazırlama ile ilgili [blog serisinin ikinci blog'unda](/docker-yeni-image-hazirlama/) anlatılan düzeyde bilgi sahibi olmak.

### Docker Compose - Giriş

Önceki iki blog'da üzerinde durduğumuz konular hep tek bir Docker Image oluşturma veya tek bir Container çalıştırma ile ilgiliydi. Günlük olarak kullandığımız veya kullanılmak üzere müşterilerimize sunduğumuz ürünler ve sistemler birden fazla servisin (genellikle web sunucular, uygulama sunucuları, veri tabanı sunucuları, cache sunucuları, message queue sunucuları, vb) bir araya gelmesiyle oluşmaktadırlar. Orta ve büyük ölçekteki sistemleri Docker CLI kullanarak kullanıma sunmak ve bakımını yapmak pek makul değildir. Bu tip sistemlerde Container'ların çalıştırılması, durdurulması, birbirleri ile olan ilişkilerinin belirtilmesi yani basit bir şekilde yönetilebilmesi görevlerini yerine getirecek ayrı bir aracın varlığı gereklidir. 

Development (geliştirme), kullanıcı kabul (UAT) ve test ortamlarının kolay bir şekilde yönetilebilmesi için Docker Compose kullanılmaktadır. Docker Compose bu ortamlarda kolay kurulum, bakım ve genel olarak kullanım sağlamaktadır fakat `Docker Inc` tarafından yapılan yeni geliştirmelerle sistem kararlılığı, performansı, tutarlılığı, yedekliliği ve yüksek erişilebilirliğinin önemli olduğu production (üretim) ortamlarında da kullanılmaya doğru gitmektedir. Özellikle Docker 1.12 versiyonu ile birlikte gelen Docker Compose ve Swarm entegrasyonu bu konuda yakın gelecekte daha da sağlam adımlar atılacağının bir habercisi niteliğindedir. Docker Compose, Docker Swarm ve Kubernetes gibi Clusterin (kümeleme) araçları ile karıştırılmamalıdır. Swarm ve Kubernetes, Production sistemlerin yukarıda sıralanan özelliklerini yerine getirmeye çabalamaktadır. 

docker-compose.yml dosyasında detayları verilen ve birbirleri ile ilişkileri tanımlanan servisler (Container'lar) tek bir komut ile ayağa kaldırılıp tek bir komut ile durdurulur ve yine tek bir komut ile kaldırılabilirler (silinebilirler).

[Fig](http://www.fig.sh/)'i referans alan `docker-compose` aracı güncel olarak Docker CLI ve Docker Daemon'ı da sağlayan `Docker Inc` tarafından sunulmakta ve genellikle bütün platformlarda Docker bundle'ı ile birlikte gelmektedir. Docker Compose'un ne işe yaradığını anladıktan sonra şimdi basit bir sistem ve senaryo ile kavramları ve kullanımını örneklemeye çalışalım.

### Basit Bir Sistemi Docker Compose ile Ayağa Kaldırma

Bu blog serisinin [ilk blog'unda](/docker-nedir-nasil-calisir-nerede-kullanilir/) Docker'ın Multitenancy mantığını uygulama içinden alarak platforma taşıma konusunda yardımcı olacağını söylemiştik. Bu bölümde yapacağımız çalışmada bu konuyu örneklemeye çalışarak bir taşla iki kuş vurmaya çalışalım. A, B ve C şirketlerinden kurulu bir holdingde, şirketleri statik sayfalardan oluşan web sitelerini sunmak için Docker Container'lardan oluşan bir yapı kurmak istediğimizi düşünelim. Bu yapı için kuracağımız test ortamını ele alacağız. Statik web sitelerini Nginx ile sunalım fakat bir önceki blog'da kendi hazırladığımız Nginx Docker Image'ı yerine [DockerHub](https://hub.docker.com)'da bulunan official Nginx Docker Image'ını kullanacağız.

Hemen işe koyulalım. 

1. Bu proje için yeni bir klasör oluşturarak, aşağıdaki içeriğe sahip bir `docker-compose.yml` dosyası oluşturun.

        version: '2'

        services:
            company_a_web_server:
                image: nginx:latest
                ports:
                    - "8001:80"

            company_b_web_server:
                image: nginx:latest
                ports:
                    - "8002:80"

            company_c_web_server:
                image: nginx:latest
                ports:
                    - "8003:80"

    Docker Compose'un 1.6 ve sonraki versiyonlarında `docker-compose.yml` dosyasının formatı farklı özellikleri de destekleyecek şekilde geliştirilmiştir. Yukarıda verilen dosyada ilk satırın `version: '2'` olduğuna dikkat edin. Bu satır Docker Compose'a içeriğin 1.6 ile gelen versiyon yani `version: '2'` için değerlendirilmesini salık verir.

    YAML dosyasının `services` düğümünde Docker Compose ile yönetmek istediğimiz servisleri teker teker sıralarız. Bizim örneğimizde A, B ve C şirketleri için sırasıyla `company_a_web_server`, `company_b_web_server` ve `company_c_web_server` servisleri yaratılmıştır. Compose file'da servisler örneğimizde yapıldığı gibi hazır bir Image'dan (`nginx:latest`) türetilebileceği gibi bir Dockerfile sağlanarak da yaratılabilir. `image` keyword'ü servisin hangi Image ile başlatılacağını belirtir.

    Docker Compose dosyası ile oluşturacağımız Nginx Container'larının (servislerinin) kullandığı official Nginx Image'ı HTTP (80) numaralı portu dinlemekte, bu portu `EXPOSE` etmekte ve bu porttan web sayfalarını sunmaktadır. Host üzerinden Container'lar tarafından 80 portundan sunulan web sayfalara ulaşabilmek için 80'li portların Host'ta farklı portlara forward edilmesi gereklidir. Port forwarding (Map'leme) amacı ile Compose file'da her bir servis için `ports` keyword'ü ile 8001, 8002 ve 8003 numaralı portlar sırasıyla A, B ve C şirketlerinin web sayfaları için Map'lenir.

2. Terminal veya komut satırı açarak `docker-compose.yml` dosyasının bulunduğu klasöre gidin ve `docker-compose up` komutunu verin. Docker Compose, YAML dosyasında bulunan bütün Image'ları önce pull edip (eğer daha önce pull edilmediyse) sonra da çalıştıracaktır. Siz de `nginx` Image'ını DockerHub'dan daha önce indirdiyseniz aşağıdakine benzer bir çıktı görmelisiniz.

        Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up
        Creating network "dcblog_default" with the default driver
        Creating dcblog_company_a_web_server_1
        Creating dcblog_company_b_web_server_1
        Creating dcblog_company_c_web_server_1
        Attaching to dcblog_company_a_web_server_1, dcblog_company_c_web_server_1, dcblog_company_b_web_server_1

    Çıktıdan görebileceğiniz gibi Docker Compose öncelikle `dcblog_default` adında bir network yarattı sonra kullanılan klasör ismi olan `DCBlog` ve servis isimlerini `company_x_web_server` birleştirip Container'lara vererek onları teker teker çalıştırdı. En son satırda ise terminali çalıştırılan bu Container'lara attach ettiğini görüyoruz. Bu çıktı ile ilgili farklı açılardan bakarak detaylı analizler yapacağız fakat öncelikle demo'yu tamamlayalım.

3. Web tarayıcıyı açarak `http://localhost:8001`, `http://localhost:8002` ve `http://localhost:8003` adreslerinden Nginx'in default sayfasının gelip gelmediğini kontrol edin. Sizde de aşağıdakine benzer bir görüntü oluşmalı. Burada aşağıya sadece A şirketinin web sitesi kabul ettiğimiz Container'ın sunduğu ana sayfanın ekran çıktısı alınmıştır.

    {% include image.html url="/resource/img/DockerPart3/CompanyAHomePage.png" description="Home Page Company A" %}

4. Şimdi Docker Compose'un arka planda ne yaptığını anlamaya çalışalım. Docker Compose'u başlattığınız terminal'den başka bir terminal açarak `docker ps` komutunu verin ve çalışan Container'ların hangileri olduğunu görün. Aşağıdaki çıktıda görebileceğiniz gibi Compose üç adet Container'ı onları ayarladığımız gibi başlatarak onları isimlendirmiş.

        CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                           NAMES
        894cf2d86b46        nginx:latest        "nginx -g 'daemon off"   14 minutes ago      Up 14 minutes       443/tcp, 0.0.0.0:8003->80/tcp   dcblog_company_c_web_server_1
        ed8bdaa7514c        nginx:latest        "nginx -g 'daemon off"   14 minutes ago      Up 14 minutes       443/tcp, 0.0.0.0:8002->80/tcp   dcblog_company_b_web_server_1
        99e685c06e2d        nginx:latest        "nginx -g 'daemon off"   14 minutes ago      Up 14 minutes       443/tcp, 0.0.0.0:8001->80/tcp   dcblog_company_a_web_server_1

5. `docker-compose up` komutunu çalıştırdığınız terminal'e tekrar giderek `Ctrl + C` tuş kombinasyonuna basarak Container'ların çalışmalarını durdurun. Sonra da terminallerin herhangi birinden `docker ps` komutunu verdiğinizde çalışan hiçbir Container olmadığını göreceksiniz. `docker ps -a` komutunu verdiğinizde çalıştırılan Container'ların durdurulduğunu görebilirsiniz.

        Gokhans-MacBook-Pro:DCBlog gsengun$ docker ps -a
        CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                          PORTS               NAMES
        894cf2d86b46        nginx:latest        "nginx -g 'daemon off"   17 minutes ago      Exited (0) About a minute ago                       dcblog_company_c_web_server_1
        ed8bdaa7514c        nginx:latest        "nginx -g 'daemon off"   17 minutes ago      Exited (0) About a minute ago                       dcblog_company_b_web_server_1
        99e685c06e2d        nginx:latest        "nginx -g 'daemon off"   17 minutes ago      Exited (0) About a minute ago                       dcblog_company_a_web_server_1

6. Herhangi bir terminalde `docker-compose.yml` dosyasının bulunduğu klasöre giderek `docker-compose up` komutunu çalıştırın. Aşağıdakine benzer bir çıktı elde edeceksiniz.

        Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up
        Starting dcblog_company_a_web_server_1
        Starting dcblog_company_b_web_server_1
        Starting dcblog_company_c_web_server_1
        Attaching to dcblog_company_b_web_server_1, dcblog_company_c_web_server_1, dcblog_company_a_web_server_1

    Çıktıdan görebileceğiniz gibi bu kez ikinci adımdaki gibi Container'lar yaratılmak yerine sadece başlatıldı çünkü bu Container'lar daha önce başlatılmış ve durdurulmuştu. Muhtemelen burada Compose Docker CLI'ın `docker start` komutunu koşturarak Container'ları tekrar ayağa kaldırmıştır.

7. `docker-compose` Docker CLI'a benzer komutlar sağlamaktadır. Bildiğiniz gibi `docker ps` Docker Daemon'da çalıştırılan bütün Container'ları listelemektedir. Docker Compose tarafından sağlanan `docker-compose ps`, `docker-compose.yml` dosyasının bulunduğu klasörde koşturulunca sadece Compose tarafından başlatılan Container'ları listeler.

    İkinci terminalde ilgili klasörde olduğunuza emin olarak `docker-compose ps` komutunu koşturun. Aşağıdakine benzer bir çıktı elde etmelisiniz.

        Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose ps
                    Name                      Command          State               Ports
        --------------------------------------------------------------------------------------------
        dcblog_company_a_web_server_1   nginx -g daemon off;   Up      443/tcp, 0.0.0.0:8001->80/tcp
        dcblog_company_b_web_server_1   nginx -g daemon off;   Up      443/tcp, 0.0.0.0:8002->80/tcp
        dcblog_company_c_web_server_1   nginx -g daemon off;   Up      443/tcp, 0.0.0.0:8003->80/tcp

8. Docker Compose CLI'ı, Docker CLI tarafından sunulan birçok komutu Compose mantığına göre tekrar uygulamıştır. Bu komutların bir listesine `docker-compose help` komutu ile bakılabilir. Bu komutlardan `docker-compose logs` komutunu vererek Compose kapsamında çalıştırılan bütün Container'ların terminal çıktılarına ulaşabilirsiniz.

9. `docker-compose up` komutunu verdiğimiz terminale giderek `Ctrl + C` ile Container'ları Stop edin. Sonra da bütün Container'ları kaldırmak için `docker-compose down` komutunu verin. Sizde de aşağıdakine benzer bir çıktı oluşmalı.

        Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose down
        Removing dcblog_company_c_web_server_1 ... done
        Removing dcblog_company_b_web_server_1 ... done
        Removing dcblog_company_a_web_server_1 ... done
        Removing network dcblog_default

    Çıktıdan Composer'ın yarattığı bütün Container'ları `docker-compose down` komutu ile kaldırdığını görebilirsiniz. `docker-compose ps` veya `docker ps -a` komutları ile Container'ların gerçekten kaldırıldığını görebilirsiniz. Burada da muhtemelen Compose, `docker rm` komutunu kullanarak Container'ları kaldırmıştır.

    `ÖNEMLİ NOT:` `docker-compose down` komutuna `-v` parametresi eklemek Compose kapsamında başlatılan herhangi bir Container ile ilişkilendirmiş Volume'ları da silmektedir. Henüz Volume'ların ne olduğundan bahsetmedik ancak Container'da oluşturulan bilgiyi kaybetmek istemiyorsanız `-v` parametresi ile çalıştırmamanız gerektiğini aklınızın bir kenarında tutmanız gerekir.

### Docker Compose CLI

İlk blog'da Docker CLI ile ilgili detaylı bilgiler vermiştik. Bir önceki bölümde de Docker Compose CLI'ın Docker CLI'daki birçok komutu Docker Compose işlevleri doğrultusunda tekrar uyguladığından bahsettik. Bu bölümde bir önceki bölümdeki örnek üzerinden Docker Compose CLI'ı (`docker-compose`) daha yakından tanıyalım.

#### docker-compose build

Docker Compose CLI'ın sunduğu `docker-compose build` ve `docker-compose build <service_name>` komutları ile Compose dosyasında tanımladığınız Container'ları (servisleri) teker teker veya toplu halde build edebilirsiniz. Önceki bölümde `docker-compose up` komutunu verdiğimizde bu komutun, servisler eğer daha önce build edilmemişse onları build ettiğini söylemiştik. Servislerden birinin Host'dan kopyaladığı değiştirdiğimizi ve Image'ını yeniden build etmek istediğimizi düşünelim. Bu durumda `docker-compose up` komutunu verirsek Docker Compose servisin içeriğinin değiştiğini anlayamadığı için sadece stop durumdaki Container'ları tekrar ayağa kaldıracaktır, dolayısıyla yapılan değişiklikler görülemeyecektir. İçeriği değiştirilen servis için `docker-compose build <service_name>` komutu koşturulduktan sonra `docker-compose up` komutu koşturulursa ilgili servis'in Container'ı kaldırılarak yeni Image'dan yeni bir Container oluşturulur. 

#### docker-compose up

Bir önceki bölümdeki örneklerde görüldüğü gibi Compose dosyasında tanımlı bütün servisleri ayağa kaldırmak için kullanılır.

`docker-compose build` için verilen yukarıdaki örnekte eğer değiştirilen şey Host'tan kopyalanan dosyalar olmayıp, Dockerfile veya servis konfigürasyonu olsaydı `docker-compose up` komutu verildiğinde Compose değişiklikleri tanıyacak Image'ı rebuild edecek, önceki Container'ı kaldıracak ve yeni bir Container yaratacaktır. Bütün bunların olması istenmiyorsa `--no-recreate` parametresi ile Compose'un değişiklikleri algılaması ve yeni bir build oluşturması engellenir. Tam tersine bir önceki örnekteki gibi Host'tan kopyalanan dosyalar gibi Compose'un anlayamayacağı değişikliklerde `--force-recreate` paramtresi verilerek Image'ın her seferinde tekrar build edilmesi, önceki Container'ın kaldırılması ve yeni bir Container yaratılması sağlanabilir.

Bütün durumlarda Compose dosyasında servislerin tamamının ayağa kaldırılması istenmeyebilir. Sadece belirli servis veya servislerin ayağa kaldırılması için servis isimleri parametre olarak verilebilir. Kullanım `docker-compose up <service_name_1>  <service_name_2>`. Bir önceki bölümdeki örnekde A, B ve C şirketlerinin sitelerinin hepsini değil sadece A sitesini çalıştırmaya başlamak istersek `docker-compose up company_a_web_server` komutunu verebiliriz. `docker-compose.yml` dosyasının buluduğu klasöre giderek aşağıdaki komutu verin.

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up company_a_web_server
    Creating network "dcblog_default" with the default driver
    Creating dcblog_company_a_web_server_1
    Attaching to dcblog_company_a_web_server_1

Gördüğünüz gibi sadece A servisi için bir Container yaratıldı. 

Docker CLI'da olduğu gibi `-d` parametresi Compose'da da Container'ların `detached` modda yani terminale bağlı olmadan arka planda (background) çalıştırılmasını sağlar. Bu kez A ve B şirketlerine ait sunucuları `detached` modda çalıştıralım.

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up -d company_a_web_server company_b_web_server
    Creating network "dcblog_default" with the default driver
    Creating dcblog_company_a_web_server_1
    Creating dcblog_company_b_web_server_1

Bu kez `-d` parametresi ile başlattığımız iki servisi görüyoruz. Bu servislerin log'larına bakmak istersek, aynı terminali kullanarak `docker-compose logs` komutunu verebiliriz.

#### docker-compose down

Önceki bölümdeki örnekten de gördüğümüz gibi `docker-compose down` Compose tarafından yaratılmış Container'ları (servisleri) öncelikle durdurarak sonra da kaldırmaktadır. Burada `-v` parametresine dikkat etmek gereklidir. Compose tarafından oluşturulan Volume'ların (sonraki bölümlerde değineceğiz) da kaldırılması isteniyorsa `-v` parametresinin sağlanması gerekmektedir.

Eğer Compose dosyasında Compose tarafından yeni Image'lar build edilmesi konfigüre edilmişse `docker-compose down` bu Image'ların silinmesi için de kullanılabilir. Oluşturulan Image'ların silinmesi için `--rmi all` parametresinin sağlanması gereklidir.

#### docker-compose ps

Aynı Host üzerinde birden fazla Docker sistemi çalıştırılıyorsa `docker ps` komutunun verdiği çıktı başka sistemlerden çalıştırılan Container'ları da gösterdiği için çok fazla anlamlı olmayabilir veya karmaşık gelebilir. Docker Compose CLI'ın sunduğu `docker-compose ps`, `docker-compose.yml` dosyasının olduğu klasörden verilirse sadece ilgili Compose dosyasında olan Container'ları listeleyecek, daha yönetilebilir ve az yoran bir çıktı sunacaktır. 

`docker-compose ps` Docker CLI'daki `-a` parametresine benzer bir parametre sunmamaktadır. Hatırlarsanız `docker ps -a` daha önce çalıştırılmış fakat sonradan çıkış (Exit) yapmış process'leri göstermekteydi. Compose sadece ve sadece kendi başlattığı Container'larla ilgilendiği için Exit olan Container'ları ayrı bir parametre ile göstermek yerine parametre almayan komutun çıktısına bir kolon olarak eklemiştir. Olayı örneklemek için öncelikle bütün Container'ları başlatalım ve sonra `Ctrl + C` tuş kombinasyonu ile durdurup `docker-compose ps` ile gösterilen çıktıya bakalım.

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up
    Creating network "dcblog_default" with the default driver
    Creating dcblog_company_b_web_server_1
    Creating dcblog_company_a_web_server_1
    Creating dcblog_company_c_web_server_1
    Attaching to dcblog_company_c_web_server_1, dcblog_company_a_web_server_1, dcblog_company_b_web_server_1
    
    ^CGracefully stopping... (press Ctrl+C again to force)
    Stopping dcblog_company_c_web_server_1 ... done
    Stopping dcblog_company_a_web_server_1 ... done
    Stopping dcblog_company_b_web_server_1 ... done
    
    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose ps
                Name                      Command          State    Ports
    ---------------------------------------------------------------------
    dcblog_company_a_web_server_1   nginx -g daemon off;   Exit 0
    dcblog_company_b_web_server_1   nginx -g daemon off;   Exit 0
    dcblog_company_c_web_server_1   nginx -g daemon off;   Exit 0

#### docker-compose run

Docker Compose CLI'daki en enteresan komutlardan biridir. Bu komutu kullanmaya başladığınızda biliniz ki ya Docker ve Compose ile ilgili gerçekten çok ileri seviyeye geldiniz ya da bir şeyleri Best Practices çerçevesinde yapmıyorsunuz. `docker-compose run` komutunun temel olarak yaptığı Compose dosyasında tanımlanan bir servis için Compose dosyasında tanımlanmayan bir komut koşturmaktır. Örnek olarak yine bir önceki bölümdeki senaryodan yola çıkalım. Öncelikle senaryoyu yaratmaya yardımcı olması açısından `docker-compose up` ile bütün servisleri başlatalım. Sonra da `docker-compose run` ile A şirketi için tanımlanan servisi kullanarak yeni bir Container çalıştırıp bu Container ile B şirketinin Container'ına `ping -c 4 company_b_web_server` komutu ile 4 adet ping atalım. Burada `docker-compose up` komutunu vermemizin tek sebebinin B şirketinin Container'ını ayağa kaldırmak olduğunu tekrar hatırlatayım. Aşağıdaki komutların aynısını siz de vererek benzer çıktılar elde etmelisiniz.

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up -d
    Creating dcblog_company_b_web_server_1
    Creating dcblog_company_a_web_server_1
    Creating dcblog_company_c_web_server_1

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose run company_a_web_server ping -c 4 company_b_web_server
    PING company_b_web_server (172.20.0.2): 56 data bytes
    64 bytes from 172.20.0.2: icmp_seq=0 ttl=64 time=0.132 ms
    64 bytes from 172.20.0.2: icmp_seq=1 ttl=64 time=0.117 ms
    64 bytes from 172.20.0.2: icmp_seq=2 ttl=64 time=0.102 ms
    64 bytes from 172.20.0.2: icmp_seq=3 ttl=64 time=0.108 ms
    --- company_b_web_server ping statistics ---
    4 packets transmitted, 4 packets received, 0% packet loss
    round-trip min/avg/max/stddev = 0.102/0.115/0.132/0.000 ms

Dikkatli okuyucularımız hemen iki şeyi farkettiler. İlki her nasıl olduysa `company_a_web_server` servisini çalıştıran Container `company_b_web_server` servisini çalıştıran Container'a ismi ile ping atabildi. İkincisi de `company_b_web_server` servisini çalıştıran Container'ın IP'sinin `172.20.0.2` olduğuydu. 

`ÇOK ÖNEMLİ NOT:` Docker Compose aynı dosyada tanımlanan bütün servislerin birbirlerine servis isimleri üzerinden network bağlantısı sağlayabilmeleri için gerekli düzenlemeleri yapar. Yaptığı düzenleme Networking modulünde ilgili servis isimleri ve bu servisleri çalıştıran Container'lara verdiği IP'leri mini bir DNS sunucuya karşılık olarak yazmasıdır.

Son olarak `docker-compose run` ile çalıştırılan Container'lar genellikle tek seferlik bir işi yapıp çıkmak için kullanıldığından bu Container'ın Exit yaptıktan sonra sistemden kaldırılmasını isteyebiliriz. Bu durumda komutu `--rm` parametresi ile çalıştırırsak Container Exit yaptıktan sonra sistemden kaldırılır. 

#### docker-compose start

Önceden `docker-compose up` veya `docker-compose run` ile başlatılan Container'lardan birini veya birkaçını yeniden başlatmak için kullanılır. Açık konuşmak gerekirse bugüne kadar çok fazla kullandığımız bir komut olmadı. Sağladığı fonksiyon `docker-compose up <service_name>` tarafından bire bir karşılandığı için `docker-compose start` muhtemelen Docker CLI ile uyum amacıyla konmuş veya [Fig](http://www.fig.sh)'e geriye dönük uyumluluk amacıyla bırakılmıştır.

#### docker-compose stop

Compose dosyasında verilen ve daha önceden `docker-compose up` veya `docker-compose run` komutları ile başlatılan bir veya daha fazla servisi durdurmak için kullanılır. Örneklemek için bir önceki bölümdeki kullanım senaryosunda A ve B şirketlerinin web sitelerini `docker-compose up` komutu ile başlatalım sonra da A şirketinin web sayfasının sunan servisi `docker-compose stop` komutu ile durduralım. Aşağıda verilen komutları takip ederseniz sizin de benzer çıktıları almanız gerekir.

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up -d company_a_web_server company_b_web_server
    Creating network "dcblog_default" with the default driver
    Creating dcblog_company_a_web_server_1
    Creating dcblog_company_b_web_server_1
        
    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose stop company_a_web_server
    Stopping dcblog_company_a_web_server_1 ... done
        
    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose ps
                Name                      Command          State                Ports
    ---------------------------------------------------------------------------------------------
    dcblog_company_a_web_server_1   nginx -g daemon off;   Exit 0
    dcblog_company_b_web_server_1   nginx -g daemon off;   Up       443/tcp, 0.0.0.0:8002->80/tcp

Çıktıdan görebildiğiniz gibi durdurulan `company_a_web_server` servisini sunan `dcblog_company_a_web_server_1` Exit durumdadır.

#### docker-compose exec

Docker CLI'daki `docker exec` komutunun bire bir aynısıdır. Çalışmakta olan Container'da bir komut koşturmak için kullanılır. Yine bir önceki bölümdeki örnekten devam ederek, A şirketinin web sitesini sunan Container'a terminal erişimi sağlayarak terminalde `uname -a` komutunu koşturalım. 

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up -d
    Creating network "dcblog_default" with the default driver
    Creating dcblog_company_a_web_server_1
    Creating dcblog_company_b_web_server_1
    Creating dcblog_company_c_web_server_1
    
    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose exec company_a_web_server /bin/bash
    
    root@3bb989b36e01:/# uname -a
    Linux 3bb989b36e01 4.4.15-moby #1 SMP Thu Jul 28 21:30:50 UTC 2016 x86_64 GNU/Linux

`docker-compose exec` komutu terminal erişimi sağlamanın yanında başka komutlar koşturmak için de kullanılabilir. Aşağıdaki örnekte A şirketinin web sitesini sunan Container'dan B'ninkine 4 adet ping atılmıştır.

    Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose exec company_a_web_server ping -c 4 company_b_web_server
    PING company_b_web_server (172.20.0.2): 56 data bytes
    64 bytes from 172.20.0.2: icmp_seq=0 ttl=64 time=0.078 ms
    64 bytes from 172.20.0.2: icmp_seq=1 ttl=64 time=0.107 ms
    64 bytes from 172.20.0.2: icmp_seq=2 ttl=64 time=0.113 ms
    64 bytes from 172.20.0.2: icmp_seq=3 ttl=64 time=0.108 ms
    --- company_b_web_server ping statistics ---
    4 packets transmitted, 4 packets received, 0% packet loss
    round-trip min/avg/max/stddev = 0.078/0.101/0.113/0.000 ms

Docker Compose CLI'ı detaylı bir şekilde inceledik. Şimdi de `docker-compose.yml` dosya yapısına ve komfigürasyon opsiyonlarına bir göz atalım. 

### docker-compose.yml Dosyasının Yapısı ve Konfigürasyon Opsiyonlarını

Daha önce de söylediğimiz ve uzantısından zaten anlaşılabileceği gibi docker-compose.yml dosyası [YAML](http://yaml.org/) (yamıl diye okunur) formatındadır. YAML, JSON ve XML gibi bir data serializasyon formatıdır. YAML, endüstride basit konfigürasyonlar için JSON'dan çok daha okunur bulunmakta ve severek kullanılmaktadır.

Compose dosyasının yapısını üç ana bölümde inceleyebiliriz. Bu bölümler Service, Volume ve Network konfigürasyonu olarak sıralanabilir. Bu bölümde sıraladığımız bütün özelliklerin versiyon 2'ye ait olduğunu bir kez daha tekrarlayarak başlayalım.

#### Service Konfigürasyonu

Compose dosyasında `service:` Tag'i ile belirtilir. Her bir servis tanımı, kendisinden çalıştırılan Container'ların detaylarını belirler. Şimdi `service:` Tag'i altında verilen konfigürasyon opsiyonlarını teker teker sıralayarak örnekleyelim.

##### build

İlgili Service'in hangi Dockerfile'a göre build edileceği bu Tag ile konfigüre edilir. İki şekilde kullanılabilir. Birincisinde sadece build'de kullanılacak `Dockerfile`'ın relatif path'inin verilmesi yeterlidir. Aşağıdaki gibi kullanılır. Verilen örnekte `MyWebApp` adlı klasörde `Dockerfile`'ın bulunması gereklidir.

    build: ./MyWebApp

İkinci kullanımda ise build context (build'in Dockerfile'a relatif olarak hangi klasörde yapılacağı) ve kullanılacak Dockerfile'ın ismi verilir. Aşağıdaki gibi kullanılır.

    build:
        context: ./MyWebApp
        dockerfile: Dockerfile-MyWebApp

##### command

İlgili servis için kullanılan Image'ın sağladığı komuttan farklı bir komut kullanılmak istendiğinde bu konfigürasyon opsiyonundan faydalanılır. Aşağıdaki gibi kullanılır.

    command: ping -c 4 www.google.com

##### container_name

Basit senaryolarda kullanılmasına gerek olmayan fakat bazı karmaşık senaryolarda çok işe yarayan bir opsiyondur. Önceki bölümlerde anlatıldığı gibi Compose Container isimlerini içinde bulunulan klasör, servis ismi ve önceden bu servis tanımından çalıştırılan Container sayısı gibi faktörlerden otomatik olarak oluşturur. Bu konfigürasyon opsiyonu kullanılarak Service tanımından oluşturulacak Container'ın isimleri otomatik oluşturmak yerine böylece belirlenebilir.

Kullanım senaryosunu örneklemeye çalışalım. Docker Compose ile oluşturduğumuz sistemde herhangi bir nedenden dolayı Container'lardan birinde oluşan bir dosyanın `docker cp` ile Host'a taşınmasının gerektiğini düşünelim. `docker cp` komutuna Container'ın isminin sağlanması gerekmektedir. Servis tanımında eğer `container_name` özel bir isim seçilirse istenen dosya `docker cp` ile rahatlıkla kopyalanabilir. Aşağıdaki gibi kullanılabilir.

    container_name: db-seeder-container

##### depends_on

`docker-compose up` birden fazla Service tanımının olduğu Compose dosyalarında servisleri birbirlerine olan bağımlılıklarına göre sırayla başlatır. Eğer Service'ler arasında bir ilişki tanımı yoksa tanım sırasına göre başlatır. Servislerin birbirleri ile olan ilişkileri `depends_on` opsiyonu ile belirlenir. `docker-compose up`'a parametre ile bir servis ismi verildiğinde Compose öncelikle ilgili Service'in bağımlı olduğu Service'leri ve sonra ilgili Service'i başlatır. nginx-service servisinin ruby-service'e ruby-service'in de redis-service'e bağımlı olduğunu düşünelim. Bu durumda aşağıdaki gibi bir kullanım uygun olur.

    version: '2'

    services:
        nginx-service:
            build: WebSite
            depends_on:
                - service-b

        ruby-service:
            build: WebApp
            depends_on:
                - nginx-service
        
        redis-service:
            image: redis

Başlangıçta bu opsiyon hep yanlış anlaşıldığı için ve muhtemelen siz de yanlış anlayacağınız için bu yanlış anlaşılmayı en baştan düzeltelim isterseniz. `depends_on` Service'leri başlatırken Service'lerin çalışmaya hazır hale gelip gelmediğini beklememektedir. Yukarıdaki örnekte, `ruby-service`'in `redis-service`'e bağımlılığı vardır. Burada `redis-service` Container'ı başlatıldıktan hemen sonra `ruby-service` Container'ı başlatılacaktır. Eğer Ruby uygulaması ilk açılışta Redis sunucunun hazır olup olmadığını kontrol ediyorsa ve hazır olmadığında hata veriyorsa Compose ile başlatıldıktan sonra muhtemelen hata verecektir çünkü Redis Container'ı ile Ruby App'inin Container'ı ile neredeyse aynı anlarda başlatılmış olmaktadır, Ruby App'inin Redis'in ayağa kalkması beklenmemektedir. Ruby App'inin Redis'in ayağa kalkmasının beklenmesi için bazı 3rd party mekanizmalar vardır ve bu hazırlayacağımız başka bir blog'un konusunu olacaktır fakat açık bir şekilde `depends_on` bu işe yaramamaktadır.

Bu durumda `depends_on` ne işe yaramaktır sorusunun cevabını yukarıdaki örneğe göre tekrar verelim. `docker-compose up ruby-service` komutu verilerek `ruby-service` ve bağımlılıklarının kaldırılması istendiğinde eğer `depends_on` opsiyonu ile `nginx-service`'e olan bağımlılık belirlenmeseydi bu servis başlatılmamış olacaktı.

##### dns

Service'ten oluşturulacak Container'lar tarafından kullanılacak DNS sunucu veya sunucuları bu komut ile değiştirilebilir. Aşağıdaki gibi kullanılır.

    dns: 8.8.8.8

    veya

    dns:
        - 8.8.8.8
        - 8.8.4.4

##### environment

Service'ten oluşturulacak Container'lara yeni Environment Variable'lar bu opsiyon ile eklenebilir. Aşağıdaki gibi kullanılır.

    environment:
        - MODE=PROD
        - DEBUG=true
        - PASSWORD=secret

##### expose

Host'a açmadan Container'lar arasında port'ları açmak için kullanılır. Dockerfile'daki `EXPOSE` komutu ile aynı işe yarar.

    expose:
        - "5432"

##### extra_hosts

DNS sunucularda tanımlı olmayan fakat Container içerisiden isimleri ile erişilebilmesini istediğimiz IP'lerin Container'lardaki `/etc/hosts` dosyasına yazılması için kullanılan bir opsiyondur. Aşağıdaki gibi kullanılır.

    extra_hosts:
        - "local.server:192.168.0.22"
 
##### image

Service'ten oluşturulacak Container'ların başlatılacağı Image'ı belirler. Eğer Service tanımında `build` opsiyonu varsa yani Container'lar hazır bir Image'dan yaratılmak yerine `Dockerfile` ile build edilecek bir Image'dan yaratılacaksa bu opsiyonda verilen isim oluşturulacak Image'a verilir. Aşağıdaki gibi kullanıldığında DockerHub'dan çekilecek Image'ın ismini belirler.

    image: nginx

Aşağıdaki gibi kullanıldığında ise MyWebApp Image'ı build edilerek gsengun/mywebapp:1.0 olarak tag'lenir.

    image: gsengun/mywebapp:1.0
    build:
        context: ./MyWebApp
        dockerfile: Dockerfile-MyWebApp

##### networks

Service'ten oluşturulacak Container'ların dahil olacağı Network'leri (Network konfigürasyonu bölümünde detaylı olarak inceleyeceğiz) belirler. Aşağıdaki gibi kullanılır.

    my-service:
        networks:
            - nosql-network

##### ports

Service'ten oluşturulacak Container'lardan Host'a map'lenecek (forward edilecek) portları belirler. En çok kullanılan opsiyonlardan biridir. Aşağıdaki örnekte ilk satırda Host'taki 5432 portu Container'daki aynı port'a map'lenmektedir. İkinci satırda ise 16000 ile 17000 arasındaki bütün port'lar Host'tan Container'e doğru forward edilmektedir. 

    ports:
        - "5432:5432"
        - "16000-17000:16000-17000"

##### volumes

`volumes` opsiyonu üç farklı şekilde kullanılır. Aşağıda bu üç kullanım şekli verilmiş ve örneklenmiştir.

1. Host üzerindeki bir klasörün Container'a mount edilmesi:

    Aşağıda Host üzerindeki `/Users/gsengun/Desktop/App` klasörü Container üzerindeki /var/lib/app klasörüne mount edilmiştir. 
    
        services:
            my-service:
                volumes:
                    - /Users/gsengun/Desktop/App:/var/lib/app

    Aşağıda Host dosyasında Dockerfile'a göre relatif olan `./App` klasörü Container üzerindeki  /var/lib/app klasörüne mount edilmiştir.

        services:
            my-service:
                volumes:
                    - ./App:/var/lib/app

2. Container üzerinde bir volume yaratılması:

    Container durdurulduktan sonra ve hatta eğer kasıtlı olarak silinmez ise kaldırıldıktan sonra bile ulaşılabilecek bir Volume yaratmak için opsiyon aşağıdaki gibi kullanılabilir.

        services:
            my-service:
                volumes:
                    - /var/lib/app

3. Volumes konfigürasyonunda tanımlanan bir Volume'un Container tarafında görünür hale gelebilmesi:

    Compose, tanımlanan bütün servisler'den oluşturulan Container'lar tarafından erişilebilecek ve yaşam döngüsü Container'larınkinden bağımsız olarak yönetilebilecek bir Volume (`Named Volumes`) tanımlanmasına olanak tanımaktadır. Bu şekilde oluşturulan Volume'un nasıl mount edileceği aşağıda örneklenmiştir. 

        services:
            my-service:
                volumes:
                    - my-volume:/var/lib/app

        volumes:
            my-volume:
                driver: local

#### Volume Konfigürasyonu

Volume'ları Container bazlı olarak tanımlayabileceğimizi zaten biliyoruz. Compose dosyası içinde bulunan bütün servisler tarafından erişilebilir durumda olan ve ayrıca Docker CLI tarafından sağlanan `docker volume` komutu ile incelenebilecek Volume'lar `Named Volumes` olarak adlandırılmaktadır. 

İnce işler yapmak için detaylı konfigürasyon yapılabilmekle birlikte bizim kullanacağımız çerçeve aşağıdaki gibidir. 

    volumes:
        my-named-volume:
            driver: local

#### Network Konfigürasyonu

Compose kompleks sistemlerde kullanılmak üzere kapsamlı Network konfigürasyon opsiyonları sağlamaktadır fakat bizim ihtiyacımız olan çerçevede bu detaya ihtiyaç bulunmadığı için burada bunlara yer vermeyeceğiz.

### Docker Compose ile Oluşturulmuş Karmaşık Bir Sistemi İncelemek

#### Uygulama Tanıtımı

Bütün bu öğrendiklerimizi yapısı karmaşık (dolayısıyla Compose'un birçok özelliğini görebileceğimiz) ancak fonksiyonalitesi sade (dolayısıyla uygulamanın mantığından çok Compose'un mantığına odaklanabileceğimiz) bir uygulamada test ederek öğrendiklerimizi iyice pekiştirelim.

Bu uygulamanın orjinal hali [bu linkten](https://github.com/docker/example-voting-app.git), bu blog için Github'dan fork edilen hali de [bu linkten](https://github.com/gokhansengun/example-voting-app.git) indirilebilir. Uygulamayı bir klasöre indirdikten sonra ilgili klasöre giderek `docker-compose up` komutunu çalıştırırsanız uygulamayı kendi bilgisayarınızdan da test edebilirsiniz. Sanırım bu kolaylık Docker Compose'u tek cümlede açıklamaya yetti :)

Örnek uygulama olarak Docker ile ilgili birçok demoda kullanılan `Voting App`'i kullanacağız. Uygulamanın sunduğu fonksiyon, bir anketle kullanıcılara kedileri mi yoksa köpekleri mi daha çok sevdiklerini sormak ve bütün kullanıcılardan gelen cevapları kümüle bir şekilde yüzde olarak göstermektir.

Uygulamanın kullanım şekli basitçe aşağıdaki hareketli resimde gösterilmiştir. 

{% include image.html url="/resource/img/DockerPart3/VotingAppUsage.gif" description="Voting App Usage" %}   

Uygulama yukarıda verilen bu basit fonksiyon için temel olarak 5 farklı servis kullanıyor böylece Docker Compose'un gücünü uygulama mantığını işin işine çok fazla sokmadan güzel bir şekilde örnekliyor. Aşağıdaki şekilde ve sonrasındaki açıklamalarda bu uygulamanın mimari yapısı özetlenmiştir.

{% include image.html url="/resource/img/DockerPart3/VotingAppArchitecture.png" description="Voting App Architecture" %}

* `voting-app` adlı servis Python web uygulaması kullanıcılardan kedi veya köpekleri seçebilmesini sağlamaktadır. `voting-app` servisi 5000 numaralı port'tan hizmet vermektedir.
* `redis` adlı servis klasik Redis memory cache uygulaması ile yeni oyları dağıtık memory'e kaydetmektedir.
* `worker` adlı servis bir .NET uygulamasıdır ve Redis'ten okuduğu yeni oyları alarak `db` servisine kaydetmektedir.
* `db` adlı servis bir Postgres veri tabanını kullanıma sunmaktadır.
* `result-app` adlı servis bir Node.js web uygulaması sunarak kullanıcılardan gelen oylardan oluşan anket sonucunu ekranda göstermektedir. `result-app` servisi 5001 numaralı port'tan hizmet vermektedir.

#### docker-compose.yml Dosyasının İncelenmesi

Şimdi fazla detaya girmeden uygulamanın `docker-compose.yml` dosyasını ve Service'leri oluşturan Image'ların nasıl oluşturulduğuna göz atacağız. İsterseniz siz de [bu linkten](https://github.com/gokhansengun/example-voting-app.git) uygulamanın kodunu indirerek kodları kendi bilgisayarınızdan inceleyebilirsiniz.

`docker-compose.yml` dosyasının içeriği aşağıda verilmiştir. Şimdi burada tanımlanan servislerin üzerinden teker teker geçelim.

    version: "2"

    services:
        voting-app:
            build: ./vote
            command: python app.py
            volumes:
                - ./vote:/app
            ports:
                - "5000:80"
        
        redis:
            image: redis:alpine
            ports: ["6379"]
            
        worker:
            build: ./worker
            
        db:
            image: postgres:9.4
        
        result-app:
            build: ./result
            command: nodemon --debug server.js
            volumes:
                - ./result:/app
            ports:
                - "5001:80"
                - "5858:5858"

##### voting-app Service'i

Bu servis aşağıdaki gibi tanımlanmıştır.

    voting-app:
        build: ./vote
        command: python app.py
        volumes:
            - ./vote:/app
        ports:
            - "5000:80"

`build: ./vote` ile `docker-compose.yml` dosyasının bulunduğu klasöre göre relatif olarak `vote` klasöründe bulunan `Dockerfile`'a göre Image'ın build edilmesi istenmiştir. İsterseniz burada bulunan `Dockerfile`'ı bu blog serisinin  [ikinci blog](/docker-yeni-image-hazirlama/)'unda öğrendiğiniz bilgiler çerçevesinde inceleyebilirsiniz. `command: python app.py` ile Image build edildikten sonra Container oluşturulurken Image tarafından verilen default CMD'nin ezilmesi ve `python app.py` komutunun verilmesi konfigüre edilmiştir. 

`volumes:` düğümünde verilen `- ./vote:/app` Host dosya sistemindeki `./vote` klasörünün, Service'ten oluşturulacak Container'ların `/app` klasörüne Mount edilmesi istenmiştir. `ports:` düğümünde verilen `- "5000:80"` ile de Host üzerindeki 5000 port'una gelen isteklerin Container'ın 80 numaralı port'una yönlendirilmesi konfigüre edilmiştir.

##### redis Service'i

Bu servis aşağıdaki gibi tanımlanmıştır.

    redis:
        image: redis:alpine
        ports: ["6379"]

`image: redis:alpine` Service tanımından yola çıkılarak oluşturulan Container'ların baz alacağı Image'ın `redis:alphine` olduğunu tanımlamıştır. İkinci satırdaki `ports: ["6379"]` ile Container içerisindeki 6379 port'u (Redis'in default portu) rastgele bir Host portu üzerinden Host'a açılmıştır. Bu konfigürasyon olası problemlerde Container'a Host üzerinden erişebilmek ve Redis'i kontrol edebilmek amacı ile yapılan bir harekettir. Host dosyasında hangi port'a map'lendiğini öğrenmek için `docker-compose ps` veya `docker-compose ps redis` komutlarını koşturabilirsiniz. Bu komutların çıktısından görebileceğimiz gibi Container içerisindeki 6379 portu Host üzerinde 32772 port'una map'lenmiştir. Host üzerinden bu port'u kullanarak Redis'e ulaşabiliriz.

    Gokhans-MacBook-Pro:DCVoteApp gsengun$ docker-compose ps redis
        Name                     Command               State            Ports
    ------------------------------------------------------------------------------------
    dcvoteapp_redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:32772->6379/tcp

##### worker Service'i

Bu servis aşağıdaki gibi basit bir şekilde tanımlanmıştır.

    worker:
        build: ./worker

Burada Compose'a `docker-compose.yml` dosyasına göre relatif olarak `worker` klasörüne gitmesi ve oradaki Dockerfile'ı build etmesi sonra da oluşan Image'ı bu servis için yeni bir Container yaratırken kullanması salık verilmiştir. Yine bu klasördeki Dockerfile'ı [ikinci blog](/docker-yeni-image-hazirlama/)'unda öğrendiğiniz bilgiler çerçevesinde inceleyebilirsiniz.

##### db Service'i

Bu servis aşağıdaki gibi çok basit bir şekilde tanımlanmıştır ve bu servis tanımından oluşturulacak Container'ların direkt olarak `postgres:9.4` Image'ından oluşturulabileceğini konfigüre etmiştir.

    db:
        image: postgres:9.4

##### result-app Service'i

Bu servisin tanımı aşağıda verilmiştir. Şimdi teker teker ilgili satırları inceleyelim.

    result-app:
        build: ./result
        command: nodemon --debug server.js
        volumes:
            - ./result:/app
        ports:
            - "5001:80"
            - "5858:5858"

Önceki servislerde de tekrar ettiğimiz gibi `build: ./result` satırı `docker-compose.yml` dosyasına göre relatif olarak `./result` klasöründe bulunan `Dockerfile`'ın build edilerek bu Service için oluşturulacak Container'larda kullanılması salık verilmiştir. `command: nodemon --debug server.js` satırı ile kullanılacak Image'ın default `CMD`'si ezilerek ilgili komutun koşturulması sağlanmıştır.

`voting-app` servisine benzer şekilde `volumes:` düğümünde verilen `- ./result:/app` Host dosya sistemindeki `./result` klasörünün, Service'ten oluşturulacak Container'ların `/app` klasörüne Mount edilmesi istenmiştir. `ports:` düğümünde verilen `- "5001:80"` ile de Host üzerindeki 5001 port'una gelen isteklerin Container'ın 80 numaralı port'una yönlendirilmesi `- "5858:5858"` ile de Host üzerindeki 5858 Container'ın aynı port'una yönlendirilmesi konfigüre edilmiştir. 5001 port'u uygulamanın sunulabilmesi için 5858 portu ise Node.js uygulamasının debug edilebilmesi için Host'a sunulmuştur. 

### Sonuç

Bu blog'da Docker'ı günlük hayat kullanımında çok daha etkili kılan Docker Compose'u çok detaylı bir biçimde inceleyerek Docker'la ilgili üç blog'luk blog serimizi tamamlamış olduk.

Bundan sonraki blog yazılarındaki bütün örnek uygulamaları (demo'ları) Docker kullanarak vereceğiz ve bu blog serisinde öğrendiğimiz bilgiler emin olun çok işimize yarayacak.
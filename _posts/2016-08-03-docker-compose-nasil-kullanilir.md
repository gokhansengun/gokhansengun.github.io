---
layout: post
title: "Docker Bölüm 3: Docker Compose Hangi Amaçlarla ve Nasıl Kullanılır?"
level: Başlangıç
progress: continues
---

Docker blog serimizin ilk iki bölümünde Docker'ı günlük hayatta kullanmaya başlamak için gerekli bilgi seviyesini oluşturmak için Docker ve sunduğu olanakları yakından tanımaya çalıştık. Bu blog'da ise Docker'ı gerek geliştirme, gerek test ve gerekse de üretim ortamında nasıl kullanabileceğimiz ile ilgili çok pratik ve genellikle demo'lardan oluşan bilgileri elde edeceğiz. Eminim verilen örnekler sizin kafanızda da farklı çağrışımlar uyandıracak ve siz de kendinizi her gün uğraştığınız işlerde Docker kullanarak nasıl daha verimli olabileceğinize dair düşünceler içinde bulacaksınız.

Docker blog serisinin ilk ikisi aşağıda verilmiştir. Eğer bu blog'ları daha önce okumadıysanız okumanızı şiddetle tavsiye ederim.

[Docker Bölüm 1: Nedir, Nasıl Çalışır, Nerede Kullanılır?](/docker-nedir-nasil-calisir-nerede-kullanilir/)

[Docker Bölüm 2: Yeni bir Docker İmajı Nasıl Hazırlanır?](/docker-yeni-image-hazirlama/)

### Çalışma Özeti

Öncelikle bu blog'da anlatılacak özellikler Docker-Compose'un 1.6 versiyonu ve sonrasında desteklenmektedir. Komut satırında `docker-compose version` komutunu vererek kullandığınız versiyon ile ilgili bilgi alabilirsiniz. Eğer bu komutun çıktısında görülen versiyon 1.6 altındaysa bu blog'da yazılanları takip edebilmek için kullandığınız versiyonu yükseltmeniz gereklidir. 

Bu blog'da aşağıdaki adımları tamamlayarak Docker'ın günlük hayatta kullanımı ve getirdiği kolaylıkları daha yakından tanıma fırsatı bulacağınızı düşünüyorum.

* Öncelikle Docker Compose'un ne işe yaradığı ve hangi problemi çözdüğü üzerinde duracağız.
* Motivasyon olması açısından en basit haliyle bir docker-compose.yml dosyası oluşturarak basit bir sistemi ayağa kaldıracağız.
* docker-compose.yml dosya yapısını ve konfigürasyon opsiyonlarını inceleyerek devam edeceğiz.
* Görece kompleks bir yapıyı Docker Compose ile kurgulayarak çalıştıracak ve bu blog'u kapatacağız.

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

`docker-compose` aracı Docker CLI ve Docker Daemon'ı da sağlayan `Docker Inc` tarafından sunulmakta ve genellikle bütün platformlarda Docker bundle'ı ile birlikte gelmektedir. Docker Compose'un ne işe yaradığını anladıktan sonra şimdi basit bir sistem ve senaryo ile kavramları ve kullanımını örneklemeye çalışalım.

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

2. Terminal veya komut satırı açarak `docker-compose.yml` dosyasının bulunduğu klasöre gidin ve `docker-compose up` komutunu verin. Docker Compose, YAML dosyasında bulunan bütün Image'ları önce pull edip (eğer daha önce pull edilmediyse) sonra da çalıştıracaktır. Siz de benim gibi `nginx` Image'ını DockerHub'dan daha önce indirdiyseniz aşağıdakine benzer bir çıktı görmelisiniz.

        Gokhans-MacBook-Pro:DCBlog gsengun$ docker-compose up
        Creating network "dcblog_default" with the default driver
        Creating dcblog_company_a_web_server_1
        Creating dcblog_company_b_web_server_1
        Creating dcblog_company_c_web_server_1
        Attaching to dcblog_company_a_web_server_1, dcblog_company_c_web_server_1, dcblog_company_b_web_server_1

    Çıktıdan görebileceğiniz gibi Docker Compose öncelikle `dcblog_default` adında bir network yarattı sonra benim klasör ismim olan `DCBlog` ve servis isimlerini `company_x_web_server` birleştirip Container'lara vererek onları teker teker çalıştırdı. En son satırda ise terminali çalıştırılan bu Container'lara attach ettiğini görüyoruz. Bu çıktı ile ilgili farklı açılardan bakarak detaylı analizler yapacağız fakat öncelikle demo'yu tamamlayalım.

3. Web tarayıcıyı açarak `http://localhost:8001`, `http://localhost:8002` ve `http://localhost:8003` adreslerinden Nginx'in default sayfasının gelip gelmediğini kontrol edin. Sizde de aşağıdakine benzer bir görüntü oluşmalı. Ben aşağıya sadece A şirketinin web sitesi kabul ettiğimiz Container'ın sunduğu ana sayfanın ekran çıktısını aldım.

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

    ÖNEMLİ NOT: `docker-compose down` komutuna `-v` parametresi eklemek Compose kapsamında başlatılan herhangi bir Container ile ilişkilendirmiş Volume'ları da silmektedir. Henüz Volume'ların ne olduğundan bahsetmedik ancak Container'da oluşturulan bilgiyi kaybetmek istemiyorsanız `-v` parametresi ile çalıştırmamanız gerektiğini aklınızın bir kenarında tutmanız gerekir.


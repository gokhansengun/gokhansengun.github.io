---
layout: post
title: "Docker İpuçları - Soru / Cevap - Bölüm 1"
level: Orta
published: true
lang: tr
ref: docker-tips-question-and-answer-part-1
blog: yes
---

Önceki blog yazılarında Docker'ın çıkış nedenini, çözdüğü problemleri ve kullanım alanlarını örneklerle açıklamış ve Docker'a aşinalık sağlamayı hedeflemiştik. Bu blog yazılarına birçok güzel yorum ve bir o kadar da soru geldi, hepsini elimizden geldiğince cevaplamaya çalıştık. Şimdi sıra kendi iş akışımızı Docker ile dönüştürme serüveninde herkesin işine yarayabilecek, Docker'ın kullanım alanlarını güzel bir şekilde örnekleyecek, Docker'ın getirdikleri ve götürdüklerinin daha iyi anlaşılmasına olanak tanıyacak bilgileri paylaşmaya geldi. 

Bu blog yazısı ve bunu takip edecek birkaç blog yazısında, soru ve cevaplarla Docker ile ilgili ipuçlarına yer vereceğiz. Öncelikle soruyu soracak, sonra sorunun çıkış nedenlerini araştıracak ve en son olarak da çalışan bir örnekle soruyu bir veya daha fazla yolla cevaplandırmaya çalışacağız.

Docker ile ilgili önceki üç blog yazısını okumadıysanız öncelikle aşağıda bulacağınız bu yazıları okumanızı tavsiye ederiz.

[Docker Bölüm 1: Nedir, Nasıl Çalışır, Nerede Kullanılır?](/docker-nedir-nasil-calisir-nerede-kullanilir/)

[Docker Bölüm 2: Yeni bir Docker Image'ı Nasıl Hazırlanır?](/docker-yeni-image-hazirlama/)

[Docker Bölüm 3: Docker Compose Hangi Amaçlarla ve Nasıl Kullanılır?](/docker-compose-nasil-kullanilir/)

### Soru 1

X servisinin Y servisine bağımlılığı var. X servisini koşturan container Y servisi tam olarak ayağa kalkmadan Y servisine ulaşmaya çalışınca hata alıp çıkıyor ve fonksiyon kaybı oluşuyor. X ve Y servisleri Docker Container'larla nasıl senkronize edilebilir?

#### İhtiyaç Duyulan Durumlar

Uygulama sunucunuzun (App Server) doğal olarak veri tabanınıza bağımlılığı vardır. Bu servislerinizi Docker CLI ile (veya Docker Compose CLI ile) aynı anda çalıştırdığınız ve uygulama sunucunuzun veri tabanından hızlı bir şekilde ayağa kalkıp veri tabanını sorguladığı durumlarda bu problemle karşılaşabilirsiniz. Bu duruma en güzel örnek Continuous Integration (CI) Pipeline'ıdır. Yeni uygulama versiyonunu paketleyip, birim, entegrasyon ve kabul testleri için bütün servisleri ayaklandırdığınızda uygulama sunucunuzu koşturan Docker Container ile veri tabanı sunucunuzu koşturan Docker Container arasında Race Condition oluşabilir.

Bu noktada uygulama sunucusunun başlarken veri tabanına neden eriştiği ile ilgili bir soru takılması normaldir çünkü akla daha yatkın olan uygulama sunucusunun dışarıdan gelen ilk istekte veri tabanına erişim yapması ve veri tabanına erişimde hata durumunda bütün servisin değil sadece ilgili isteğin etkilenmesidir. Normal akış bu olsa bile uygulama sunucusu ilk kez başlatılırken veri tabanında Migration (veri tabanındaki şema versiyonunun yükseltilmesi) yapmak isteyebilir. Migration yapmak üzere veri tabanına ulaşamayınca bunu ciddi bir hata olarak değerlendirip çalışmayı durdurabilir.

Migration işlemini uygulama sunucusu yerine bir kereye mahsus çalışan ve bu iş için özelleşmiş [Flyway](https://flywaydb.org/) gibi bir araca da yaptırmak isteyebilirsiniz. Tahmin edebileceğiniz gibi Migration aracının da öncelikle veri tabanının ayağa kalkmasını beklemesi gerekecektir.

#### Problemin Gösterimi

Öncelikle tasvir ettiğimiz bu problemi bir örnek ile gösterelim ve kendimiz test edelim.

Gösterim kolaylığı açısından Flyway Migrator ile Postgres örneğini verelim ve Docker Compose kullanalım.

Belirtilen adımları siz de takip etmek istiyorsanız bu blog için hazırladığım [Github Repository](https://github.com/gokhansengun/Docker-Tips-with-QA)'sini klonlayıp komut satırında repo içindeki `Question-1/Problem` klasörüne geçin. Yolumuz düşerse ve beğendiysek Github'da Star vermeyi ihmal etmeyelim :-)

Bu klasörde içeriği aşağıda verilen ve `db` ve `flyway` adlı iki servis içeren Docker Compose dosyası ile karşılaşacaksınız.

```yaml
version: "2"

services:

    flyway:
        image: shouldbee/flyway
        volumes:
            - ./sql:/flyway/sql
        command: -url=jdbc:postgresql://db:5432/ -user="postgres" -password="secret" migrate

    db:
        image: postgres:9.4
        ports:
            - "5432:5432"
        environment:
            - POSTGRES_PASSWORD=secret

```

`docker-compose up` komutunu vererek servisleri çalıştırın. Siz de aşağıdaki örnekte görülene benzer bir çıktı almalısınız. Gördüğünüz gibi `flyway_1` Container'ında çalıştırılan `flyway` servisi hızlı davranarak ayağa kalktı fakat Postgres o sırada henüz hazır olmadığı için bağlantı kuramadığını söyleyip çıkış yaptı. Logu takip ettiğimizde `flyway_1` çıkış yaptıktan bir süre sonra `db_1` Container'ında çalıştırılan Postgres servisinin bağlantıları kabul etmeye ancak hazır hale gelebildiğiniz görüyoruz. 

```
db_1      | setting privileges on built-in objects ... ok
flyway_1  | ERROR: Unable to obtain Jdbc connection from DataSource (jdbc:postgresql://db:5432/) for user 'postgres': Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
db_1      | creating information schema ... ok

......

db_1      | LOG:  database system is ready to accept connections
db_1      | LOG:  autovacuum launcher started
```

#### Ek Soru

Docker Compose'da bulunan [depends_on](https://docs.docker.com/compose/compose-file/#dependson) Keyword'ü bunun için neden kullanılamıyor?

Docker Engine, bir Container'ın çalıştırdığı servisin ayakta olup olmadığını mevcut yapıda bilmemektedir. Docker Engine, servisin Container'da çalıştırılacağı izole ortamı hazırladıktan ve kontrolü uygulamanın belirttiği Entrypoint ve Command'e verdikten sonra uygulama bir Exit Code ile çıkış yapana kadar uygulamanın yaşam döngüsünden haberdar değildir. Docker, örneğimizdeki Postgres veri tabanının 5432 portundan dinlemeye başlayıp başlamadığı ile ilgilenmemektedir, kaldı ki bir uygulamanın tam anlamıyla ayağa kalkıp kalkmadığı da (bir uygulama birden fazla özelliği hizmete sunabilir) tartışmalı bir konudur.

### Cevap 1

Soruyu, dolaylı olarak da ihtiyacı bir örnekle açıkladıktan sonra şimdi cevap alternatiflerini konuşmaya başlayabiliriz.

#### Alternatif 1 

En az zahmetle problemi çözmemize olanak tanıyacak yöntem, `Flyway` servisi başarılı bir şekilde çıkış yapana kadar servisi Docker Compose'a sürekli restart ettirmek olabilir.

Önce yöntemi deneyelim sonra da artı ve eksilerini konuşalım.

Komut satırında repo içindeki `Question-1/Alternative-1` klasörüne geçin. Fark edebileceğiniz gibi `docker-compose.yml` dosyasında `flyway` servisinin tanımına `restart: on-failure:10` eklendi. Bu tanıma göre Docker Compose `flyway` servisinden ürettiği Container'ların hata ile çıktığı ilk 10 denemeden sonra servisi tekrar çalıştıracak, eğer 10 deneme sonunda yine hata alınırsa artık servisi tekrar çalıştırmayı denemeyecek. Burada `restart: on-failure:10` yerine `restart: always` kullansaydık servisten oluşturulan Container bir hata ile de çıksa hatasız da çıksa her çıkıştan sonra yeni bir Container yaratılacaktı. Uygulama sunucusu vb durumlarda istediğimiz davranış bu olacak olsa da biz Migration'ın sadece bir kere koşmasını istiyoruz.

```yaml
....

    flyway:
        image: shouldbee/flyway
        restart: on-failure:10 =========>>>> YENI
        volumes:
            - ./sql:/flyway/sql

....
```

`docker-compose up -d` yaparak servisleri Detached modda (Terminal'e output vermeden arka planda) çalıştırın. Daha sonra `docker-compose logs -f flyway` komutunu vererek `flyway` servisine ait Container'dan gelen logları izlemeye başlayın. Görebileceğiniz gibi `flyway` 3 kere hata alıp çıktıktan sonraki denemede Postgres'in ayağa kalkması sonucunda işlemi tamamlamış ve çıkmıştır.

```
Alternative-1 $ docker-compose logs -f flyway
Attaching to alternative1_flyway_1
flyway_1  | Flyway 3.2.1 by Boxfuse
flyway_1  |
flyway_1  | ERROR: Unable to obtain Jdbc connection from DataSource (jdbc:postgresql://db:5432/) for user 'postgres': Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
flyway_1  | Flyway 3.2.1 by Boxfuse
flyway_1  |
flyway_1  | ERROR: Unable to obtain Jdbc connection from DataSource (jdbc:postgresql://db:5432/) for user 'postgres': Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
flyway_1  | Flyway 3.2.1 by Boxfuse
flyway_1  |
flyway_1  | ERROR: Unable to obtain Jdbc connection from DataSource (jdbc:postgresql://db:5432/) for user 'postgres': Connection refused. Check that the hostname and port are correct and that the postmaster is accepting TCP/IP connections.
flyway_1  | Flyway 3.2.1 by Boxfuse
flyway_1  |
flyway_1  | Database: jdbc:postgresql://db:5432/ (PostgreSQL 9.4)
flyway_1  | Validated 1 migration (execution time 00:00.013s)
flyway_1  | Creating Metadata table: "public"."schema_version"
flyway_1  | Current version of schema "public": << Empty Schema >>
flyway_1  | Migrating schema "public" to version 0001 - InitialSetup
flyway_1  | Successfully applied 1 migration to schema "public" (execution time 00:00.340s).
alternative1_flyway_1 exited with code 0
```

#### Alternatif 1'in Artıları ve Eksileri

Bu alternatifin ilk artısı gördüğünüz gibi çok kolay adapte edilebilmesidir. Servisler arasındaki senkronizasyon problemini çözmemiz sadece 1 satırlık bir kod gerektirdi, fazla bir efor harcamadık.

Alternatif için sayılabilecek ilk eksi nokta ise burada Docker Compose'a bağımlılık yaratmamızdır. Docker Compose ile gelen Restart özelliğini kullandık. Eğer uygulamanın bütün yaşam döngüsünde (geliştirici ortamı, test ortamı ve üretim ortamı) Docker Compose kullanıyorsak bu bir problem teşkil etmeyecektir ancak örneğin üretim ortamında Kubernetes, Docker Swarm, vb bir Scheduler kullanıyorsak Docker Compose'un sağladığı `restart: on-failure:10` özelliğinin Scheduler'lar tarafından da benzer davranışla sağlanmasını beklememiz gerekir. Neyse ki bu temel özelliği neredeyse bütün Scheduler'lar sağlamakta :-) Burada yer vermemin sebebi karar alma kriterleri konusunda pratik yapmak.

İkinci eksi nokta bağımlı olan servisin (örneğimizde Flyway) defalarca başlatılmasının gerek işlem yoğunluğu, gerekse iş kuralları gereği çok maliyetli olması tehlikesidir. Flyway'in başlatılırken hata aldığında geri alınması gereken (örneğin Transactional) bir işlem yapması gerekseydi veya veri tabanına ulaşıncaya kadar 10 saniyelik başka hazırlıklar yapması gerekseydi onu defaatle başlatırken bu kadar rahat olamayacaktık :-)

Üçüncü ve belki de en önemli eksi nokta tekrar başlattığımız servise (örnekte Flyway'e) de bağımlı başka servis ya da servisler olması ve bu servislerin de zincir şeklinde yeniden başlatılmasının gerekmesi ve ortada tam bir restart kaosu yaşanması tehlikesidir. Yaşanan restart kaosu sonrası servisler ayağa kalkacak fakat sıralı ve planlı bir kalkışa göre daha uzun süren ve ortaya çıkan log anlamında daha çok gürültü (Noise) üreten bir şekilde olacaktır.

#### Alternatif 2

İkinci alternatif olarak "Postgres taş çatlasa 10 bilemedin 15 saniyede ayağa kalkar" diyip Flyway'i 15 saniye bekledikten sonra çalıştırabiliriz. Fikir olarak bile kulağa çok hoş gelmese de operasyonel kabiliyetlerimizi artırmak adına bu çözümü de deneyelim ve sonucu görelim.

Kullandığımız `shouldbee/flyway` Docker Image'ında `flyway` komutu Entrypoint olarak kullanıldığı için bu Container'da Sleep yapabilmek için bir bölümünü aşağıda da görebileceğiniz `docker-compose.yml` dosyasında `entrypoint: []` ile Image'daki mevcut Entrypoint'i Override etmemiz gerekiyor. Aşağıda da görebildiğiniz gibi Flyway servisinden oluşturulacak Container'lara komut olarak öncelikle ekrana bilgilendirme mesajı yazan, 15 saniye bekleyen sonra da Migration'ı gerçekleştiren bir dizi verilebilir. Github Repo'sunda `Question-1/Alternative-2` klasöründe çalışan kodu bulabilirsiniz. `docker-compose up` komutunu vererek Migration'ın başarılı bir şekilde gerçekleştiğini görebilirsiniz.

```yaml
....

    flyway:
        image: shouldbee/flyway
        entrypoint: []
        volumes:
            - ./sql:/flyway/sql
        command: bash -c "echo 'Sleep 15 secs' && sleep 15 && flyway -url=jdbc:postgresql://db:5432/ -user=postgres -password=secret clean"

....
```

#### Alternatif 2'nin Artıları ve Eksileri

En belirgin eksi yön, belirli deneyler sonucu belirlediğimiz 15 saniyenin işlem gücü yüksek olan sistemler için çok uzun düşük olan sistemler için ise çok kısa olabileceğidir. Bu yöntem ile sahip olunan kaynaklar yeterince etkin kullanılamamaktadır. Bu alternatifte üzerinde durulmaya değer pek bir artı yön bulunmamaktadır.

#### Alternatif 3

En makul olan alternatif üçüncü alternatif olarak öne çıkmaktadır. Bu alternatifte bir Wrapper script ile belirli kısa aralıklarla bağımlılık bulunan servisin ayağa kalkıp kalkmadığı test edilip ayağa kalktıktan sonra ise bağımlı servisin çalıştırılması sağlanmaktadır.

Önerilen yöntemde `flyway` servisinden üretilen Container, `db` servisinden üretilen Postgres Container'ındaki TCP 5432 portu sorgulanabilir ve portun açık hale gelmesi, servisin ayağa kalkması olarak değerlendirilebilir. Bu yöntem Postgres için sağlıklı bir yöntemdir.

TCP portu sorgulamaya alternatif olarak `psql` aracı ile belirli aralıklarla Postgres'e bağlantı yapılması denenebilir ve bağlantı yapılabilmesi servisin ayağa kalkması olarak değerlendirilebilir. Bu yöntemle oluşturulan `Flyway` Image'ına [gsengun/flyway-postgres](https://hub.docker.com/r/gsengun/flyway-postgres/)'dan, kaynak koduna ise [Docker-Hub-Flyway-Postgres](https://github.com/gokhansengun/Docker-Hub-Flyway-Postgres)'dan erişebilirsiniz.

Biz burada daha genel olarak kullanılabilecek TCP yöntemini örnekleyelim. İzleyeceğimiz yöntem `shouldbee/flyway` Image'ına ekleyeceğimiz bir script ile Postgres'in portunun açık olup olmadığını izlemek ve açıksa Migration'ı çalıştırmak olacak.

TCP bağlantı testini yapması tam da bu iş için üretilmiş, popüler [wait-for-it.sh](https://github.com/vishnubob/wait-for-it) script'ini kullanacağız. Aşağıda önceki örneklere göre değişen kısmı verilen `docker-compose.yml` dosyasında, `wait-for-it.sh` script'ini Container'ın içindeki `/scripts/wait-for-it.sh` klasörüne sadece okunur olarak koyduğumuza ve Timeout 30 saniye olacak şekilde `db:5432`'ün erişilebilir hale gelmesini beklediğimize dikkat edin.

```yaml
....

    flyway:
        image: shouldbee/flyway
        entrypoint: []
        volumes:
            - ./sql:/flyway/sql
            - ./wait-for-it.sh:/scripts/wait-for-it.sh:ro
        command: /scripts/wait-for-it.sh -t 30 db:5432 -- flyway -url=jdbc:postgresql://db:5432/ -user=postgres -password=secret migrate

....
```

Komut satırından `Question-1/Alternative-3` klasörüne erişerek önce `docker-compose up -d db; docker-compose up flyway` komutunu verin. Servisleri ayrı çalıştırarak `flyway` servisinin çıktısını daha net olarak görmeyi hedefliyoruz.

Verilen komutu çalıştırdığımızda terminalde aşağıdakine benzer bir çıktı oluşacak. Gördüğünüz gibi script'imiz maksimum 30 saniye bekleyecek şekilde portun erişilebilir olup olmadığına bakıyor ve 3 saniye sonra erişilebilir durumda olduğunu görerek Migration'ı çalıştırıyor.

```
Alternative-3 $ docker-compose up -d db; docker-compose up flyway
Creating network "alternative3_default" with the default driver
Creating alternative3_db_1
Creating alternative3_flyway_1
Attaching to alternative3_flyway_1
flyway_1  | wait-for-it.sh: waiting 30 seconds for db:5432
flyway_1  | wait-for-it.sh: db:5432 is available after 3 seconds
flyway_1  | Flyway 3.2.1 by Boxfuse
flyway_1  |
flyway_1  | Database: jdbc:postgresql://db:5432/ (PostgreSQL 9.4)
flyway_1  | Validated 1 migration (execution time 00:00.013s)
flyway_1  | Creating Metadata table: "public"."schema_version"
flyway_1  | Current version of schema "public": << Empty Schema >>
flyway_1  | Migrating schema "public" to version 0001 - InitialSetup
flyway_1  | Successfully applied 1 migration to schema "public" (execution time 00:00.322s).
alternative3_flyway_1 exited with code 0
```

#### Alternatif 3'nin Artıları ve Eksileri

Baştan da yazdığımız gibi bu alternatif kaynakları etkin bir biçimde kullandığı ve servisin tekrar tekrar başlatılmasına gerek bırakmadığı için en optimal alternatif olarak görünmektedir.

İlk eksi olarak `wait-for-it.sh` script'inin sadece TCP bazlı (ve dolayısıyla HTTP) servisleri beklemeye olanak tanıması verilebilir. İkinci eksi yön ise bir servisin TCP portu ile ulaşılabilir olmasının o servisin her durumda tam anlamı ile kullanılabilir olup olmadığını belirtmeyecek olmasıdır. `wait-for-it.sh` kullanımının farkında olmayan bir uygulama geliştirici sağladığı TCP servisin açılış kodunda öncelikle TCP port'u Bind ederek dinlemeye başlayıp sonra gerekli Initilization'ları yapmış olabilir. Dolayısıyla TCP port erişilebilir olduğu halde servis henüz fonksiyonel değildir.

### Kapanış

Blog'un bu serisindeki sorunun cevabı biraz kapsamlı oldu. Bundan sonraki bölümlerde açıklama ve detaylandırma kısmı çok geniş olmayan ipuçlarına da yer vereceğiz.


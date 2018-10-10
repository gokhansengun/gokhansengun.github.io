---
layout: post
title: "Docker İpuçları - Soru / Cevap - Bölüm 3"
level: Başlangıç
published: true
lang: tr
ref: docker-tips-question-and-answer-part-3
blog: yes
---

Şimdiye kadar yaptığımız birçok örnekte Docker Container'ları hep servis tipi (Web sunucu, yük dağıtıcı, Cache, Database) işler için kullandık. Docker Container'lar, servis tipi işlerde kullanılmanın yanında Batch olarak adlandırabileceğimiz, zamanlanarak veya isteğe bağlı çalışacak bir şekilde de kullanılabilirler. Soru / Cevap serimizin bu bölümünde Docker'ı Batch tipi işlerde kullanmamıza yardımcı olarak konseptleri ve teknikleri tanıyacağız.

Öncelikle **Container başlatıldıktan sonra** (Container ayakta olsa da olmasa da) Host'tan Container'a ve Container'dan Host'a nasıl dosya kopyalayabileceğimizi göreceğiz.

Bu özelliklerin hangi amaçlarla kullanılabileceğine bu blog boyunca yer yer değineceğiz fakat asıl olarak ilerleyen blog'larda bunu referans vererek işlemler yapacağız ve daha fazla kullanım alanı tanımlamış olacağız.

#### Önemli Uyarı

Bu blog'da yapılan işlemlerde Docker CLI Native olarak Linux üzerinde koşturulmuştur. Docker for Windows ve Docker for Mac kurulumlarında fonksiyonlar, bu blog'da belirtildiği gibi çalışmayabilir.

### Soru 3

Belirli bir klasöre konan dosyaları işleyen ve bu işlemlerden elde edilen bilgileri toplayarak öğrenen bir uygulamam var (örneğin bir Yapay Zeka uygulaması). Bu uygulama güncel dosyayı işlerken, önceden işlediği dosyalardaki bilgilere de ihtiyaç duyuyor. Dolayısıyla Container'ı Host'tan her yeni dosya geldiğinde yeniden başlatmak önceki dosyaların tekrar tekrar işlenmesini gerektireceği için performans problemi yaratmakta. Container çalışırken Host üzerinden Container içine nasıl dosya kopyalayabilirim?

#### Demo Ortamının Yaratılması

Gösterimi yapabilmek için Container içindeki `/opt/my-app/data/input` klasörüne eklenen dosyaları alıp işleyerek `/opt/my-app/data/processed` klasörüne taşıyan bir Docker Container yaratalım. Gösterimi kolaylaştırmak için yukarıda Yapay Zeka olarak tanımlanan uygulamamız basit bir Bash Script'i olsun ve dosyanın işlenmesi işlemini sadece ekrana bir mesaj bastırarak simüle edelim.

Belirtilen adımları siz de takip etmek istiyorsanız bu blog için hazırladığım [Github Repository](https://github.com/gokhansengun/Docker-Tips-with-QA)'sini klonlayıp komut satırında repo içindeki `Question-3/Demo` klasörüne geçin. Yolumuz düşerse ve beğendiysek Github'da Star vermeyi ihmal etmeyelim :-)

Bu klasörde içeriği aşağıda verilen, `program` adlı tek servis içeren Docker Compose dosyası ile birlikte Container'a kopyalayacağımız test dosyaları ve Container'ın çalıştırdığı simülasyon programıdır. 

```shell
Demo $ tree
.
├── data
│   ├── file-0.txt
│   ├── file-1.txt
│   ├── file-2.txt
│   ├── file-3.txt
│   └── file-4.txt
├── docker-compose.yml
└── program
    └── artificial-intelligence.sh
```

`Demo` klasöründe iken `docker-compose up program` komutunu vererek Container'ı çalıştırın. Ekranda aşağıdakine benzer bir çıktı görmelisiniz. Aşağıdaki çıktıdan `Creating demo_program_1` görebileceğiniz üzere yaratılan Container'ın ismi `demo_program_1` oldu. Önceki Docker Compose blog'undan hatırladığınız üzere Container isminin `demo` ile başlaması Demo klasöründe olduğumuzdan, `program` ile devam etmesi servis isminden, sondaki `1` ise ilgili servis için yaratılan ilk Container olmasından dolayıdır. Birazdan Container ismini cevap bölümünde kullanacağız.

```shell
Demo $ docker-compose up program
Creating network "demo_default" with the default driver
Creating demo_program_1
Attaching to demo_program_1
program_1  | Started listening on the changes for directory /opt/my-app/data/input
program_1  | Could not found /opt/my-app/data/input, creating the directory
program_1  | Could not found /opt/my-app/data/output, creating the directory
program_1  | Sleeping for 10 seconds for the next run
program_1  | No new files found for this interval
program_1  | Sleeping for 10 seconds for the next run
```

### Cevap 3

Soruyu ve demo ortamını hazırladıktan sonra şimdi cevaba geçebiliriz.

Öncelikle şunu belirtmek gerekir ki, Container çalışırken, Host'tan Container'a dosya kopyalanması aslında çoğunluk durumda kaçınılması gereken ve "Best Practice" olmayan bir durumdur. Tavsiye edilen yöntem, çalışan Container'daki dosyayı değiştirmekten ziyade, ilgili dosyayı veya klasörü Docker Container'a Mount etme veya duruma göre ilgili dosya ile yeni bir Image oluşturma ve bu Image'dan yeni bir Container yaratmaktır. Bu yöntemin neden "Best Practice" olduğunu ilerleyen zamanlarda başka bir blog yazısında tartışabiliriz.

Çok nadir olmakla birlikte, yukarıda belirtilen gibi, bazı özel durumlarda performans ve yönetilebilirliği artırmak için Container çalışırken, Host'tan Container'a dosya kopyalamak gerekebilir.

Host'tan Container'a dosya kopyalama sentaksı aşağıdaki gibidir. Yani ilk parametre Host sistemdeki PATH, sonraki parametre ise Container ID'den sonra konulan iki nokta ve Container içerisindeki PATH'dir.

```shell
docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH
```

Örneğin Host içindeki /a/b/c.txt dosyasını 12345678 ID'li Container içindeki /x/y/z.txt dosyası olarak kopyalamak istersek aşağıdaki komutu kullanabiliriz.

```
docker cp /a/b/c.txt 12345678:/x/y/z.txt
```

Demo Ortamının Yaratılması adımında zaten programı çalıştırmıştık. Şimdi başka bir terminal açarak yine `Question-3/Demo` klasörüne geçin. Yapmak istediğimiz şey `Demo/data/file-1.txt` dosyasını `demo_program_1` adlı Container'ın içindeki `/opt/my-app/data/input` klasörüne kopyalamak olduğu için aşağıdaki iki komuttan birini Container ismi veya ID'si ile kullanabiliriz.

```
# Relative Path kullanılarak
docker cp ./data/file-1.txt demo_program_1:/opt/my-app/data/input/

# Absolute Path kullanılarak
docker cp `pwd`/data/file-1.txt demo_program_1:/opt/my-app/data/input/
```

Bu komutlardan birini verdikten sonra Docker Compose ile başlattığınız Program ekranında aşağıdaki gibi `Processing file file-1.txt` bir çıktı görmelisiniz.

```shell
program_1  | Sleeping for 10 seconds for the next run
program_1  | Processing file file-1.txt
program_1  | Sleeping for 10 seconds for the next run
program_1  | No new files found for this interval
```

Pratik olması açısından dosyanın da gerçekten işlenip işlenmediğini anlamak için `/opt/my-app/data/input` ve `/opt/my-app/data/output` klasörlerinin içeriğini görüntüleyelim. Container'ın içine girmeden bunu `exec` komutu ile yapabiliriz. Gördüğünüz gibi `/opt/my-app/data/input` klasörüne kopyaladığımız `file-1.txt` adlı dosya `/opt/my-app/data/output` klasörüne taşındı.

```shell
Demo $ docker exec demo_program_1 ls /opt/my-app/data/input
Demo $ docker exec demo_program_1 ls /opt/my-app/data/output
file-1.txt
```

### Soru 4

Zaman zaman Container'a yaptırdığınız bir işlemin sonucunda oluşan dosyayı Host'a kopyalamak isteyebilirsiniz. Host'tan Container'a dosya kopyalamanın aksine bu durum "Best Practice" ile çok fazla ters düşen bir durum değildir. Continuous Integration Pipeline'ınınızda Container içinde koşturduğunuz Unit, Integration ve Acceptance test sonuçlarınızı Jenkins veya başka bir araçta ilgili Plugin'in raporlaması için Export etmek gibi bir ihtiyacınız olabilir.

Çalıştırıldığında 4K boyutunda Random sayılardan oluşan bir dosya oluşturan bir Container'ım var. Bu Container sonlandıktan sonra oluşan dosyayı Host üzerindeki bir klasörün içine nasıl kopyalayabilirim?

#### Demo Ortamının Yaratılması

Gösterimi yapabilmek için Container içinde öncelikle `/opt/my-app/data/random-4K.bin` isimli bir dosya oluşturan uygulamayı Bash Script'i ile yaratalım. Dosyanın başarılı oluşturulması üzerine Container çıkış yapsın. Container içindeki dosyanın boyutunu Host üzerinden görerek yaptığımız Setup'ı doğrulayabiliriz.

Belirtilen adımları siz de takip etmek istiyorsanız bu blog için hazırladığım [Github Repository](https://github.com/gokhansengun/Docker-Tips-with-QA)'sini klonlayıp komut satırında repo içindeki `Question-4/Demo` klasörüne geçin. Yolumuz düşerse ve beğendiysek Github'da Star vermeyi ihmal etmeyelim :-)

Bu klasörde içeriği aşağıda verilen, `program` adlı tek servis içeren Docker Compose dosyası ile birlikte Container'da çalıştırılacak ve data üretecek simülasyon programıdır. 

```shell
Demo $ tree
.
├── data
├── docker-compose.yml
└── program
    └── random-file-generator.sh
```

`Demo` klasöründe iken `docker-compose up program` komutunu vererek Container'ı çalıştırın. Ekranda aşağıdakine benzer bir çıktı görmelisiniz. Aşağıdaki çıktıdan `Creating demo_program_1` görebileceğiniz üzere yaratılan Container'ın ismi yine `demo_program_1` oldu ve dosya oluşturma işlemi bittikten sonra Container çıkış yaptı.

```shell
Demo $ docker-compose up program
Creating network "demo_default" with the default driver
Creating demo_program_1
Attaching to demo_program_1
program_1  | Up and running to generate a 4K-size random file
program_1  | Could not find /opt/my-app/data, creating the directory
program_1  | Outputing the file to /opt/my-app/data/random-4K.bin
program_1  | 8+0 records in
program_1  | 8+0 records out
program_1  | 4096 bytes (4.1 kB, 4.0 KiB) copied, 8.3719e-05 s, 48.9 MB/s
demo_program_1 exited with code 0
```

### Cevap 4

Soruyu ve demo ortamını hazırladıktan sonra şimdi cevaba geçebiliriz.

Container'dan Host'a dosya kopyalama sentaksı aşağıdaki gibidir. Yani ilk parametre Container ID'den sonra konulan iki nokta ve Container içerisindeki PATH, ikinci parametre ise Host sistemdeki PATH'dir.

```shell
Demo $ docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-
```

Örneğin 12345678 ID'li Container içindeki /x/y/z.txt dosyasını Host'a /a/b/c.txt dosyası olarak kopyalamak istersek aşağıdaki komutu kullanabiliriz.

```
Demo $ docker cp 12345678:/x/y/z.txt /a/b/c.txt 
```

Demo Ortamının Yaratılması adımında zaten programı çalıştırmıştık. Şimdi başka bir terminal açarak yine `Question-4/Demo` klasörüne geçin. Yapmak istediğimiz şey `demo_program_1` adlı Container içinde bulunan `/opt/my-app/data/random-4K.bin` dosyasını Host üzerindeki `/tmp/random-4K.bin` dosyası olarak kopyalamak olsun. Bu durumda aşağıdaki iki yöntemden birini kullanabiliriz.

1.

```
Demo $ docker cp demo_program_1:/opt/my-app/data/random-4K.bin /tmp/random-4K.bin
```

2.

```
Demo $ docker ps -a
CONTAINER ID        IMAGE               COMMAND                CREATED             STATUS                      PORTS               NAMES
3659d8a028b1        ubuntu:16.04        "/usr/app/runner.sh"   1 minutes ago      Exited (0) 1 minutes ago                       demo_program_1
Demo $ docker cp 3659d8a028b1:/opt/my-app/data/random-4K.bin /tmp/random-4K.bin
Demo $ ls -lrt /tmp/random-4K.bin
-rw-r--r-- 1 vagrant vagrant 4096 Feb 24 21:31 /tmp/random-4K.bin
```

### Kapanış

Bu blog'daki yer verilen bilgiler devam eden blog'larda yapılacak çalışmalara yardımcı olacaktır. Bir sonraki blog'da buluşmak üzere.

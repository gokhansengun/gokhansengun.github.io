---
layout: post
title: "Docker İpuçları - Soru / Cevap - Bölüm 2"
level: Orta
published: true
lang: tr
ref: docker-tips-question-and-answer-part-2
---

Docker Container'ların yaşam döngüleri çok iyi bir biçimde tanımlanmıştır. Docker Daemon, Docker Image'ından bir Container oluşturarak Image içinde tanımlanan uygulamaya (Command) kontrolü bıraktıktan sonra uygulama, kendi isteği ile çıkış yapana kadar çalıştırılmaya devam eder. Container'ın çalışmasına müdahale gerektiğinde, Docker CLI yardımı ile Docker Daemon'a gönderilen komutlar, Container'ın çalışması duraklatabilir (Pause), durdurabilir (Stop) veya yeniden başlatabilir (Restart).

Dockerfile'ını kendi hazırladığınız Container'ları, Docker CLI veya Docker Compose CLI ile durdurmaya çalıştığınızda Container'ın hemen durdurulamadığını fakat 10 saniye sonra ancak durdurulabildiğini bugüne kadar gözlemlemiş olabilirsiniz. Henüz bu duruma rastlamadıysanız, Docker ile gelişen maceralarınızda karşılaşacağınızı garanti edebilirim. Bu blog'da bu davranışın neden sadece bazı Container'larda oluştuğuna ve bu davranışı nasıl değiştirebileceğimizi göreceğiz.

### Soru 1

Docker Hub'dan indirdiğiniz Nginx Docker Image'ının içine Dockerfile yardımı ile kendi sitenizdeki dosyaları kopyaladınız ve web sunucuyu başarılı bir şekilde ayağa kaldırdınız. Sitenizdeki yük fazla olduğu için birden fazla Nginx Container ayağa kaldırıyorsunuz ve bu Container'ları bir Load Balancer (Yük Dağıtıcı) arkasına koyarak gelen yükü eşit olarak dağıtıyorsunuz.

Operasyon takımı olarak, ara ara web sunucularda çıkan problemlerin hangi Container'dan kaynaklandığını öğrenmek ve hızlıca bu Container'ları tespit edebilmek üzere web sunucunun IP adresini görebilmek için `ip-addr.html` adlı bir dosya eklemek istediğinizi varsayalım. 

Not: Buradaki senaryonun gerçekten işe yarayabilmesi için Load Balancer'da [Sticky Session](http://wiki.metawerx.net/wiki/StickySessions) kullanıldığı varsayılmıştır.

#### Problemin Gösterimi

Öncelikle tasvir ettiğimiz bu problemi bir örnek ile gösterelim ve kendimiz test edelim.

##### Demo Ortamının Yaratılması

Bu bölümde problemin gösterimini yapacağımız örnek için gerekli ortamı yaratalım. Önlerinde bir Load Balancer (HAProxy) olan üç adet Nginx web sunucuyu HAProxy ile birlikte Docker Compose yardımıyla ayağa kaldıralım ve çalıştığını test edelim.

Belirtilen adımları siz de takip etmek istiyorsanız bu blog için hazırladığım [Github Repository](https://github.com/gokhansengun/Docker-Tips-with-QA)'sini klonlayıp komut satırında repo içindeki `Question-2/NoProblem/Demo` klasörüne geçin. Yolumuz düşerse ve beğendiysek Github'da Star vermeyi ihmal etmeyelim :-)

Bu klasörde içeriği aşağıda verilen, `web`, `curl` ve `lb` adlı üç servis içeren Docker Compose dosyasının yanında, 

- Nginx Image'ını özelleştirdiğimiz `Dockerfile-Nginx` dosyası
- HAProxy'nin konfigürasyonunu belirlediğimiz `haproxy.cfg` dosyası
- Nginx'te sunacağımız basit web sitesini içeren `site` klasörü
- Docker Compose komutlarını bir araya toplayarak işimizi kolaylaştıracak `Makefile` dosyası 

ile karşılaşacaksınız.

```yaml
version: "2"

services:
  web:
    build:
      context: .
      dockerfile: ./Dockerfile-Nginx
    
  curl:
    image: byrnedo/alpine-curl

  lb:
    image: haproxy:1.7.1
    volumes:
      - "./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg"
    ports:
      - "8080:8080"

```

Komut satırında `make up` komutunu vererek servisleri çalıştırın. Komut satırında işlemler tamamlandıktan sonra `make ps` komutunu vererek servislerin çalışıp çalışmadığını kontrol edebilirsiniz. Aşağıdakine benzer bir görüntü oluşmalı.

Gördüğünüz gibi HAProxy (`demo_lb_1` isimli Container'a sahip olan `lb` servisi) 8080 numaralı portta istekleri bekliyor.

```
Demo $ make ps
docker-compose ps
   Name                 Command               State           Ports
----------------------------------------------------------------------------
demo_lb_1    /docker-entrypoint.sh hapr ...   Up      0.0.0.0:8080->8080/tcp
demo_web_1   nginx -g daemon off;             Up      443/tcp, 80/tcp
demo_web_2   nginx -g daemon off;             Up      443/tcp, 80/tcp
demo_web_3   nginx -g daemon off;             Up      443/tcp, 80/tcp
```

Tarayıcınızın adres çubuğuna `http://localhost:8080` adresini girerek aşağıdaki gibi bir çıktı elde etmelisiniz.

{% include image.html url="/resource/img/DockerQAPart2/company_page_browser.png" description="Company Page in Browser" %}

Eğer bu testi (Load Balancer'ın sayfaları verip vermediği testini) komut satırından yapmak isterseniz `docker-compose.yml` dosyasında gördüğünüz `curl` servisini aşağıdaki gibi çağırabilirsiniz.

```bash
Demo $ docker-compose run --rm curl http://lb:8080
<html>
    <head>
        <title>Company Site</title>
    </head>
    <body>
        <h1 style="text-align: center; color: red">Welcome to Company Page</h1>
        <h2 style="text-align: center; color: blue">You will find useful info here</h2>
    </body>
</html>
``` 

##### Problemi Göstermeden Bir Öncesi: Problem Olmayan Durum

Problemi görmek için biraz daha beklememiz gerekecek :-) Öncelikle henüz bozmamışken doğru davranışın ne olduğunu görelim.

Docker Compose ile başlattığımız servisleri durdurmak istediğimizi farz edelim. `Makefile`'ımızda bunun için `make clean` komutunu kullanabiliriz. Komut satırından `time make clean` komutunu verdiğinizde işlemin 2.2 saniyede bittiğini gözlemleyebilirsiniz. Gördüğünüz gibi öncelikle servislerin içindeki Container'lar Stop edilmeye çalışılıyor ve sonrasında da Remove ediliyor.

Not: `make clean` komutunun başına `time` komutunu vermek `make clean` komutunun tamamlanma süresi ile ilgili bilgi almamızı sağladı.

```bash
Demo $ time make clean
docker-compose down -v
Stopping demo_lb_1 ... done
Stopping demo_web_3 ... done
Stopping demo_web_2 ... done
Stopping demo_web_1 ... done
Removing demo_lb_1 ... done
Removing demo_web_3 ... done
Removing demo_web_2 ... done
Removing demo_web_1 ... done
Removing network demo_default

real	0m2.201s
user	0m0.239s
sys	0m0.051s
``` 

##### Ve Nihayet Problemin Gösterimi

Buraya kadar hiçbir problem yoktu her şey istediğimiz şekilde ilerledi. Şimdi ise Nginx web sunuculara, sunucunun IP'sini gösterecek olan `ip-addr.html` sayfayı eklemeye çalışalım.

Adımları kendiniz de takip ediyorsanız komut satırında repo içindeki `Question-2/Problem/Demo` klasörüne geçin. Nginx Container'ın IP adresini Container ayağa kalkmadan öğrenemeyeceğimiz için web sunucunun altına koyacağımız `ip-addr.html` dosyasını `Dockerfile`'da üretemeyiz. Aynı şekilde bu dosyayı Docker Container'ları koşturan Host'tan da Volume direktifi ile Mount edemeyiz. Yapmamız gereken şey Nginx Image'ının Command'ını bir Bash Script ile değiştirmek ve Bash Script'in içerisinde Nginx'i başlatmadan `ip-addr.html` dosyasını IP bilgisini alarak oluşturup sonra Nginx'i başlatmaktır. Aşağıdaki Bash Script'i bu işi yapmak üzere kullanılabilir.

Not: IP adresini bulmak için komut satırına Google'ın DNS sunucusuna erişmek için hangi Route'u kullanacağını soruyoruz ve buradan kendi IP adresimizi çekiyoruz.

```bash
#!/bin/bash -u

ip_addr=`ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n'`;

echo "<center><h2>Serving Web from IP address: ${ip_addr}</h2></center>" > /usr/share/nginx/html/ip-addr.html

nginx -g 'daemon off;'
```

`Question-2/Problem/Demo` klasöründe `make up` komutunu verin ve servislerin ayağa kalkmasını bekleyin. Sonra IP adresinin doğru gelip gelmediğini test etmek için tarayıcınızın adres çubuğuna `http://localhost:8080/ip-addr.html` adresini girerek aşağıdaki gibi bir çıktı elde etmelisiniz. Sayfayı birkaç kez yenileyerek IP adresinin değiştiğini görebilirsiniz.

{% include image.html url="/resource/img/DockerQAPart2/nginx_ip_addr_browser.png" description="Nginx IP Address" %} 

Sonunda geldik problemin gösterimine :-) Servisleri durdurmak için `time make clean` komutunu verin, aşağıdaki gibi bir çıktı elde etmeniz gerekir.

Bir önceki denemenin aksine bu kez servislerin durdurulma işleminin tamamlanması 2.2 saniye yerine 12 saniye sürdü. Şimdi aradaki 10 saniyelik farkın nereden kaynaklandığını anlamaya çalışalım.
 
```bash
Demo $ time make clean
docker-compose down -v
Stopping demo_lb_1 ... done
Stopping demo_web_2 ... done
Stopping demo_web_3 ... done
Stopping demo_web_1 ... done
Removing demo_lb_1 ... done
Removing demo_web_2 ... done
Removing demo_web_3 ... done
Removing demo_web_1 ... done
Removing network demo_default

real	0m12.027s
user	0m0.286s
sys	0m0.067s
``` 

Problemin gösteriminin ikinci şekli muhtemelen daha çok karşılaşılan şeklidir. Docker CLI veya Docker Compose CLI ile bir Container'ı terminaline Attach olarak başlattıktan sonra `Ctrl+C` ile durdurmak istediğimizde bazen Container'ın hemen durmadığını ve 10 saniyelik bir gecikme ile durduğunu fark ederiz. Şimdi bunu örnekleyelim. `Question-2/Problem/Demo` klasöründe iken sadece `web` servisinden bir Container'ı Docker Compose ile başlatın ve sonra `Ctrl+C` ile durdurmaya çalışın, davranışı gözlemleyebilmelisiniz.

```bash
Demo $ docker-compose up web
Creating network "demo_default" with the default driver
Building web
Step 1/2 : FROM nginx:1.10
 ---> 5acd1b9bc321
Step 2/2 : COPY ./site /usr/share/nginx/html/
 ---> 4fc3746cd5b4
Removing intermediate container 94e4397ad538
Successfully built 4fc3746cd5b4
WARNING: Image for service web was built because it did not already exist. To rebuild this image you must use `docker-compose build` or `docker-compose up --build`.
Creating demo_web_1
Attaching to demo_web_1
^CGracefully stopping... (press Ctrl+C again to force)
Stopping demo_web_1 ... done
```

Bir sonraki test için servisleri temizlemek için `make clean` komutunu verin.

##### Problemin Kök Sebebi

Yaptıklarımızı kısaca özetlemek gerekirse, Docker Image'ının Command'ını değiştirdik ve `nginx` programını bir script `init-wrapper.sh` içinden çalıştırdık. Bu değişiklik bize çalıştırdığımız Docker Container'ı durdurmaya çalışırken 10 saniyelik bir gecikme olarak yansıdı.

Problemin neden kaynaklandığını anlamak için `Question-2/NoProblem/Demo` klasörüne (evet problem olmayan demo'nun olduğu klasöre) geçin. `make up` komutunu vererek servisleri ayağa kaldırın. `docker-compose exec web /bin/bash` komutunu vererek Nginx Container'larının birinin içine bağlanın. Container'ın içinde ise `ps auxww` komutunu verin, aşağıdakine benzer bir çıktı elde etmeniz gerekir.

```bash
Demo $ docker-compose exec web /bin/bash
root@93edb2b11c22:/# ps auxww
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.1  0.2  31684  5104 ?        Ss   21:32   0:00 nginx: master process nginx -g daemon off;
nginx        5  0.0  0.1  32068  2924 ?        S    21:32   0:00 nginx: worker process
root         6  0.3  0.1  20244  3084 ?        Ss   21:32   0:00 /bin/bash
root        11  0.0  0.1  17500  2152 ?        R+   21:33   0:00 ps auxww
```

Yukarıdaki çıktıdan görebileceğiniz gibi `nginx -g 'daemon off;'`, `PID` 1 ile çalıştırılmış. Bu bilgiyi not ederek bir de problemli durumdaki aynı çıktıya bakalım. `make clean` komutunu vererek bu kez `Question-2/Problem/Demo` klasörüne geçin. Bu klasörde önce `make up`, sonra `docker-compose exec web /bin/bash` ve en sonra da `ps auxww` komutunu verin.

```bash
Demo $ docker-compose exec web /bin/bash
root@bbdf34004077:/# ps auxww
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1  20048  2756 ?        Ss   21:36   0:00 /bin/bash -u /script/init-wrapper.sh
root         9  0.0  0.2  31684  5068 ?        S    21:36   0:00 nginx: master process nginx -g daemon off;
nginx       10  0.0  0.1  32068  3032 ?        S    21:36   0:00 nginx: worker process
root        11  0.5  0.1  20244  2988 ?        Ss   21:37   0:00 /bin/bash
root        15  0.0  0.1  17500  2056 ?        R+   21:37   0:00 ps auxww
```

Yukarıdaki çıktıda bu kez `nginx -g 'daemon off;'`'un `PID` 9 ile çalıştırıldığını. `PID` 1'in ise Docker Image'ına verdiğimiz yeni Command yani `/bin/bash -u /script/init-wrapper.sh` olduğunu görüyoruz.

Bu iki testten yapmamız gereken ilk çıkarım, Docker'ın Image Command'lerini `PID` 1 (yani `init` Process) olarak başlatmasıdır.

Docker CLI'dan bir Docker Container için `stop` komutu verildiğinde Docker Engine, ilgili Container'ın `init` Process'ine `SIGTERM` sinyali göndermekte 10 saniye (ayarlanabilir bir değer) beklemekte ve sonrasında eğer Container kendi isteği ile çıkış yapmazsa yine `init` Process'ine bu kez `SIGKILL` sinyalini göndermekte ve Container'ı sonlandırmaktadır. Docker Daemon, `init` Process'e `SIGTERM` gönderdikten sonra 10 saniye bekleyerek Container'ın (varsa) hali hazırda yaptığı bir işi sonlandırmasını beklemektedir. Bu davranış geleneksel Linux/Unix sistem mimarisi ile uyumlu bir davranıştır. Linux/Unix'te bir Process veya tüm sistem kapatılmak istendiğinde Process'lere `SIGTERM` sinyali gönderilir ve 5-10 saniye boyunca kendilerinin çıkış yapması beklenir, Process'ler çıkış yapmazsa `SIGKILL` veya sistem kapatılması suretiyle sonlandırılırlar.

Nginx'i bir Bash Script ile başlattığımızda `SIGTERM` sinyali, `init` Process'i olan `bash` Process'ine gönderilmekte ve sinyal Nginx'e aktarılmadığı için Nginx çalışmaya devam etmektedir.

Bir sonraki test için servisleri temizlemek için `make clean` komutunu verin.

### Cevap 2

Soruyu, ziyade detayı ile ortaya koyduktan sonra şimdi iki cevap alternatifi ile birlikte konuşabiliriz.

#### Alternatif 1 

En az zahmetle ve yukarıda verilen problemi en doğru şekilde çözmemize olanak tanıyacak yöntem, `bash` Process'i yerine `nginx` Process'ini `PID` 1 yani `init` Process'i yapmaktır. `init-wrapper.sh` dosyasında `nginx`'in başlatılma şeklini aşağıdaki gibi değiştirirsek yani başına `exec` komutunu eklersek `nginx -g 'daemon off;'`, `PID` 1 olarak çalıştırılacak ve Container doğru bir şekilde Stop edilebilecektir. `exec` komutu Linux/Unix işletim sistemlerinde o anda koşturulmakta olan Process'in Image'ını kendisine parametre olarak verilen programın Image'ı ile değiştirir. Dolayısıyla bizim durumumuzda, Docker Daemon'ın `init` Process olarak başlattığı `/bin/bash -u /script/init-wrapper.sh` Process'i `nginx -g 'daemon off;'` tarafından ezilecek ve yeni `init` Process olacaktır.

```bash
exec nginx -g 'daemon off;'
```

Öncelikle çözümü test etmek için `make up` komutunu vererek servisleri ayağa kaldırın. Servisleri durdurmak için `time make clean` komutunu verin. Gördüğümüz gibi servislerin durdurulması toplam 2.3 saniye sürdü yani gerçekten de problem çözüldü.

```bash
Demo $ time make clean
docker-compose down -v
Stopping demo_lb_1 ... done
Stopping demo_web_3 ... done
Stopping demo_web_2 ... done
Stopping demo_web_1 ... done
Removing demo_lb_1 ... done
Removing demo_web_3 ... done
Removing demo_web_2 ... done
Removing demo_web_1 ... done
Removing network demo_default

real	0m2.308s
user	0m0.238s
sys	0m0.058s
```

#### Alternatif 1'in Artıları ve Eksileri

Bu alternatifin ilk artısı gördüğünüz gibi çok kolay adapte edilebilmesi ve problemimizi herhangi bir eksiklik bırakmadan tam anlamı ile çözmesidir.

Bizim örneklediğimiz durumda bu alternatifin kullanılabilmesine olanak tanıyan şey, `init-wrapper.sh` Script'inin bazı hazırlıklar yapıp kontrolü `nginx` Process'ine devredilmesidir. Eğer `nginx` Process'i başlatıldıktan sonra Script içinde başka bazı işlemler yapmamız gerekseydi bu yöntemi kullanamayacaktık çünkü `init-wrapper.sh` Script'imiz `exec nginx -g 'daemon off;'` çağrıldığı noktadan sonraki kısımları işletemeyecektir (Replace edildiği için).

Bu durumda aynı Docker Container içerisinde iki adet Process başlatmamız gerekirse bu yöntemi kullanamayacağımız açıktır.

#### Alternatif 2

İkinci alternatif tahmin edebildiğiniz gibi Bash Process'inin kendisine gelen sinyalleri başlattığı Child (çocuk) Process'lere iletmesidir. Bu durumda yapmamız gereken `init-wrapper.sh` Script'inde, başlatılan Child Process'lerin ID'lerini saklamak ve `SIGTERM` sinyallerini dinleyerek `SIGTERM` sinyali geldiğinde bu Process'lere iletmektir. Aşağıda güncellenen `init-wrapper.sh` Script'i tam olarak bunu yapmaktadır.

```bash
#!/bin/bash -u

child_pid=

# handler for SIGTERM
term_handler() {
  echo "SIGTERM signal is caught!";
  kill -TERM "$child_pid" 2>/dev/null;
}

trap term_handler SIGTERM;

ip_addr=`ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n'`;

echo "<center><h2>Serving Web from IP address: ${ip_addr}</h2></center>" > /usr/share/nginx/html/ip-addr.html;

# start the process
nginx -g 'daemon off;' &

# save the child process id
child_pid=$! 

# wait for it until exit
wait "$child_pid"
```

Çözümü test etmek için `make up` komutunu vererek servisleri ayağa kaldırın. Servisleri durdurmak için `time make clean` komutunu verin. Gördüğümüz gibi servislerin durdurulması yine toplam 2.3 saniye sürdü yani yine gerçekten de problem çözüldü.

```bash
Demo $ time make clean
docker-compose down -v
Stopping demo_lb_1 ... done
Stopping demo_web_3 ... done
Stopping demo_web_2 ... done
Stopping demo_web_1 ... done
Removing demo_lb_1 ... done
Removing demo_web_3 ... done
Removing demo_web_2 ... done
Removing demo_web_1 ... done
Removing network demo_default

real	0m2.324s
user	0m0.231s
sys	0m0.055s
```

#### Alternatif 2'nin Artıları ve Eksileri

Alternatif 2, alternatif 1'de belirtilen sadece tek Process başlatabilme kısıtına sahip değildir. Bir Docker Container içerisinde birden fazla Process başlatılabilir ve bu Process'ler istendiğinde durdurulabilir.

Yukarıda verilen artısının yanında bu yöntem bir öncekine göre biraz daha kompleks'tir.

### Kapanış

Bu blog'daki yer verilen problemin çözümünü tamamıyla anlamak için bir miktar Linux ve Bash bilgisi gerekse de verilen çözümler, yeterli Linux ve Bash bilgisi olmadan da rahatlıkla uygulanabilir. Bir sonraki blog'da buluşmak üzere.

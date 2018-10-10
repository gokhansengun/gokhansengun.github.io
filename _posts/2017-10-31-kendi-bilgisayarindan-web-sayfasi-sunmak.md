---
layout: post
title: "Kendi Bilgisayarından Web Sayfası Sunmak"
level: Başlangıç
published: true
lang: tr
ref: hosting-web-sites-from-your-own-computer
blog: yes
---

Evde kullandığımız bilgisayardan internete açık bir şekilde bir servisin (örneğin web sunucu) nasıl yayınlanabileceği konusu üzerine uzun süredir yazmak istiyordum. Bu konu ile ilgili bir mail grubunda soru gelince "fırsat bu fırsat" diyerek bu blog yazısına başladım. Sunucuların özel veri merkezlerinden bile çıkarılıp, konsolide edilmiş paylaşılan veri merkezlerine (public cloud - AWS, Azure, Google Cloud, DigitalOcean, vb) taşındığı, A'dan Z'ye bütün hizmetlerin (web sayfası sunma, veri tabanı, in-memory cache) cloud'da maliyet etkin bir biçimde sağlandığı bu devirde evden servis sağlamak da nereden çıktı dediğinizi duyar gibiyim :-)

### Motivasyon

Bu blog yazısını yazmak istememin temel sebebi modem arkasından bir servisi internete açarken yapılması gereken ayarların ve problem çözme adımlarının birçok konseptin tanıtılması ve anlaşılmasına olanak tanımasıdır. Buna ek olarak aşağıdaki kullanım senaryolarında bu işlemi gerçekten yapmaya ihtiyaç duyabiliriz.

1. Bilgisayarınızda geliştirdiğiniz ve henüz dışarıdan erişilebilir bir sunucuya deploy etmediğiniz bir web uygulamasını müşterinize veya iş arkadaşlarınıza göstermek istediğinizde
2. Evinize kurduğunuz bir akıllı ev sistemi ya da güvenlik kamera sistemine internet üzerinden erişmek istediğinizde
3. Evinizdeki bilgisayarınızı iş yerinden veya yakınlarınızın bilgisayarını, TeamViewer vb programlar olmadan direkt erişim ile yönetmek istediğinizde

### Ön Koşullar

Bu blog'da macOS yüklü bir bilgisayarda basit bir web sunucu çalıştırılacak ve internete açılacaktır. Windows ve Linux yüklü bilgisayarlarda işletim sistemi bazlı olarak bazı değişiklikler yapmak gerekecektir. İlerleyen zamanlarda bu yazıya macOS'e ek olarak, Windows ve Linux işletim sistemlerinde yapılması gereken ayarlar ile ilgili eklemeler yapılacaktır.

### Hazırlık

Öncelikle internete açılacak bir test web sunucusunun kurulumunu bilgisayarımıza yapalım. Test web sunucusu olarak NPM paketi olarak dağıtılan basit [`http-server`](https://www.npmjs.com/package/http-server) uygulamasını kullanabiliriz.

Uygulamayı global olarak kullanabilmek için komut satırından `npm install -g http-server` komutunu verebilirsiniz. `http-server` uygulaması çalıştırıldığı klasör içindeki dosyaları sunmaktadır. Bu klasörde aşağıdaki komutu vererek birkaç `html` dosyası oluşturalım.

```bash
for i in {1..5}; do echo "Hello World $i" > $i.html; done
```

Komut satırında `http-server -p 8080` komutunu vererek web sunucunun bilgisayarınızın `8080` portundan yayın yapmasını sağlayabilirsiniz. Aşağıdaki gibi bir görüntü elde etmelisiniz.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/run_http_server.png" %}

Çıktıdan görüldüğü üzere web sunucu `8080` numaralı portu benim bilgisayarımın sahip olduğu bütün IP'lerden dinlemeye başlamıştır. Genel olarak işletim sistemleri sanal veya fiziksel her bir ağ kartı için birer IP adresi tanımlarlar. Buna ek olarak aynı bilgisayardaki uygulamaların network'e çıkmadan işletim sistemi üzerinden direkt haberleşebilmeleri için `localhost` ya da `loopback` adı verilen `127.0.0.1` IP'li sanal bir arayüz tanımlarlar.

Şimdi `curl` aracı ile gösterilen bütün IP'lerden web sunucuya erişebileceğimizi farklı dosyalar isteyerek kontrol edelim.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/curl_to_all_ips.png" %}

Örneğimizde web sunucu her ne kadar bütün IP'leri dinliyor olsa da bazı durumlarda sadece belirli arayüzlerden belirli IP'leri dinlemek isteyebiliriz. Örneğin, şu anda yapmak istediğimizin tam aksi durumda, yani web sunucumuza dış dünyadan erişilmesini istemediğimizde web sunucuyu sadece `localhost` yani `127.0.0.1` IP'sini dinlemek üzere kurgulayabiliriz.

`http-server`'in `-a` parametresine `127.0.0.1` geçerek sadece `localhost` arayüzünü dinlemesini sağlayabiliriz. `http-server`'ı sadece `localhost`'u dinleyecek şekilde çalıştırıp, `curl` ile az önce yaptığımız testi tekrarladığımızda, aşağıdaki çıktıda gösterildiği gibi `192.168.1.36` ve `172.16.44.1` IP'li adreslere yapılan isteklerin cevaplanmadığını görebiliriz.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/curl_to_all_ips_fail_except_localhost.png" %}

`http-server`'ı `Ctrl+C` ile durdurup bütün IP'leri dinleyecek şekilde yani `-a` parametresini kaldırarak tekrar çalıştıralım.

Son hazırlık adımı olarak internet üzerinden sunucuya erişmek üzere ISP'nin (Internet Service Provider - internet servis sağlayıcı) bize verdiği IP adresini bulalım. IP adresimizi Google'a `what is my ip` yazarak görebileceğimiz gibi aşağıdaki komutu kullanarak da görebiliriz.

```
$ dig +short myip.opendns.com @resolver1.opendns.com.
88.253.21.56
```

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/what_is_my_ip.png" %}

Tam bu noktada kazara internetten servisinize ulaşıp ulaşamadığınızı test etmek için `curl http://88.253.21.56:8080` yani `curl http://<public_ip_adresi>:8080` komutunu verebilirsiniz. Benim durumunda internet üzerinden sunucuya bağlantı sağlanamadı. 

### Güçlü ve Doğru Alternatif

Aşağıda detaylandıracağımız adımlarla hiç uğraşmadan bilgisayarınızda çalıştırdığınız servisleri [`ngrok`](https://ngrok.com/) ile güvenli bir şekilde internete açabilirsiniz. `ngrok` bilgisayarımızla internet arasında güvenli bir tünel oluşturarak internet üzerinden gelen istekleri bilgisayarımıza ulaştırır ve aldığı cevabı istemciye iletir.

`8080` portundan çalıştırdığımız web sunucumuzu internete açmak için `ngrok http 8080` komutunu kullanabiliriz. Aşağıdaki çıktıda görüldüğü gibi, `ngrok` `8080` portunu `http://a44c3a39.ngrok.io` ve `https://a44c3a39.ngrok.io` adresleri üzerinden internete açmaktadır. Tabii bu adresler sizin çalıştırmanız sırasında değişecektir.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/ngrok_http.png" %}

`http://a44c3a39.ngrok.io` ve `https://a44c3a39.ngrok.io` adreslerine `curl` ile Http isteklerinde bulunarak servisin çalıştığını doğrulayabilirsiniz. Dikkat ettiyseniz `ngrok` bizim `http` yani güvenlik eklenmemiş servisimizi `https` olarak internete açma opsiyonu sunmaktadır. Bu bakımdan aşağıda anlatılan yönteme göre daha güvenlidir (servisimizi kullanıcıları ile aramıza bir üçüncü partinin girememesi konusunda).

### Topoloji

İlerleyen aşamalarda çıkması muhtemel problemleri çözmek için evimizden internete ulaşmamızı sağlayan cihazlar, cihazların rolleri ve ağ topolojisine kısmen hakim olmamız gerekir. Şimdi bu kısımları biraz irdeleyelim.

Genel olarak evlerimizden internete bir ADSL, VDSL, kablo vb modem vasıtasıyla bağlanırız. Bu modemin temel görevi paketleri telefon kablosu üzerinden iletilmek üzere modüle/demodüle etmektir. Zaten `MoDem` kelimesi de `modulation` ve `demodulation` kelimelerinden oluşmaktadır. Modern modemlerin bir çoğunda kablosuz olarak internete bağlanmamızı sağlayan bir kablosuz alıcı bulunmaktadır. Yine modeme entegre olarak bir adet de Router bulunmaktadır. Genel olarak Router'lar WAN portundan ISP ağına bağlanarak ISP'den internete çıkabilecekleri bir IP adresi alırlar. 

Evimizin içerisinde bir public IP adresi üzerinden birden fazla cihazı (cep telefonlarımız, bilgisayarlarımız, vb) ağa bağlamak isteriz. Modem içinde bulunan Router'lar birden fazla cihaza internet sağlayabilmek için bağlı bulunan cihazlarla kendi arasında yeni bir ağ oluşturur. Bu ağdaki cihazlar genellikle 192.168.1.x'li IP'ler alırlar, Router'a ise DHCP'den 192.168.1.1 IP'sini atanır, bu nedenle modem arayüzüne girmek için genellikle 192.168.1.1 IP'sini kullanırız. İşte modem, içerisinde bulunan Router ile ISP'de dahil olduğu dış ağ ve evimizdeki cihazlarla birlikte dahil olduğu ev ağı arasında geçişi sağlar. Zaten Router'ların asıl görevi iki farklı ağ arasında paket geçişini sağlamaktır.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/topology.png" %}

Router'ın evdeki cihazlarla kurduğu küçük ağ'dan üzerinden cihazları internete çıkarabilmesini sağlayan özellik NAT'tır (Network Address Translation). Yukarıdaki şekilde görüldüğü gibi Router üzerinde bulunan NAT modulü dış dünya ile ev ağımız arasındaki cihazların konuşmasını sağlar. Normalde ev ağına bağlı cihazlardan internetteki servislere (haber siteleri, WhatsApp, Facebook, vb) erişiriz. Bu senaryoda istek bizim tarafımızdan başlatıldığı için akıllı Router'lar güvenli ortamdan (ev ağından) çıkan isteklere verilen cevaplar için gerekli anahtarlamayı yapar. Ancak ev ağı içerisinde sunduğumuz servisler için elimizde tek bir public IP ve birden çok cihaz bulunduğu için Router'a gelen isteklerin hangi cihaza yönlendirilmesi gerektiğini söylememiz gerekir. İşte bu noktada `Port Forwarding` devreye girer. `NAT arkası - Behind the NAT` terimi de tam buradan çıkmıştır.

Ev ağındaki bütün cihazlar `NAT arkasındaki cihazlar` olarak adlandırılır. Public IP'nin X portuna gelen isteklerin iç ağdaki Y IP'sinin (örneğin 192.168.1.36) portuna yönlendirilmesi işlemi `Port Forwarding`'dir. Bu işlem genellikle model arayüzü üzerinden yapılır.

### Adımlar

Şimdi tekrar bilgisayarımızdaki web sunucuyu dışarı açma işlemlerine devam edelim.

#### Bilgisayarın Ev Ağı IP'sini Bulma

Hazırlık adımında `http-server`'ı çalıştırdığınızda listelenen IP'lerden birisi sizin bilgisayarınızın IP adresidir. Windows'ta `ipconfig`, Linux ve macOS'te ise `ifconfig` komutları ile bilgisayarınızın iç ağ adresini bulabilirsiniz. Bilgisayarımızın iç ağ adresini modem'de port yönlendirme yaparken kullanacağız. 

#### Port Yönlendirme

Port yönlendirme ile dış IP'den `8080` portu üzerinden modeme iletilen bütün isteklerin iç network'te bilgisayarımıza gönderilmesini sağlayacağız. Modeminizin arayüzünü açarak `Port Forwarding - Port Yönlendirme` sayfasından aşağıdakine benzer şekilde yeni bir kural ekleyin. Burada seçeceğiniz `WAN interface` çok önemlidir. WAN arayüzünün ISP'nin sizi internete çıkardığı arayüz olmasına dikkat edin. Hangi arayüz üzerinden çıktığınız ile ilgili bir fikriniz yoksa deneme yanılma yolu ile doğru WAN arayüzünü bulabilirsiniz.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/forward_port.png" %}

Kuralı ekledikten sonra tekrar `curl http://<public_ip_adresi>:8080/1.html` komutunu vermeyi deneyin. Benim durumumda aşağıdaki gibi web sunucumu bu adımla internet'e açmış oldum. Bunun sebebi daha önceden bilgisayarımda Firewall'u (güvenlik duvarı) kapalı hale getirmemdi.  

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/curl_to_internet.png" %}

Bilgisayarımda Firewall'u açık hale getirip tekrar deneyince aşağıdaki gibi bir çıktı alarak web sunucuya internet üzerinden erişimim tekrar kesildi.

```
$ curl 88.253.21.56:8080/2.html
curl: (7) Failed to connect to 88.253.21.56 port 8080: Operation timed out
```

#### Bilgisayar Üzerinde Firewall Ayarı (macOS)

`Security & Privacy` bölümünden `Firewall` sekmesini seçerek `Firewall Options`'ı tıklayın. Açılan aşağıdaki ekrandan görebileceğiniz üzere macOS bize büyük kolaylık sağlayarak `node` uygulamasının (`http-server`'ı çalıştıran runtime) anlık olarak bazı portları dinlediğini ve gelen isteklerin halihazırda bloklandığını bildirmektedir. İlgili satırın üzerine tıklayarak `node`'un internetten gelen istekleri kabul etmesini sağlayabiliriz.

{% include centeredImageCaption.html url="/resource/img/HostingFromComputer/block_incoming_conns_mac_firewall.png" %}

İlgili değişikliği yaptıktan sonra `curl http://<public_ip_adresi>:8080/1.html` komutunu tekrar web sunucuya internet üzerinden ulaşabilecektir.

### Problem Çözme

1. Sizin durumunuzda, çalıştırdığınız servis örnek olarak kullandığımız `http-server` gibi ilgili portun hangi IP'ler tarafından dinlendiğini söylemeyebilir. Bu durumda `127.0.0.1` ve bilgisayarımızın modemden aldığı `192.168` ile başlayan IP'lere `curl` ile istekler göndererek portun gerçekten dinlenip dinlenmediğine emin olmanız gerekir.

2. Yine ilgili servisin doğru IP'ler tarafından dinlenip dinlenmediğini anlamak için `netstat` programını kullanabiliriz. macOS işletim sistemi için `netstat -ap tcp | grep -i "listen"` komutu ile ilgili portun hangi IP'lerde dinlendiğini görebiliriz. Çıktıda görülen `*.8080` ve `0.0.0.0:8080` portun bütün IP'ler tarafından dinlendiğini belirtecektir.

3. Yukarıdaki bütün ayarları yapmanıza rağmen uzak bir ihtimal de olsa ISP'niz kendi ağında modeminizin önüne koyduğu bir network cihazı ile modeminize gelen istekleri bloklayabilir. Bu durumda ISP ile bağlantı kurulup istenen portlara izin vermesi talep edilebilir.

4. Router üzerinde yapılan port yönlendirme ayarı ile -varsa- Router üzerindeki Firewall'da ilgili portlara otomatik olarak izin verilmesi beklenir. Yine çok uzak bir ihtimal olmakla birlikte standart dışı bir modem bu basit kuralı görmezden gelerek yönlendirilen portları Firewall'da bloklayabilir. Bu durumda modem üzerinde manuel olarak ilgili porta gelen isteklerin bloklanmaması sağlanmalıdır.

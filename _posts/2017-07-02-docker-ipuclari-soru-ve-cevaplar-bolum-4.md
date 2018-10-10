---
layout: post
title: "Docker İpuçları - Soru / Cevap - Bölüm 4"
level: Orta
published: true
lang: tr
ref: docker-tips-question-and-answer-part-4
blog: yes
---

Serinin bu bölümünde Docker Inc'in Nisan 2017'deki konferansında duyurduğu ve büyük yankı uyandıran Multi-stage Build'ın ne anlama geldiğini öğrenecek ve bu özelliği kullanan bir örnek yapacağız. Tanıtılan özellik yakın zamanda eklendiği için bu blog'daki örneği takip edebilmek ve daha sonrasında kullanabilmek için Docker sürümünüzü en günceline 17.06.0-ce veya bir önceki sürüme 17.05.0-ce güncellemeniz gerekmektedir.

### Soru 5

Bütün Continuous Integration akışımı Docker ile yürütmek istiyorum ve CI sunucumda herhangi bir bağımlılığı bulundurmak istemiyorum. Jenkins veya benzeri bir CI aracının, kaynak kodları versiyon kontrol sistemimden çektikten sonra build işlemlerini Docker Image'ları ile yapmasını ve build çıktılarını bir Docker Image'ına koyarak paketlemesini istiyorum. Bunu gerçekleştirirken Dockercon 2017'de duyurulan Multi-stage Build özelliği nasıl bir fayda sağlıyor ve daha önce bu iş nasıl yapılıyordu?

### Cevap 5

Öncelikle [bir önceki blog'u](/docker-ipuclari-soru-ve-cevaplar-bolum-3/) bu blog'a hazırlık olsun diye yazmıştım ancak Dockercon'da duyurulan Multi-stage Build özelliği ile bu blog'daki cevap tamamiyle değişmiş oldu. Nisan 2017'de duyurulmasına rağmen bu özelliğin stable sürümler için Docker for Mac ve Docker for Windows için ulaşılabilir olması geçen haftayı buldu dolayısıyla bu blog da sarkmış oldu.

Önceki blog'larda sıklıkla üzerinde durduğumuz üzere Docker sürekli olarak verimliliği esas alıyor. Image'ların katmanlara bölünmesi, aynı katmana sahip olan Image'ların bu katmanları ortak kullanarak diskte daha az yer kaplamaları, vb dizaynlar verimlilik odağına sadece birkaç örnek. Durum böyleyken Build edilen dillerde geliştirilen uygulamaların Docker ile otomatik olarak paketlenmesi ya verimsiz ya da biraz zahmetli oluyordu.

Hemen bir örnekle konuyu açalım. Java uygulaması geliştirdiğimizi düşünelim. Geliştirdiğimiz Java uygulamasını Docker Image'ı içerisinde build edebilmek ve çıktı olarak JAR, WAR, EAR dosyasını alabilmek için -kullandığımız geliştirme araçlarına göre- içinde Gradle, Maven ve JDK (Java Development Kit) bulunan bir Docker Image'ına ihtiyacımız var. İçerisinde bu kadar araç bulunan bir Docker Image'ı da haliyle içerisinde sadece JRE (Java Runtime Environment) bulunduran bir Image'a göre daha büyük boyutlu ve verimsiz olacaktır. Dolayısıyla oluşturduğumuz JAR'ı build ettiğimiz Docker Image'ı içerisinde çalıştırmak pek makul olmamaktadır.

Bu noktada endüstride genel olarak benim de daha önce kullanmakta olduğum ve Builder Pattern adı verilen teknik kullanılmaktaydı. Bu pattern'e göre uygulamanın kaynak koddan build edildiği ve çalıştırıldığı Docker Image'ları farklı farklıydı. Yukarıdaki örnek için içerisinde Gradle, Maven ve JDK bulunan birinci Docker Image'ında JAR build edildikten sonra JAR Container'dan Host bilgisayara taşınıyor ([önceki blog'a göz atabilirsiniz)](/docker-ipuclari-soru-ve-cevaplar-bolum-3/), sonra da ilgili JAR içinde sadece JRE olan Docker Image'ına kopyalanarak üretim ortamında çalıştırılacak sonuç Image elde ediliyordu.

Builder Pattern'deki bu işlemler bütünü için Docker tarafından sağlanan bir araç olmadığı için bu işlemler ya Makefile'lar ile ya da Shell Script'leri ile halledilmeye çalışılıyordu. 

Yukarıda bahsedilen karmaşaya ek olarak Dockerfile'larla fazlaca haşır neşir olan kişilerin aşina olduğu bir problem daha var. Bu problem de Dockerfile'a her eklenen satırın Docker Image'ında yeni bir layer oluşturması ve ilgili satırın Container'ın çalışma zamanında kullanılmasa bile Image'da yer kaplamasıydı. Örneğin aşağıdaki JMeter Image'ında Apache sitesinden download edilen zip dosyası final Image'da Container tarafından hiç kullanılmayacak olsa dahi Image'ın boyutunu artırmaktaydı. 

```Dockerfile
ADD http://www-us.apache.org/dist/jmeter/binaries/apache-jmeter-3.1.zip \
        /apache-jmeter-3.1.zip
```

Ek olarak Dockerfile'larda aşağıdaki gibi çoklu, okunması zor satırlar görmekteydik. Bu satırların da sebebi işlemleri farklı farklı satırlarda yapıp Image'ın boyutunu şişirmemekti.

```Dockerfile
RUN unzip /apache-jmeter-3.1.zip && \
    rm /apache-jmeter-3.1.zip && \
    mv /apache-jmeter-3.1 /jmeter && \
    ln -s /jmeter/bin/jmeter /usr/local/bin/jm
```

Gördüğünüz gibi aslında herkesin uğraştığı ve hemen hemen herkesin aynı sonucu beklediği işlemler için dünyanın dört bir yanında aynı acılar çekiliyordu. Ürettiği Executable 2 MB olan Go ile yazılmış bir programı düşünelim, bu programın Build ve çalıştırma için iki farklı Docker Image'ı ile uğraşılmadan derlenip çalıştırılabilmesi için 86 MB'lık Golang SDK'sına katlanılmak zorunda kalınıyordu. İşte tam bu noktada Docker Inc sevenlerinin acısını dindirmeye karar verdi ve Multi-stage Build'i kullanıma sundu.

#### Peki Docker Inc, Multi-stage Build ile bu problemi nasıl çözmeyi seçti?

Tahmin edilebileceği gibi Docker Inc'in elinde bu problemi sistematik olarak çözmek için birçok yol vardı. Bana göre en güzel yolla çözdüler. Artık rahatlıkla anladığımız ve Builder Pattern'den de ciddi bir kopya aldığımız üzere mesele hazırlık aşaması ile fırınlama (Bake) aşamasında kullanılan Docker Image'ını ayırmaktan geçiyor. Docker Inc, kullanıcı alışkanlıklarını değiştirmemek üzere aynı Dockerfile'da birden fazla `FROM` takısı tanımlanmasına izin verdi. Aynı zamanda bu `FROM` takılarına kod adı verebilir olduk. 

- `FROM gsengun/my-fatty-builder AS build-env`
- `FROM gsengun/my-tiny-runtime AS runtime-env`.

Böylelikle iki `FROM` takısı arasında yaptığımız bütün işlemler ilk `FROM` takısı ile belirtilmiş Image'a dahil oldu, sonraki işlemlerse ikinci `FROM` takılı Image'a. İkinci olarak Dockerfile içindeki birden fazla Image'ın birbirinden dosya kopyalamasına izin verildi. Böylece sonuç Image'lar sadece ilgilerini çeken dosyaları şişman Image'lardan alabildiler. Bu durumda `COPY` komutunun sentaksına bir `--from` parametresi eklenmiş oldu.

- `COPY --from=build-env /build/artifacts /runtime/path`

Tahmin edebileceğiniz gibi son olarak eklenen `FROM` komutu ile verilen Image o Dockerfile build edilince oluşan Image oluyor. Neler döndüğünü daha iyi anlatmak için şimdi bir örnek yapalım.

#### Örnek:

[Önceki bir blog'da yer verdiğim](/blogun-teknik-altyapisi/) gibi bu blog'un altyapısında Jekyll statik site jeneratörü var. Özetle Ruby ile yazılmış Jekyll uygulaması benim [Markdown](https://en.wikipedia.org/wiki/Markdown) ile yazmış olduğum post'ları alarak Html, Css ve JS'e çeviriyor ve bu herhangi bir web sunucuda (Apache, Nginx, IIS) çalıştırılabilir hale geliyor.

Tekrar hatırlayacak olursak yazılımlarımızın sadece Container'lar kullanılarak CI aracı tarafından build edilmesi ve oluşan çıktının da çalıştırma ortamına konmasını hedeflemiştik. Bu örnekte Jekyll Docker Image'ını kullanarak Html, Css ve JS çıktısı üreteceğiz ve oluşan bu çıktıyı Nginx Image'ının içine koyarak servis edeceğiz.

Örneği kendiniz de takip etmek istiyorsanız benim blog sitemi Git ile [bu adresten](https://github.com/gokhansengun/gokhansengun.github.io.git) bir klasöre klonlayıp ana klasördeki `Dockerfile`'i kullanabilirsiniz.

Öncelikle Jekyll kısmını halledelim ve siteyi build edelim. Gördüğünüz gibi Jekyll Image'ını `build-env` kod adını veriyor sonra da bütün dosyaları `/src/jekyll` klasörü altına kopyalıyoruz. Daha sonra Jekyll özelinde bazı işlemler yaparak Jekyll'ın statik sitemizi `_site` klasörü altında oluşturmasını sağlıyoruz. Son iki komutu, `jekyll clean` ve `jekyll build` tek satır yerine iki satırda verdiğimize dikkat edin. Normalde bu komutlar ayrı ayrı Image katmanları oluşturacağı için aynı satırda vermek isteyecektik ama artık bunu umursamıyoruz çünkü bu katmanlar oluşacak final Image'da yer almayacaklar.

```Dockerfile
FROM jekyll/jekyll:3.5 AS build-env
COPY . /src/jekyll
# jekyll docker image uses 'jekyll' as user
# so change all permissions in the folder to jekyll
RUN chown -R jekyll /src/jekyll
WORKDIR /src/jekyll
RUN jekyll clean
RUN jekyll build 
```

İkinci adımda ise Dockerfile'a statik dosyaları koyacağımız Nginx Image'ının FROM komutunu ekleyerek başlıyoruz ve Nginx Image'ının `/usr/share/nginx/html/` klasörüne (yani dosyaları sunacağı klasöre) Jekyll Image'ı tarafından `/src/jekyll/_site` klasöründe üretilen dosyaları kopyalıyoruz. Böylece son oluşan Image'da Jekyll özelinde hiçbir dosya kalmıyor.

```Dockerfile
FROM nginx:1.10 AS runtime-env
COPY --from=build-env /src/jekyll/_site /usr/share/nginx/html/
```

Şimdi bir terminal açarak `docker build  -t gsengun/blog:0.1.0 .` komutunu vererek Image'ı build edin. Image oluştuktan sonra `docker run --rm -p 8080:80 gsengun/blog:0.1.0` komutunu vererek Container'ı başlatın ve sonrasında tarayıcınızdan `http://localhost:8080` adresini girin blog sayfamın tarayıcınızda görüntülendiğini göreceksiniz.

### Kapanış

Bir sonraki blog'da buluşmak üzere.

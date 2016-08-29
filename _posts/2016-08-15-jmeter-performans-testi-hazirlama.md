---
layout: post
title: "JMeter Bölüm 4: Performans Testi Nasıl Hazırlanır?"
level: Orta
published: false
progress: continues
---

JMeter'ın en çok kullanıldığı alan şüphesiz "Performans Testidir". Günümüz sistemlerinin geldiği noktada zengin fonksiyonlar sağlamak artık farklılık yaratan bir unsur olmaktan yavaş yavaş çıkmaktadır. Kullanıcılar üç aşağı beş yukarı benzer fonksiyonları sunan servisler arasında daha performanslı ve daha kararlı çalışan sistemleri tercih etmektedirler. Bu tarz sistemleri kullanıma sunmak için sistemin dar boğazlarını, yani performans problemi yaratacak bölümlerini, henüz gerçek kullanıcılar görmeden yakalamak ve çözmek için gerçek senaryolara yakın senaryolarda performans testleri yapmak gereklidir. JMeter sunduğu pratik test senaryosu hazırlama olanakları ve bu senaryoları farklı girdilerle paralel olarak istenen sayıda kullanıcı ile koşturabilme özellikleri ile Performans Testi yapmak için mükemmel bir alternatif olarak ortaya çıkmaktadır. JMeter ile paralel şekilde koşturulan sanal kullanıcılar kendilerine verilen senaryoları icra ederek sistemin verdiği cevapları ve metrikleri test sonrası kullanılmak üzere kaydederler. Oluşan bu bilgiler hemen test sonrası JMeter GUI'si ile incelenebildiği gibi bir dosyaya kaydedilerek test sonrası yine JMeter GUI ile açılıp incelenebilir. 

JMeter ile önceden bir deneyiminiz yoksa öncelikle aşağıdaki blog yazılarını okuyarak başlamanızı öneririz. Önceden deneyiminiz varsa bile aşağıda verilen blog yazılarını okumanızda fayda bulunmaktadır.

[JMeter Bölüm 1: Nedir ve Ne İşe Yarar?](/jmeter-nedir-ve-ne-ise-yarar/)

[JMeter Bölüm 2: Fonksiyon Testi Nasıl Hazırlanır?](/jmeter-fonksiyon-testi-hazirlama/)

[JMeter Bölüm 3: Pratik Test Senaryosu Kaydı Nasıl Yapılır?](/jmeter-pratik-test-hazirlama/)

Bu blog yazısını okuduktan sonra aşağıdaki blog yazısını da okumanız tavsiye edilir. Böylelikle JMeter'ı bütün yönleriyle anlamış olacağınızı umuyoruz.

[JMeter Bölüm 5: İleri Düzey Özellikleri Nelerdir?](/jmeter-ileri-duzey-ozellikler/)

### Çalışma Özeti

Bu blog'da JMeter'ı bir Performans Testi aracı olarak kullanacağız. Kurgulayacağımız .NET tabanlı basit bir sistemde farazi bir Üniversite Ders Kayıt sistemini JMeter ile test edeceğiz. Sistemde iyileştirmemiz gereken kısımları belirleyeceğiz ve sistemi iteratif olarak iyileştirerek performans istediğimiz düzeye gelene kadar testler yapmaya devam edeceğiz.

* Sistemimizin kullanım senaryolarını özetleyeceğiz 
* Docker Compose kullanarak oluşturduğumuz sistemimi tanıtarak başlayacağız.
* JMeter'da ilgili kullanım senaryolarını tek bir kullanıcı için koşturan bir Test Plan oluşturacağız.
* Input dosyası vererek oluşturduğumuz sistemi birçok kullanıcı için paralel olarak koşturacak ve test sonuçlarını inceleyeceğiz.
* Sistemimizde bir iyileştirme yaparak testi tekrar koşturacağız ve test sonuçlarını karşılaştırmalı olarak göreceğiz.
* Yüksek sayıda kullanıcıyı simüle etmek için JMeter Test Planlarını bulut (Cloud) üzerinde birçok makinada koşturmaya olanak tanıyan [Blazemeter](https://www.blazemeter.com)'a kısa bir bakış atarak bu blog'u noktalayacağız.

### Ön Koşullar

Bu blog'da yer verilen adımları takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker Compose ile oluşturulan sistemi çalıştırabilmek, bu konuda bilgi için [Docker Compose Blog'una](/docker-compose-nasil-kullanilir/) göz atabilirsiniz.

### Test Edilecek Sistemin Mimarisi ve Kullanım Senaryoları

Test edeceğimiz sistem farazi bir Üniversite Ders Kayıt sistemi olacak. Bir HTTP API olarak sunulan bu sistemde aşağıdaki üç fonksiyon bulunacaktır. 

1. Öğrenciler kendilerine sağlanan kullanıcı adı ve parola ile sistemden bir Token alacaklar ve sonraki isteklerde bunu kullanacaklar. (`/Token`)
2. Öğrenciler departman için açılan dersleri görebilecekler. (`/api/Registration/CoursesByStudent`)
3. Öğrenciler açık derslerden kendilerine dönem için yeni bir ders ekleyebilecekler. (`/api/Registration/AddCourseForStudent`)
4. Öğrenciler kendi aldıkları dersleri görebilecekler. (`/api/Registration/ListCoursesByDepartmentYearSeason`)

Bu sistem kendi bilgisayarınızda rahatlıkla ayağa kaldırabilmeniz ve bir dış bağımlılık olmadan testleri koşturabilmeniz için `Docker` ile paketlenmiş ve `Docker Compose` ile orkestre edilmiştir. Önceki blog'lardan [Docker Compose'a](/docker-compose-nasil-kullanilir/) göz atmanız faydalı olabilir. Sözün özü bundan sonraki kısımları çalıştırabilmek için sisteminizde Docker 1.12 ve üzeri ve Docker-Compose 1.6 ve üzeri versiyon bulunması gereklidir. Docker kullanmak istemiyorsanız sistemi küçük bir çabayla ayağa kaldırıp test edebilirsiniz.

Yapacağımız performans testiyle bağlantılı olmasa da sistemin altyapısı ile ilgili bilgi almak için projenin [Github](https://github.com/gokhansengun/Simple-Mono-Postgres-Demo)'daki açıklamasını okuyabilirsiniz. Test edeceğimiz sistem .NET'i Linux ve Mac'te çalıştırmak üzere varlık sürdüren açık kaynaklı [Mono](http://www.mono-project.com/) platformu üzerinde çalıştırılmaktadır. Sunulan HTTP API, ASP.NET Web API'deki OWIN/Katana altyapısı ile oluşturulmuştur. Veri tabanı şeması ve test dataların veri tabanına yazılması için [Flyway](https://flywaydb.org/), veri tabanına erişim için popüler Micro ORM'lerden [Dapper](https://github.com/StackExchange/dapper-dot-net) kullanılmaktadır. Bütün bu sistemler `Docker` ile paketlenmekte, `Docker Compose` ile orkestre edilmekte ve `Makefile` ile birleştirilmektedir. Bütün bu sistemlerle ilgili detaylı blog yazılarını önceki blog'lardan bulabilirsiniz.

### Tek Kullanıcı için Çalışacak JMeter Script'inin Oluşturulması

Performans testi için oluşturucağımız JMeter Script'ini öncelikle bir kullanıcı için çalıştırılabilir hale getirmemiz gerekmektedir. Test öncesinde ise test senaryomuzu oluşturmalıyız. Test senaryomuz aşağıdaki adımlardan oluşacaktır.

1. Kendisine sağlanan kullanıcı adı ve parola ile sisteme giriş yapması ve bir Token alması.
2. Öğrencinin Üniversite'nin bir departmanında (örneğin Elektrik-Elektronik - EE) açılan dersleri `/api/Registration/ListCoursesByDepartmentYearSeason` çağrısı ile listelemesi.
3. Öğrencinin listelenen derslerden 3 adet seçmesi ve `/api/Registration/AddCourseForStudent` çağrısı ile o dönem alacağı derslere eklemesi.
4. Aldığı dersleri `/api/Registration/ListCoursesByDepartmentYearSeason` ile listelemesi.

Önceki JMeter blog'larında JMeter Script oluşturmayı bol bol anlattık, bu sebeple bu bölümü normalden biraz hızlı geçeceğiz. Script'i hazır olarak vererek Script'te yer alan bölümleri anlatmakla yetineceğiz.

* [Tek Kullanıcı için JMeter Script'i](/resource/file/JMeterPart4/ListCoursesAndAddTestsOnePerson.jmx)
* [Kullanıcı Listesi](/resource/file/JMeterPart4/UserList.csv)

JMeter Script'imizin genel görünümü aşağıdaki gibidir.

{% include image.html url="/resource/img/JMeterPart4/JMeterScriptOverallLook.png" description="JMeter Script Overall Look" %}

#### Script Bölümleri

1. Öncelikle `User Defined Variables` bölümünü inceleyelim. Bu kısımda bağlanacak olduğumuz uygulama sunucusunun IP'si ile uygulamanın sunulduğu Port'u tanımladık. Uygulama boyunca bu bilgileri kullanarak bir değişiklik durumunda sadece bu kısmı değiştirerek IP ve Port değişikliğini sorunsuz gerçekleştirebileceğiz.

    {% include image.html url="/resource/img/JMeterPart4/UserDefinedVariables.png" description="User Defined Variables" %}

2. `CSV Data Set Config` bölümünde Registration sistemimize bağlı olan 10000 öğrencinin öğrenci numarası, email'i ve parolasını (aslında parolasının hash'i olması gerekiyor ama testi kolay yapabilmek için parolayı plain olarak tuttuk) sakladığımız CSV dosyasının (JMX dosyası ile aynı klasörde bulunan) ismini, içindeki değerlerin hangi sırayla bulunduğu (bizim için `student_id,username,password`) ve hangi karakterle (bizim için `;`) ayrıldığını konfigüre ettik.

    Bu dosya JMeter tarafından okunarak her bir satır JMeter tarafından oluşturulan Thread'lere (sanal kullanıcılar) atanacaktır. Böylelikle koşturduğumuz her bir thread dosyadaki satır sırasına göre ilgili öğrenciyi simüle edecektir. Bu dosyayı vererek testi şu anda yapacak olduğumuz gibi sadece 1 kullanıcı için çalıştırırsak bu kullanıcıya atanacak değişkenler dosyanın ilk satırındaki bilgiler olacaktır.

    {% include image.html url="/resource/img/JMeterPart4/CSVDataSetConfig.png" description="CSV Data Set Config" %}

3. `GetToken` adlı HTTP Sampler önceki blog'larda kullandığımız HTTP Sampler'ın neredeyse aynısıdır. Bu method testimizde öncekilerden farklı olarak JSON dönmektedir ve `Token` bilgisinin JSON'dan çekilmesi gereklidir. JMeter 3.0 versiyonu ile birlikte önceki versiyonlarda plugin'ler aracılığıyla desteklediği `JSON Path PostProcessor`'u default olarak desteklemektedir. Bu çağrıdan alınan `access_token` diğer HTTP Sampler'larda `HTTP Header Manager` yardımıyla HTTP Header'ına eklenmekte ve kullanıcının doğrulanma ve yetkilendirme testlerinden geçmesine yardımcı olmaktadır.

    `/Token` çağrısı aşağıdaki gibi bir JSON dönmektedir. 

        {
            "access_token":"A_LONG_LONG_VALUE",
            "token_type":"bearer",
            "expires_in":1209599,
            "userName":"student-10000@xxx.edu",
            ".issued":"Mon, 29 Aug 2016 00:26:49 GMT",
            ".expires":"Mon, 12 Sep 2016 00:26:49 GMT"
        }

    Bu JSON'dan `access_token` kısmının alınabilmesi için gerekli olan JSON Path Extractor konfigürasyonu aşağıda verilmiştir. Burada `$` root node'a karşılık gelmektedir. `$.` ile root node'un elemanlarına erişilmekte ve sonrasında `$.access_token` vb ifadelerle cevaptan dönen değerler alınabilmektedir.

    {% include image.html url="/resource/img/JMeterPart4/TokenJSONPathExtractor.png" description="Token JSON Path Extractor" %}

    Sentaksı daha iyi anlayabilmek için yeni bir örnek verelim. Eğer JSON cevabı aşağıdaki gibi olsaydı `access_token`'a erişmek için kullanmamız gereken Expression `$.token_info.access_token` olacaktı.

        {
            "token_info": 
            {
                "access_token":"A_LONG_LONG_VALUE",
                "token_type":"bearer",
                "expires_in":1209599,
                "userName":"student-10000@xxx.edu",
                ".issued":"Mon, 29 Aug 2016 00:26:49 GMT",
                ".expires":"Mon, 12 Sep 2016 00:26:49 GMT"
            },
            "welcome":
            {
                "server_name":"Server1",
                "no_of_cores":"32"
            }
        }

4. `api/Registration/ListCoursesByDepartmentYearSeason` HTTP çağrısı ile `EE` departmanın `2016` yılının Sonbahar döneminde açılan bütün derslerin listenmesi istenmiştir. JMeter Script'inin bu listeyi alarak daha sonra içinden 3 ders seçilerek öğrencinin ders listesine eklenmesi için kaydetmesi beklenmektedir.

    {% include image.html url="/resource/img/JMeterPart4/GetCoursesByDepartmentId.png" description="Get Courses By Department Id" %}

    Bu çağrıdan aşağıdakine benzer bir cevap dönmektedir.

        [
            {
                "CourseId":"EE100",
                "Credit":4,
                "Department":"EE",
                "Instructor":"Instructor-2",
                "Year":2016,
                "Season":1
            },
            {
                "CourseId":"EE102",
                "Credit":4,
                "Department":"EE",
                "Instructor":"Instructor-2",
                "Year":2016,
                "Season":1
            },
            ...
        ]

    Ders ekleme methodu `/api/Registration/AddCourseForStudent` için öğrencinin numarası ile `CourseId` yeterli olmaktadır. Bu sebeple aşağıdaki gibi `CourseId`'leri alan bir JSON Path Extractor beklentilerimizi karşılayacaktır. Bu JSON Path Extractor `avail_courses` değişkeninde dönen toplam kurs sayısını ve kurs Id'lerini tutacaktır. Bir sonraki adımda bu değişkenlerin BeanShell Sampler'ında kullanıldığı görülecektir.

    {% include image.html url="/resource/img/JMeterPart4/CourseIdJSONPathExtractor.png" description="Course Id JSON Path Extractor" %}

5. Toparlamak gerekirse bu adıma kadar sisteme giriş yaparak bir Token alan ve ilgili dönem için öğrencinin alımına açık olan dersler listelenmiş ve parse ederek kullanmaya hazır hale getirilmiştir. Bu adımda ise `api/Registration/AddCourseForStudent` HTTP çağrısı ile parse edilen ders listesinden rastgele 3 adet ders seçilerek bu dersler öğrencinin ders listesine eklenmiştir.

    Öncelikle ders ekleme işlemini 3 kere yapabilmek için aşağıdaki gibi bir `Loop Controller` eklendiğine dikkat ediniz.

    {% include image.html url="/resource/img/JMeterPart4/AddCoursesLoopController.png" description="Add Courses Loop Controller" %}

    Loop Controller'ın içinde, yani her bir Thread (user) için 3 kere koşturulmak üzere, aşağıdaki gibi bir BeanShell Sampler eklenerek rastgele 3 ders seçme işlemi burada yapılmış ve her bir Loop için seçilecek ders kodu `selected_course_id` değişkenine atılmıştır.

    {% include image.html url="/resource/img/JMeterPart4/AddCoursesBeanShellSampler.png" description="Add Courses BeanShell Sampler" %}

    Eklenecek ders, BeanShell Sampler ile belirledikten sonra nihayet `api/Registration/AddCourseForStudent` çağrısını yapılarak ders öğrencinin listesine eklenmektedir.

    {% include image.html url="/resource/img/JMeterPart4/AddCoursesHTTPSampler.png" description="Add Courses HTTP Sampler" %}

6. Son adım olarak ilgili dönem için listesine 3 ders eklenen öğrencinin bütün dersleri `api/Registration/coursesbystudent` HTTP çağrısı ile çekecek bir HTTP Sampler eklenmiştir.

    {% include image.html url="/resource/img/JMeterPart4/ListCoursesByStudentHTTPSampler.png" description="List Courses By Student HTTP Sampler" %}

### Test Sisteminin Ayağa Kaldırılması ve Tek Kişilik Testin Koşturulması

1. Test sistemini Github'dan lokal sistemimize klonlayarak başlayalım. Popüler Git Client'ınızdan ya da komut satırından `git clone https://github.com/gokhansengun/Simple-Mono-Postgres-Demo.git` komutunu vererek Repo'yu lokal dosya sisteminize kopyalayın.

2. Test yapacağımız sistemi Docker Compose ile ayağa kaldırmak için Repo'nun ana klasöründeki `Docker` klasörüne geçerek sırasıyla aşağıdaki komutları verin.

        $ docker-compose up build
        $ docker-compose up -d db
        $ docker-compose up flyway-migrator
        $ docker-compose up -d app

    Bu komutları verdikten ve tamamlanmalarını bekledikten sonra `docker-compose ps` komutunu verin. Aşağıdaki bir çıktı elde etmeniz gerekir. `docker_app_1` isimli uygulama sunucusu Container'ının 8090, `docker_db_1` veri tabanı sunucusunun ise 5432 numaralı portu dinlediğini gözlemleyin, gördüğünüz gibi test sistemimiz testimize hazırdır. 

        Gokhans-MacBook-Pro:Docker gsengun$ docker-compose ps
                Name                        Command               State            Ports
        -------------------------------------------------------------------------------------------
        docker_app_1               mono /artifact/UniversityR ...   Up       0.0.0.0:8090->8090/tcp
        docker_build_1             /bin/true                        Exit 0
        docker_db_1                /docker-entrypoint.sh postgres   Up       0.0.0.0:5432->5432/tcp
        docker_flyway-migrator_1   /scripts/wait-for-postgres ...   Exit 0

3. Önceki blog'larda JMeter'da Sampler'lar tarafından yapılan Request ve Response'ların loglanması için kullandığımız `View Results Tree` Listener'ına ek olarak Performans Testi yaparken `View Results in Table` ve `Summary Report` Listener'ları eklenerek sunucuya yapılan HTTP Request'ler ile ilgili detaylı bilgilerin tabular formatta alınması hedeflenmiştir.

    Performans testleri sırasında özellikle `Summary Report` Listener'ındaki bilgileri esas alarak sistemin istediğimiz performans kriterlerine getirmeye çalışacağız.

    Test Script'inin çalıştırılması ile oluşan `View Results in Table`'ın örnek çıktısı aşağıda verilmiştir. Bu Listener'da her bir Sampler'ın Sample Time'ı ve Latency'si ve Status'ü tabular formatta verilmiştir. `Sample Time (Örnekleme Süresi) ve Latency (Gecikme)` [ilk JMeter Blog](/jmeter-nedir-ve-ne-ise-yarar/)'unda detaylı olarak ilgili başlıkta açıklanmıştır.

    {% include image.html url="/resource/img/JMeterPart4/ExampleViewResultsInTable.png" description="Example of view Results in Table" %}

    Test Script'inin çalıştırılması ile oluşan `Summary Report`'un örnek çıktısı aşağıda verilmiştir. `View Results in Table`'de görülen çıktının gruplanmış (Avg, Min, Max, Std Dev) formu ile Throughput (saniyede yapılan Request sayısı) ve KB/sec (saniyede gönderilen KB miktarı) bilgilerini görüntülemektedir.

    {% include image.html url="/resource/img/JMeterPart4/ExampleSummaryReport.png" description="Example of Summary Report" %}

4. Her bir yük testinden sonra test sistemini resetlemek ve yeniden başlatmak önemlidir. Özellikle üst üste yapılan testlerden sonra veri tabanında biriken datalar ilerleyen testlerde performansı olumsuz etkileyebilir. Test sistemini Docker Compose ile kurduğumuz için `docker-compose down -v` komutunu çalıştırarak Docker Compose tarafından oluşturulan Container'ları ve Volume'ları kaldırabiliriz.

### İlk Performans Testi

Ve en heyecanlı bölüme geldik, birazdan ilk performans testimizi çalıştıracağız. Tek kullanıcı için doğru bir şekilde çalıştığını belirlediğimiz sistemi eş zamanlı 400 kullanıcı vererek test edelim.

1. Lokal'e kopyaladığınız Github Repo'sunun ana klasörüne göre `.\PerfTests` klasörünün altında bulunan `ListCoursesAndAddTestsOnePerson.jmx` dosyasını aynı klasöre kopyalayarak adını `ListCoursesAndAddTests.jmx` olarak değiştirerek JMeter ile açın.

2. Öncelikle Thread Group üstüne tıklayarak aşağıda görüldüğü gibi `Action to be taken after a Sampler error` bölümünde `Stop Test` olan konfigürasyonu `Stop Thread` olarak değiştirin. Bu değişiklikle alınacak herhangi bir hatada bütün testin durdurulması yerine sadece hata alan Thread'in durdurulması diğer Thread'lerin akışlarına devam etmesi hedeflenmiştir.

    Aynı ekranda `Number of Thread (users)` bölümünü `1`'den `400`'e değiştirin. 

    {% include image.html url="/resource/img/JMeterPart4/ThreadGroupConfigurationUpdate.png" description="Thread Group Configuration Update" %}

3. Bildiğiniz gibi `View Results Tree` ve `View Results in Table` Listener'ları bütün Sampler'ın Request ve Response'larını loglamaktadır. Performans testi sırasında JMeter tarafında bu tür işlemler yapmak JMeter'ın çalıştırıldığı bilgisayarın kaynaklarını test kullanıcısı yaratmak yerine loglamak için kullanacağı için bu Sampler'ları sadece hata durumlarında loglama yapacak şekilde ayarlamamız gereklidir. Aşağıdaki şekilde sadece Error olan Request'lerin loglanması sağlanabilir.

    {% include image.html url="/resource/img/JMeterPart4/LogErrorsOnlyViewResultsTree.png" description="Log Errors Only in View Results Tree" %}

    {% include image.html url="/resource/img/JMeterPart4/LogErrorsOnlyViewResultsInTable.png" description="Log Errors Only in View Results in Table" %}

4. Test sistemimizi tekrar ayağa kaldırmaya hazırız. Aşağıdaki komutlarla sistemi ayağa kaldıralım ve testi başlatmaya hazır hale gelelim.

        $ docker-compose up build
        $ docker-compose up -d db
        $ docker-compose up flyway-migrator
        $ docker-compose up -d app

5. JMeter'da testi başlatın ve `Summary Report`'taki sonucun ekran çıktısını alarak bir yere `JMeter-First-Test` ismi ile kaydedin. Benim bilgisayarımda oluşan çıktı aşağıdaki gibi oldu.

    {% include image.html url="/resource/img/JMeterPart4/FirstPerfTestResults.png" description="Result of first performans Test" %}

    Gördüğünüz gibi 400 kullanıcı için koşan testte kullanıcılar aşağıdaki gibi metrikler üretmiştir.
    
        `/Token` çağrısını Avg `1750 ms` ve Max `4045 ms`'de
        `/api/Registration/ListCoursesByDepartmentYearSeason` çağrısını Avg `259 ms` ve Max `1607 ms`'de
        `/api/Registration/AddCourseForStudent` çağrısını Avg `216 ms` ve Max `3959 ms`'de
        `/api/Registration/coursesbystudent` çağrısını Avg `149 ms` ve Max `3920 ms`'de

    Aslında sistemimiz 400 eş zamanlı kullanıcıya göre fena performans göstermedi. Kullanıcılar kabul edilebilir (`5000 ms`) sınırlar içerisinde isteklerine cevap alabildiler fakat 400 kullanıcı 4000 olduğunda Response zamanları da aynı oranda artarsa performans istenen sınırlar içerisinde kalmayacaktır. Şimdi iyileştirebildiğimiz kadar performansı iyileştirmeye çalışalım.  

### İyileştirme Denemesi ve Yeni Yük Testi


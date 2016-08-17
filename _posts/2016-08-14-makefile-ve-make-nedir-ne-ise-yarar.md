---
layout: post
title: "Makefile ve make nedir, ne işe yarar?"
level: Başlangıç
published: true
progress: finished-not-reviewed
---

Eğer daha önce C/C++ programlama dilleri ile program geliştirmiş, açık kaynak kodlu projeleri kaynağından derlemiş ve çalıştırmış iseniz muhakkak make ve Makefile'ı duymuş olmalısınız. Makefile'lar Unix/Linux'ta make, Windows'ta ise nmake araçları ile yorumlanır ve koşturulurlar. Makefile'ların en yaygın kullanımı, programların kaynak dosyalarının birbirleri ile bağımlılıklarını derleme ve linkleme (build) aşamasında yönetmek yani programlar derlenirken birbirlerine olan bağımlılıklara ve kaynak dosyaların son değiştirilme tarihlerine bakarak sadece derlenmesi gereken dosyaları derlemektir fakat Makefile'lar aslında çok farklı amaçlarla da kullanılabilirler. Bu blog'da sizleri Makefile ve make/nmake araçları ile tanıştırarak Makefile'ı günlük yaşantımızda sıklıkla karşılaştığımız problemlerin çözümünde nasıl kullanabileceğimizi göreceğiz.

### Çalışma Özeti

Bu blog'da Makefile yapısını ve make aracını bütün yönleri ile inceleyerek öğreneceğiz, sonrasında Makefile'ları pratik işlerde nasıl kullanabileceğimizi göreceğiz.

* Motivasyon olması açısından basit bir Makefile oluşturarak Makefile'ların nasıl çalıştığı ile ilgili kafamızda bir fikir oluşturmaya çalışacağız.
* Makefile'ın bağımlılık altyapısı ve formatı ile ilgili bilgiler edineceğiz.
* Makefile'ı ilerideki blog'larda hangi farklı senaryolar üzerinde konuşarak bu blog'u kapatacağız.

### Ön Koşullar

Bu blog'da yer verilen konuyu daha rahat takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* make aracı birçok Linux dağıtımında default olarak gelmekle birlikte Mac OS X'te default kurulumda bulunmamakta ve ayrıca kurulum gerektirmektedir. Aynı şekilde Windows'ta make'in karşılığı olan nmake aracı da Visual Studio ile birlikte gelmektedir. Blog boyunca örnekler (nmake bölümü hariç) Mac OS X üzerinde yapılacaktır fakat Linux/Unix sistemlerde sorunsuz çalışması beklenmektedir. 

#### Windows Kullanıcıları

Sağlayacağımız Makefile'lar aslında Windows sistemlerde nmake ile sentaks olarak sorunsuz çalışabilir fakat Makefile'lar içerisinde kullanılan komutların bazıları Windows sistemlerde bulunmayacağı için bu blog'da verilen adımlar sağlıklı bir şekilde takip edilemeyecektir. 

Windows'ta Linux/Unix'teki make aracını çalıştırabilmek için bugün itibari ile dört opsiyon bulunmaktadır.

1. Docker ile herhangi bir Ubuntu Linux bazlı Image terminal attached modda çalıştırılarak make aracına erişilebilir fakat Docker metin editörü olarak grafik bazlı bir araç sunmadığı için pek pratik olmayacaktır.
2. Virtual Box, Hyper-V veya VMware ile Windows üzerine Linux/Unix bazlı bir işletim sistemi kurulabilir.
3. Windows 10 öncesi sistemler için [Cygwin](https://www.cygwin.com/) kurularak buradan make aracına erişilebilir
4. Windows 10 kullanıcıları için bizim tavsiye edeceğimiz ise [Bash on Ubuntu on Windows](https://msdn.microsoft.com/en-us/commandline/wsl/about) ile birlikte Linux/Unix'teki make aracının kullanılmasıdır. Eğer Windows 10 kullanıyorsanız, bu yöntemi şiddetle tavsiye ederiz.

### Makefile ve Make Aracı - Giriş

Makefile'lar aşağıdaki formattaki Rule'lardan oluşur. Rule'ların başında Target ismi verilerek Target'ın bağımlılıkları (başka Target'lar ya da dosyalar) verilir. İkinci ve sonraki satırlarda ise TAB karakteri ile Target'a göre Indent edilmiş komutlar bulunur. Bu komutlar make aracının Target'ı koşturması sırasında çalıştırılır.

    target: bağımlılıklar
    [tab] komutlar 1
    [tab] komutlar 2
    [tab] komutlar 3

make aracı, Makefile'daki komutları koşturmakla görevlidir. make aracı, Makefile'daki Target'ların (ki çoğu zaman Target'lar dosyalardır) bağımlılıklarının son güncelleme tarihlerini tutarak, ilgili Target'ın bağımlıklarının değişip değişmediği dolayısıyla da ilgili Target'ın yeniden koşturulmasına gerek olup olmadığına karar verir. Eğer Target'ın bağımlılıkları son koşturulma zamanından sonra değiştirilmediyse aynı girdilerle aynı çıktı meydana geleceği için make, Target'ın altındaki komutları koşturmaz. Bu tanım biraz karışık gelmiş gibi görünse de birazdan vereceğimiz örneklerle daha anlaşılır hale gelecek. Bu arada aynı girdilerle aynı çıktı meydana gelecek dedik ancak bunun doğru olmadığı çıktının zamana ve başka koşullara bağlı olduğu durumlar da vardır fakat nadirdir. Makefile bu tür durumların belirtilmesi için de bazı mekanizmalar sağlamaktadır, ilerleyen bölümlerde buna da değineceğiz.

Tanıtım bölümünde de bahsedildiği gibi Makefile ve make genellikle kaynak dosyaların derlenmesi, birleştirilmesi ve çalıştırılabilir dosya elde edilmesinde kullanılırlar fakat başka bir sürü kullanım alanı da bulunmaktadır. Şimdi çok basit bir senaryoda Makefile ve make kullanımını örnekleyelim.

### Basit Bir Senaryo'da Makefile ve make

Kurgulayacağımız senaryo çalışma klasörümüzündeki bir kaynak dosyanın başına `/* Copyright (C) 2016 Gökhan Şengün - All Rights Reserved */` yazılması olsun. Bu senaryoda güncel klasördeki `Hello.js` kaynak dosyasını her güncellediğimizde aynı klasör altına `Hello.out.js` adında yeni bir dosya olarak Copyright'lı metin eklenmiş versiyonu bu dosyaya içerik olarak ekleyeceğiz.

1. Yeni bir klasör oluşturarak, klasörün içerisinde aşağıdaki içerikle `Hello.js` adlı bir dosya oluşturun.

        (function InitFunc() {
            console.log("Init function does here");
        })();

2. Şimdi bir Makefile oluşturarak aşağıdaki kod parçasını ekleyin.

    `ÇOK ÖNEMLİ NOT:` Makefile'ın içerisinde target'ların (aşağıdaki örnekteki `copyright`) altındaki komutların SPACE (boşluk) karakteri yerine TAB karakteri ile ayrılması gereklidir. Bu blog'da kullanılan HTML üretici maalesef TAB'ları SPACE'e dönüştürdüğü için aşağıdaki kodu kopyalayıp yapıştırdıktan sonra SPACE karakterleri TAB'a çevirmeniz ya da verilen linklerden indirmeniz gerekmektedir. 

        copyright: Hello.out.js 

        Hello.out.js: Hello.js
            echo "/* Copyright (C) 2016 Thomas Edison - All Rights Reserved */" > /tmp/cpyr;
            cat /tmp/cpyr Hello.js > Hello.out.js

    [Yukarıdaki Makefile'ı indirin](/resource/file/Makefile/1/Makefile)

    Şimdi yukarıda verdiğimiz Makefile'ın içeriğini özetleyelim. `copyright: Hello.out.js` satırında `copyright` adlı bir Target yaratılmış ve bu Target'ın başka bir Target'a yani `Hello.out.js`'e bağımlı olduğu verilmiştir. `Hello.out.js: Hello.js` satırında ise `Hello.out.js` Target'ının `Hello.js` dosyasına bağımlı olduğu belirtilmiştir. 
    
    Burada ifade edilenler aslında `Hello.js` dosyası her değiştiğinde `Hello.out.js` Target'ının, `Hello.out.js` Target'ı her değiştiğinde ise `copyright` Target'ının yeniden koşturulması gerekliliğidir. 

3. Bir terminal açarak ilgili klasöre gidip `make` veya `make copyright` komutunu çalıştırın. Aşağıdakine benzer bir çıktı görmelisiniz.

        Gokhans-MacBook-Pro:1 gsengun$ make
        echo "/* Copyright (C) 2016 Thomas Edison - All Rights Reserved */" > /tmp/cpyr;
        cat /tmp/cpyr Hello.js > Hello.out.js

    Çıktıdan görebileceğiniz ve beklendiği üzere `make`, `Hello.out.js` Target'ının altındaki komutları koşturmuştur. `cat Hello.out.js` komutu ile dosyanın içeriğine bakın ve Copyright metninin kaynak dosyaya eklendiğini kontrol edin.

        Gokhans-MacBook-Pro:1 gsengun$ cat Hello.out.js
        /* Copyright (C) 2016 Thomas Edison - All Rights Reserved */
        (function InitFunc() {
            console.log("Init function does here");
        })();

4. Şimdi terminalden tekrar `make` komutunu çalıştırın, aşağıdakine benzer bir çıktı görmelisiniz. Burada `make`, `Hello.js` dosyası `make`'in bir önceki çalıştırılmasına göre değişmediği için oluşacak çıktının farklı olmayacağını öngörerek `Nothing to be done for 'copyright'.` çıktısını üretmiştir.

        Gokhans-MacBook-Pro:1 gsengun$ make
        make: Nothing to be done for `copyright'. 

5. `Hello.js` dosyasında küçük bir değişiklik yaparak ya da `touch Hello.js` komutunu koşturup işletim sistemine `Hello.js` dosyasının değiştiğini düşündürterek `make` komutunu tekrar çalıştırın. Bu kez `make`'in tekrar çalıştığını ve `Hello.out.js` dosyasını tekrar ürettiğini görmelisiniz.

        Gokhans-MacBook-Pro:1 gsengun$ touch Hello.js
        Gokhans-MacBook-Pro:1 gsengun$ make
        echo "/* Copyright (C) 2016 Thomas Edison - All Rights Reserved */" > /tmp/cpyr;
        cat /tmp/cpyr Hello.js > Hello.out.js

### Makefile'ın Bağımlılık Yapısı ve Formatı

Makefile'ların Rule'lardan oluştuğunu giriş bölümünde söylemiştik. Rule Sentaks'ı aşağıdaki gibidir.

    target: bağımlılıklar
    [tab] komutlar 1
    [tab] komutlar 2
    [tab] komutlar 3

Target'lar genel olarak dosya isimleridir ancak dosya ismi olmak zorunda değildirler. Target'ların dosya ismi olduğu durumlardan birini bir önceki bölümde özetledik, bir diğeri ise make'in en yaygın kullanımı olan C ve C++ dosyalarının Compile ve Link işlemidir. Target'ların dosya ismi olmadığı durumlara bir sonraki bölümde bir örnek vereceğiz.

Yine genellikle bir Rule'da sadece bir Target bulunmaktadır ancak birden fazla target bulunmaması için herhangi bir engel yoktur. Rule, Makefile'da iki şey ifade eder; birincisi Target'ın güncel olup olmadığı, ikincisi ise eğer güncel değil ise nasıl yani hangi komutlarla tekrar güncel hale getirilebileceğidir.

Bir önceki bölümdeki örnekte gördüğünüz gibi Makefile'larda Shell (Terminal) komutları koşturabiliriz. Rule'larla kurguladığımız iş parçacıklarından birbirleri ile ilgili olanlar için bağımlılıklar tanımlanabilir ve iş parçacıkları Shell (genellikle Bash) komutları ile uygulanarak karmaşık sistemler tasarlanabilir.

Şimdi biraz daha pratik olması ve yazdıklarımızı örneklemesi açısından bir örnek ile devam edelim.

Yeni senaryomuz Makefile ile hazırlanan bir CI (Continuous Integration) / CD (Continuous Delivery) Pipeline'ı olsun. İlgili Pipeline'da klasik olarak kaynak dosyaların Build edilmesi, başarılı Build sonrası Unit (Birim) Test'lerin çalıştırılması, Unit Test'lerin de başarılı olması ile Acceptance (Kabul) Test'lerin koşturulması, Acceptance Test'lerin de başarılı bir şekilde geçmesiyle uygulamanın Deploy edilmesi bulunmaktadır. Buradaki basit bağımlılıklar aşağıdaki Makefile ile gerçekleştirilebilir.

    all: deploy 

    build :
        echo "Building the project now";

    unit_test : build
        echo "Running Unit Tests";

    acceptance_test : unit_test
        echo "Running Acceptance Tests";

    deploy : acceptance_test
        echo "Everything is fine deploying the app";

[Yukarıdaki Makefile'ı indirin](/resource/file/Makefile/2/Makefile)

Görebileceğiniz gibi `all` Target'ı `deploy` Target'ına, `deploy` Target'ı `acceptance_test` Target'ına, `acceptance_test` Target'ı `unit_test` Target'ına, `unit_test` Target'ı `build` Target'ına bağlanmıştır. Dolayısıyla `all` Target'ı çalıştırıldığında öncelikle en uç Dependency (bağımlılık) en son da ilk bağımlılık çalıştırılacaktır dolayısıyla çalıştırılma sırası `build`, `unit_test`, `acceptance_test` ve `deploy` şeklinde olacaktır.

Makefile'ı bilgisayarınıza indirip `make all` veya `make deploy` komutlarını çalıştırınca aşağıdakine benzer bir çıktı görmelisiniz.

    Gokhans-MacBook-Pro:2 gsengun$ make all
    echo "Building the project now";
    Building the project now
    echo "Running Unit Tests";
    Running Unit Tests
    echo "Running Acceptance Tests";
    Running Acceptance Tests
    echo "Everything is fine deploying the app";
    Everything is fine deploying the app

Aynı şekide sadece `unit_test`'leri çalıştırmak istediğimizi düşünelim. make öncelikle `build` Target'ını çalıştırarak kaynak dosyaları build edip sonra `unit_test` Target'ını çalıştıracaktır. Örnek çıktı aşağıda verilmiştir.

    Gokhans-MacBook-Pro:2 gsengun$ make unit_test
    echo "Building the project now";
    Building the project now
    echo "Running Unit Tests";
    Running Unit Tests

Daha karmaşık Makefile'larda bir bağımlılık birden fazla Target için sağlanmış olabilir. Eğer make'in iki Target'ı birden çalıştırması gerekiyorsa bağımlılık sadece bir kere çalıştırılır. Aşağıdaki örneği inceleyelim.

    all: target3 

    common_dep :
        echo "Common Dependency Running";

    target1 : common_dep
        echo "Running Target1";

    target2 : common_dep target1
        echo "Running Target2";

    target3 : target1 target2 common_dep
        echo "Running Target3";

[Yukarıdaki Makefile'ı indirin](/resource/file/Makefile/3/Makefile)

Target'lardan kimin kime bağımlı olduğunu artık öğrendiğimizi varsayarak yazmıyorum. Burada `make target3` komutunu koşturduğumuzda bütün Target'ların bağımlı olduğu `common_dep` Target'ının sadece bir kez koşturulduğunu görebilirsiniz.

    Gokhans-MacBook-Pro:3 gsengun$ make target3
    echo "Common Dependency Running";
    Common Dependency Running
    echo "Running Target1";
    Running Target1
    echo "Running Target2";
    Running Target2
    echo "Running Target3";
    Running Target3

Son olarak ele alacağımız senaryoda bu bölümün başında örnekleyeceğimize söz verdiğimiz senaryoyu örnekleyelim.

Aşağıdaki Makefile'ı kopyaladığınız klasöre `output` adında bir dosya yaratın.

    all: output 

    output :
        echo "Running Output Target"

[Yukarıdaki Makefile'ı indirin](/resource/file/Makefile/4/Makefile)

Terminal'de ilgili klasöre gidip `make all` ya da `make output` komutlarını verdiğinizde Target'ın koşturulmadığını göreceksiniz. Aynı klasörde Target ile aynı isimde `output` bir dosya olduğu için ve dosya değiştirilmediği için make, Target'ın güncel olduğunu düşünmekte ve güncellemeye çalışmamaktadır. Peki bu (kazara Target ile aynı klasördeki bir dosya isminin aynı olduğu) durumda Target'ın çalıştırılması nasıl sağlanabilir?

    Gokhans-MacBook-Pro:4 gsengun$ make output
    make: `output' is up to date.

Eğer Target'ın gerçekten dosyalarla ilişkisi yoksa Target `PHONY` olarak tanımlanır ve make'in Target'ı sürekli güncellemeye çalışması (dolayısıyla komutları çalıştırması) sağlanabilir. Makefile'ı aşağıdaki gibi değiştirerek aynı adımları tekrarladığınızda bu kez Target'ın make tarafından güncellenmeye çalışılacağını görebilirsiniz.

    .PHONY: output
    all: output 

    output :
        echo "Running Output Target"

[Yukarıdaki Makefile'ı indirin](/resource/file/Makefile/5/Makefile)

Yeni Makefile ile make'in Target'ı her durumda güncellemeye çalıştığını görebilirsiniz.

    Gokhans-MacBook-Pro:5 gsengun$ make all
    echo "Running Output Target"
    Running Output Target

    Gokhans-MacBook-Pro:5 gsengun$ make output
    echo "Running Output Target"
    Running Output Target

### Sonuç

Sanırım bu blog'da verdiğimiz bilgiler ile make aracının Makefile'lar ile birlikte ne kadar güçlü bir altyapı sunduğunu gösterebilmişizdir. make aracı muhtemelen birçoğunuzun günlük direkt veya endirekt olarak kullandığı Ant ve MSBuild gibi araçların atasıdır. Güncel JavaScript Client Side Build Automation (İstemci Tarafı Build Otomasyon) tool'larından [Gulp](http://gulpjs.com/)'ın da atası make denebilir. make'i anlamak bilinç düzeyinizin yükselmesine katkıda bulunacağı gibi karmaşık Script'ler ile daha uzun yoldan ve daha az okunur kodlar yazmak yerine kullanabileceğiniz güçlü bir alternatif de sunmaktadır.

Bu blog'da make'e yer verilmesinin bir amacı da ilerleyen günlerde bu blog'da, [Docker Compose blog](/docker-compose-nasil-kullanilir/)'unda tanıtılan Docker Compose aracında sunulan fonksiyonlara make'in fonksiyonlarını katarak [Jenkins](https://jenkins.io/)'le işletilen Docker bazlı bir Continuous Integration Pipeline'ının nasıl hazırlanacağını özetleyen bir blog'a yer verilecek olmasıdır. Dolayısıyla bu blog ifade edilen çalışmaya önceki blog'larla birlikte bir altyapı oluşturmaya çalışmaktadır.

Sonraki blog'larda görüşmek üzere. 
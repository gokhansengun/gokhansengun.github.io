---
layout: post
title: "Makefile ve make nedir, ne işe yarar?"
level: Başlangıç
published: false
progress: continues
---

Eğer daha önce C/C++ programlama dilleri ile program geliştirmiş, açık kaynak kodlu projeleri kaynağından derlemiş ve çalıştırmış iseniz muhakkak Makefile'ı duymuş olmalısınız. Makefile Unix/Linux'ta make Windows'ta ise nmake araçları ile yorumlanır ve koşturulurlar. Makefile'ların en yaygın kullanımı programların kaynak dosyalarının birbirleri ile bağımlılıklarını yönetmek ve programlar derlenirken bu bağımlılıklara ve kaynak dosyaların son değiştirilme tarihlerine bakarak derlenmesi gereken dosyaları derlemektir fakat aslında çok farklı amaçlarla da kullanılabilirler. Bu blog'da sizleri Makefile ve make/nmake araçları ile tanıştırarak Makefile'ı günlük yaşantımızda sıklıkla karşılaştığımız problemlerin çözümünde nasıl kullanabileceğimizi göreceğiz.

### Çalışma Özeti

Bu blog'da Makefile yapısını ve make aracını bütün yönleri ile inceleyerek öğreneceğiz, sonrasında Makefile'ları pratik işlerde nasıl kullanabileceğimizi göreceğiz.

* Motivasyon olması açısından basit bir Makefile oluşturarak Makefile'ların nasıl çalıştığı ile ilgili kafamızda bir fikir oluşturmaya çalışacağız.
* Makefile'ın bağımlılık altyapısı ve formatı ile ilgili bilgiler edineceğiz.
* Windows'taki nmake aracına kısaca göz atacağız.
* Makefile'ı kullanabileceğimiz farklı senaryolar üzerinde konuşarak bu blog'u kapatacağız.

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
4. Windows 10 kullanıcıları için benim tavsiye edeceğim ise [Bash on Ubuntu on Windows](https://msdn.microsoft.com/en-us/commandline/wsl/about) ile birlikte Linux/Unix'teki make aracının kullanılmasıdır. Eğer Windows 10 kullanıyorsanız, bunu şiddetle tavsiye ederim.

### Makefile ve Make Aracı - Giriş

make aracı Makefile'daki komutları koşturmakla görevlidir. make aracı Makefile'da referans verilen dosyaların son güncelleme tarihlerini tutarak, ilgili dosyaların referans edildiği kurallar veya ilgili dosyaların referans edildiği kuralları referans eden kuralların dosya değişikliğinden kaynaklı olarak koşturulup koşturulmaması gerektiğine karar verir. Bu tanım biraz karışık gelmiş gibi görünse de birazdan vereceğimiz örneklerle daha anlaşılır hale gelecek. 

Tanıtım bölümünde de bahsedildiği gibi Makefile ve make genellikle kaynak dosyaların derlenmesi, birleştirilmesi ve çalıştırılabilir dosya elde edilmesinde kullanılırlar fakat başka bir sürü kullanım alanı da bulunmaktadır. Şimdi çok basit bir senaryoda Makefile ve make kullanımını örnekleyelim.

### Basit Bir Senaryo'da Makefile ve make

Kurgulayacağımız senaryo çalışma klasörümüzündeki bir kaynak dosyanın başına `/* Copyright (C) 2016 Thomas Edison - All Rights Reserved */` yazılması olsun. Bu senaryoda güncel klasördeki `Hello.js` kaynak dosyasını her güncellediğimizde ilgili klasör altındaki `dist` klasörünün altına aynı dosyanın başına Copyright konmuş halini kopyalayacağız.

1. Yeni bir klasör oluşturarak, klasörün içerisinde aşağıdaki içerikle `Hello.js` adlı bir dosya oluşturun.

        (function InitFunc() {
            console.log("Init function does here");
        })();

2. Makefile aşağıdaki formattaki Rule'lardan oluşur.

        target: bağımlılıklar
        [tab] komutlar
        
    Şimdi bir Makefile oluşturarak aşağıdaki kod parçasını ekleyin.

    `ÇOK ÖNEMLİ NOT:` Makefile'ın içerisinde target'ların (aşağıdaki örnekteki `copyright`) altındaki komutların SPACE (boşluk) karakteri yerine TAB karakteri ile ayrılması gereklidir. Bu blog'da kullanılan HTML üretici maalesef TAB'ları SPACE'e dönüştürdüğü için aşağıdaki kodu kopyalayıp yapıştırdıktan sonra SPACE karakterleri TAB'a çevirmeniz ya da verilen linklerden indirmeniz gerekmektedir. 

        copyright: Hello.out.js 

        Hello.out.js: Hello.js
            echo "/* Copyright (C) 2016 Thomas Edison - All Rights Reserved */" > /tmp/cpyr;
            cat /tmp/cpyr Hello.js > Hello.out.js

    [Yukarıdaki Makefile'ı indir](/resource/file/Makefile/1/Makefile)

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


---
layout: post
title: "Docker Bölüm 2: Yeni bir Docker Image'ı Nasıl Hazırlanır?"
level: Başlangıç
progress: continues
---

Docker blog serimizin ilk bölümünde Docker nedir, nasıl çalışır ve nerede kullanılır sorularına cevap aramış ve Docker'a detaylı bir giriş yapmıştık. Önceki blog'da bahsettiğimiz gibi [DockerHub](https://hub.docker.com) gerek official (Ubuntu, Nginx, Redis, vb) gerekse de bu Image'lardan türetilen ve farklı özellikler barındıran birçok farklı ve çok faydalı Image içermektedir. Bu Image'lar ihtiyaçlarımızı çok büyük oranda karşılasa da kısa sürede gerek official gerekse de diğer repository'lerdeki Image'ları özelleştirme ihtiyacı ortaya çıkmaktadır. Blog serimizin ikinci bölümü olan bu blog'da Docker'ın sunduğu zengin özelleştirme araçlarını kullanarak mevcut Docker Image'larını özelleştirerek ihtiyaçlarımıza uygun hale getireceğiz ve bir yandan da Docker'ı bu vesile ile daha yakından tanımış olacağız. 

Docker blog serisinin ilki aşağıda verilmiştir. Eğer daha önce okumadıysanız bu blog'u da okumanızı tavsiye ederim.

[Docker Bölüm 1: Nedir, Nasıl Çalışır, Nerede Kullanılır?](/docker-nedir-nasil-calisir-nerede-kullanilir/)

Docker Image hazırlamayı gösteren bu ikinci blog'da da günlük kullanım örneklerine pek değinemeyeceğiz. Docker'ın pratik kullanım alanlarını aşağıda linki verilen blog'da özetlemeye gayret edeceğim. Bu blog'u okuduktan sonra onu okumanızı tavsiye ederim.

[Docker Bölüm 3: Docker Compose Hangi Amaçlarla ve Nasıl Kullanılır?](/docker-compose-nasil-kullanilir/)

### Çalışma Özeti
___

Bu blog'da aşağıdaki adımları tamamlayarak Docker'ı daha etkili kullanmak ve ihtiyaçlarımız için özelleştirme ile ilgili detaylı bilgileri tanıtmaya ve örneklemeye çalışacağız.

* Dockerfile'ın yapısını ve komutlarını inceleyerek başlayacağız.
* Image Layer'lar (katmanlar) ve kullanım alanlarını, çözdükleri problemleri anlayacağız.
* Farklı senaryolar içeren iki Image'ı özelleştirecek ve DockerHub'da başkalarının kullanımına sunacağız.
* Github'da oluşturduğumuz bir repo'da tuttuğumuz kaynak dosya ile DockerHub'da otomatik build yapısını kurarak blog'u kapatacağız.

### Ön Koşullar

Bu blog'da yer verilen adımları takip edebilmeniz için aşağıdaki koşulları sağlamanız beklenmektedir.

* İlgili platformda (Windows, Linux, Mac) komut satırı (command window veya terminal) kullanabiliyor olmak.
* Docker CLI ile ilgili genel bilgi sahibi olmak.

### Dockerfile

Önceki blog'da Docker'ın LXC'ye göre getirdiği en önemli özelliklerden birisinin koşturduğu Container'ın yapısını metin bazlı bir dosya ile tutması ve böylece Image'dan Container oluşturma işlemini standardize ve tekrarlanabilir kılması olduğunu belirtmiştik. Bla bla bla
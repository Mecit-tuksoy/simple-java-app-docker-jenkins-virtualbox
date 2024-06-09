# Google Cloud Platform'da Ubuntu 24.04 LTS Minimal Sunucu Kurulumu

## Adım 1: Google Cloud Platform'da Proje Oluşturma

### Google Cloud Console'a Giriş Yapın
1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin ve Google hesabınızla giriş yapın.

### Yeni Bir Proje Oluşturun
1. Üstteki proje seçicisini tıklayın ve "Yeni Proje"yi seçin.
2. Projeye bir isim verin ve oluşturun.

## Adım 2: Compute Engine API'sini Etkinleştirme

### Compute Engine API'sini Etkinleştirin
1. Menüden "Compute Engine" -> "VM Instances" sekmesine gidin.
2. "Enable" butonuna tıklayarak Compute Engine API'sini etkinleştirin.

## Adım 3: Yeni Bir VM Oluşturma

### Yeni VM Instance Oluşturma
1. "Create Instance" butonuna tıklayın.

### VM Ayrıntılarını Belirleme
1. **Name:** VM'ye bir isim verin.
2. **Region and Zone:** İhtiyacınıza göre bir bölge ve zona seçin.
3. **Machine Type:** Gerekli CPU ve RAM miktarını seçin (örneğin, e2-micro minimal bir kurulum için uygun olur).

### Boot Disk (Başlangıç Diski) Ayarları
1. **Boot Disk:** "Change" butonuna tıklayın.
2. **Operating System:** "Ubuntu" seçin.
3. **Version:** "Ubuntu 24.04 LTS" seçin.
4. **Disk Type:** İhtiyacınıza göre disk tipini (Standard Persistent Disk veya SSD Persistent Disk) seçin.
5. **Size:** Disk boyutunu belirleyin (örneğin, 10 GB).

### Firewall Ayarları
1. "Allow HTTP traffic" ve "Allow HTTPS traffic" seçeneklerini işaretleyin (isteğe bağlı).
2. "Allow SSH traffic" seçeneğini işaretleyin.

Jenkins sunucusuna sadece HTTPS üzerinden erişim sağlamak için yapılabilecek alternatif yaklaşımlar şunlardır:

HTTP ve HTTPS Ters Proxy Kurulumu: Jenkins sunucusu önünde bir ters proxy (reverse proxy) kurarak, gelen HTTP isteklerini HTTPS'e yönlendirebilirsiniz. Bu şekilde, Jenkins sunucusuna gelen tüm istekler otomatik olarak HTTPS üzerinden yönlendirilir.

8080 Portunu Kapatma: Jenkins sunucusundaki 8080 portunu kapatarak, sadece HTTPS üzerinden erişim sağlanmasını sağlayabilirsiniz. Ancak, bu yaklaşım bazı durumlarda kullanıcılara ulaşmakta güçlük çıkarabilir, bu nedenle dikkatlice planlanmalıdır.

Jenkins İçinde SSL Konfigürasyonu: Jenkins sunucusunda doğrudan SSL konfigürasyonu yaparak, 8080 portunu tamamen devre dışı bırakabilir ve yalnızca HTTPS üzerinden hizmet verebilirsiniz.

### Oluşturma
1. "Create" butonuna tıklayarak VM'yi oluşturun.

## Adım 4: SSH ile Bağlantı Kurma

### Google Cloud Console üzerinden SSH ile Bağlantı
1. VM Instances listesinden yeni oluşturduğunuz VM'yi bulun.
2. "SSH" butonuna tıklayarak tarayıcı üzerinden VM'ye bağlanın.


## Adım 5: Ubuntu 24.04 LTS'yi Güncelleme 

### Paketleri Güncelleme
SSH ile bağlandıktan sonra, paket listelerini güncelleyin ve sisteminizi güncel tutun:
```sh
sudo apt update
sudo apt upgrade

```

### İlgili olmayan ek paketlerin yüklü olup olmadığının kontrolü :


````bash
dpkg -l | grep xorg
dpkg -l | grep xserver
````

Bu komutlar hiçbir çıktı döndürmedi, yani X Sunucusu kurulu değil.

````sh
dpkg -l | grep gnome
dpkg -l | grep kde
dpkg -l | grep lxde
````
Bu komutlar da hiçbir çıktı döndürmedi, yani GNOME, KDE, LXDE gibi grafiksel masaüstü ortamları kurulu değil.


````sh
dpkg -l | grep 'openssh-server'
````
Bu komut, SSH sunucusunun kurulu olduğunu gösterdi.




#### jenkins kurulumu:

jenkins.sh dosyası oluşturup içine bunları yapıştırıyoruz;

````sh

#!/bin/bash

# Sistemi güncelleyin
sudo apt update -y

# install java 17
sudo apt install openjdk-17-jdk -y

# Jenkins GPG anahtarını ve depo ekleyin
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Depoları güncelleyin ve Jenkins'i kurun
sudo apt update -y
sudo apt install jenkins -y

# Jenkins hizmetini etkinleştirin ve başlatın
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Kurulumun başarılı olup olmadığı kontrol ediliyor
if systemctl is-active --quiet jenkins; then
    echo "Jenkins başarıyla kuruldu!"
    echo "Jenkins web arayüzüne tarayıcınızdan http://<sunucu_ip_adresi>:8080 adresinden erişebilirsiniz."
else
    echo "Jenkins kurulumu başarısız oldu. Lütfen hataları kontrol edin."
fi
````


## YENİ VM AYAĞA KALDIR (jENKİNS SERVİR GİBİ) 
Bu server Nginx ve Certbot kullanarak güvenli bağlantı için kullanılacak.

# Bu serverin public ip'sine Domain name ile "A record" yapacağız. "www" olan ve olmayan şeklinde

### Jenkins'in Güvenli Bağlantısının Ayarlanması (SSL):

## Nginx ile Reverse Proxy Kurulumu:

Ücretsiz Let’s Encrypt Sertifikası Kullanmak
````sh
sudo apt update -y
sudo apt install -y nginx
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d mecitdevops.com -d www.mecitdevops.com
````
# Çıktı bu şekilde olacak:

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
 (Enter 'c' to cancel): mecit.tuksoy@gmail.com

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.4-April-3-2024.pdf. You must agree in
order to register with the ACME server. Do you agree?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y
Account registered.
Requesting a certificate for mecitdevops.com and www.mecitdevops.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/mecitdevops.com/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/mecitdevops.com/privkey.pem
This certificate expires on 2024-09-03.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for mecitdevops.com to /etc/nginx/sites-enabled/default
Successfully deployed certificate for www.mecitdevops.com to /etc/nginx/sites-enabled/default
Congratulations! You have successfully enabled HTTPS on https://mecitdevops.com and https://www.mecitdevops.com
We were unable to subscribe you the EFF mailing list because your e-mail address appears to be invalid. You can try again later by visiting https://act.eff.org.

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

````bash
cd /etc/nginx/sites-available/              
````
bu dizindeki 'default' dosyasını aşağıdaki gibi değiştiriyoruz

````sh

upstream app {
    server <jenkins-server-private-ip>:8080;

}

server {
    listen 80 default_server;
    server_name <domain-name>;

    # All other requests get load-balanced
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl default_server;

    server_name <domain-name>;

    ssl_certificate      /etc/letsencrypt/live/<domain-name>/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/<domain-name>/privkey.pem;

    charset utf-8;

    location / {
        include proxy_params;
        proxy_pass http://app;
        proxy_redirect off;

        # Handle Web Socket connections
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

````

# Bu değişiklikleri yaptıktan sonra bir yanlışlık olup olmadığını kontrol etmek için:

````sh
nginx -t
````
çıktısı bu şekilde ise devam edebiliriz:

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful


# nginx'i yeniden başlatmak için:

````sh
sudo systemctl restart nginx.service
````


# domain name ile güvenli bağlantı ile (domain name) jenkinse bağlanabiliriz
 ````sh
 sudo cat /var/lib/jenkins/secrets/initialAdminPassword 
````
bu komutu jenkins serverinda girerek gelen şifreyi tarayıcıda ilgili yere yazıyoruz ve jenkins'e giriyoruz.

Gelen ekranda "Install suggested plugins" e tıklayarak devam ediyoruz.

"Create First Admin User" sayfasında yeni kullanıcı adı ve şifre belirlip başlatma işlemini bitiriyoruz.




# Gerekli eklentilerin yüklenmesi

Jenkins yönetim panelinden "Manage Jenkins" > "Manage Plugins" yolunu izleyerek Git, Pipeline, ve Docker Pipeline eklentilerini yükleyin.

Docker Pipeline Plugin: Bu eklenti, Jenkins pipeline'ında Docker ile ilgili işlemleri kolayca yapmanızı sağlar. Docker container'larını çalıştırabilir, yapılandırabilir ve temizleyebilirsiniz.

Docker Commons Plugin: Bu eklenti, Docker ile ilişkili işlemlerde kullanılan genel araçları sağlar. Diğer Docker eklentileri tarafından kullanılır.

Docker Build Step Plugin: Bu eklenti, Jenkins iş akışlarında Docker imajlarını oluşturmak için bir adım sağlar. Dockerfile kullanarak imaj oluşturma işlemlerini kolaylaştırır.

CloudBees Docker Pipeline Plugin: Bu eklenti, Jenkins pipeline'larında Docker kullanımını genişletir. Docker imajları oluşturmak, çalıştırmak ve yönetmek için ek yetenekler sağlar.

Docker Traceability Plugin: Bu eklenti, Jenkins tarafından kullanılan Docker imajlarının izlenebilirliğini sağlar. Docker imajlarının ve konteynerlerin kullanımıyla ilgili bilgileri toplar ve raporlar.

## webhooks trigir ayarı
Adım 1: Jenkins GitHub Plugin'i Yükleme
Jenkins ana sayfasında "Manage Jenkins"e gidin.
"Manage Plugins"e tıklayın.
"Available" sekmesine gidin ve "GitHub Integration Plugin" ve "GitHub Plugin" gibi GitHub ile ilgili eklentileri arayın ve yükleyin.
Adım 2: Jenkins Job'unu Yapılandırma
Jenkins ana sayfasında, tetiklemek istediğiniz job'u açın veya yeni bir job oluşturun.
"Configure"e tıklayın.
"Source Code Management" sekmesine gidin ve Git'i seçin. Git repository URL'sini girin.
"Build Triggers" sekmesine gidin ve "GitHub hook trigger for GITScm polling" seçeneğini işaretleyin.
Değişiklikleri kaydedin.
Adım 3: GitHub Webhook Ayarları
GitHub repository'nize gidin.
Repository'nin sağ üst köşesindeki "Settings"e tıklayın.
Sol menüde "Webhooks"u seçin ve "Add webhook"e tıklayın.
"Payload URL" kısmına Jenkins sunucunuzun URL'sini girin. Örneğin: http://your-jenkins-server/github-webhook/
"Content type" olarak "application/json" seçin.
"Which events would you like to trigger this webhook?" altında "Just the push event" veya tetiklemek istediğiniz diğer olayları seçin.
"Add webhook"e tıklayın.


## Jenkins'te Docker Hub kimlik bilgilerinizi ayarlamak için:

1- Jenkins dashboard'una gidin.
2- Sol taraftaki menüden "Credentials" seçeneğine tıklayın.
3- "System" sekmesine geçin.
4- "Global credentials (unrestricted)" altında "Add Credentials" seçeneğine tıklayın.
5- Credential türü olarak "Username with password" seçin.
6- Docker Hub kullanıcı adınızı ve parolanızı girin.
7- Kimlik bilgileriniz için bir tanım verin (örneğin, "docker-hub-credentials").
8- "OK" veya "Save" düğmesine tıklayarak bilgilerinizi kaydedin.


# Docker Hub'da bir access token oluşturmak için:

1- Docker Hub'a giriş yapın.
2- Sağ üst köşede bulunan profil simgesine tıklayın ve "Account Settings" (Hesap Ayarları) sekmesine gidin.
3- Sol taraftaki menüden "Security" (Güvenlik) sekmesine tıklayın.
4- "New Access Token" (Yeni Erişim Anahtarı) düğmesine tıklayın.
5- Gerekli izinleri seçin ve "Generate" (Oluştur) düğmesine tıklayarak yeni bir access token oluşturun.
6- Oluşturulan token'ı kopyalayın.



# dockerhub'a push işlemi için:
````sh
docker tag my-java-app:latest mecit35/my-java-app:latest
docker push mecit35/my-java-app:latest
````





1. SSH Anahtar Çifti Oluşturun
Hedef makineye bağlanmak için bir SSH anahtar çifti oluşturmanız gerekiyor. Eğer zaten bir anahtar çiftiniz varsa bu adımı atlayabilirsiniz.

sh
Kodu kopyala
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
2. Genel Anahtarı Hedef Makineye Ekleyin
Oluşturduğunuz genel anahtarı (~/.ssh/id_rsa.pub dosyasını) hedef makinedeki ~/.ssh/authorized_keys dosyasına ekleyin.

3. Jenkins SSH Kimlik Bilgilerini Yapılandırın
Jenkins'e SSH anahtar çiftinizi tanımlayın.

Jenkins Web Arayüzüne gidin.
Credentials bölümüne gidin.
(global) alanını seçin.
Add Credentials butonuna tıklayın.
Kind olarak SSH Username with private key seçin.
ID ve Description alanlarını doldurun. Örneğin, ID olarak ssh-credentials kullanabilirsiniz.
Username alanına, hedef makinedeki kullanıcı adını girin.
Private Key alanına, oluşturduğunuz özel anahtarı (~/.ssh/id_rsa dosyasını) yapıştırın.




##  Google Cloud SDK'yı (gcloud) Kurun
Jenkins'in çalıştığı makinede Google Cloud SDK'nın kurulu olması gerekiyor. Bunu yapabilmek için:

Debian/Ubuntu için:
````sh
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get install apt-transport-https ca-certificates gnupg
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
````

google cloud'da instance'a bağlanma
````sh
 gcloud compute ssh mecit_tuksoy@nginx --zone=us-central1-a --project=sodium-daylight-425313-u7
 ````






#### Projenin kök dizininde "Maven Wrapper" kullanmak için ön ayar yapılması

Maven Wrapper'ı Projeye Ekleme
Maven Wrapper'ı Kurun: Maven 3.5.0 veya daha yeni bir sürümünü kullanarak Maven Wrapper'ı projenize ekleyin. Bunun için terminal veya komut satırında projenizin kök dizinine gidin ve aşağıdaki komutu çalıştırın:

````sh
mvn -N io.takari:maven:wrapper
````
Bu komut Maven Wrapper betiği (mvnw ve mvnw.cmd), maven-wrapper.properties dosyası ve ilgili jar dosyalarını (.mvn/wrapper/maven-wrapper.jar) projenize ekler.

maven-wrapper.properties Dosyasını Güncelleyin: Maven Wrapper'ı kullanarak hangi Maven sürümünü kullanmak istediğinizi belirtmek için maven-wrapper.properties dosyasını güncelleyin.

````sh
distributionUrl=https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.7/apache-maven-3.9.7-bin.zip
wrapperUrl=https://repo.maven.apache.org/maven2/io/takari/maven-wrapper/0.5.6/maven-wrapper-0.5.6.jar
````
Maven Wrapper'ı Kullanarak Projeyi Derleyin: Artık mvnw betiği projede bulunduğuna göre, Maven komutlarını çalıştırmak için mvnw betiğini kullanabiliriz:

````sh
./mvnw clean install
````





## Dosya İzinlerini Ayarlamak

````sh
sudo chmod 644 /etc/nginx/sites-available/jenkins
````










# Maven Projesini Çalıştırma ve Docker İmajı Oluşturma

## Proje Derleme

Maven kullanarak projeyi derleyin ve paketleyin:

```bash
mvn clean package
```


target dizininde JAR dosyasını kontrol edin: 

````bash
ls target/

````

Dockerfile'ınızı JAR dosyasının adı ve yoluna göre güncelleyin.


## Dockerfile Oluşturma
Projenizin kök dizininde bir Dockerfile oluşturun ve aşağıdaki içeriği ekleyin:

```bash

Dockerfile
Kodu kopyala
FROM openjdk:17-jdk-alpine
COPY target/my-app-1.0-SNAPSHOT.jar /myapp/app.jar
WORKDIR /myapp
CMD ["java", "-jar", "app.jar"]

```

## Docker İmajını Oluşturma

```bash
docker build -t my-java-app .
```

# Docker İmajını Çalıştırma

```bash

docker run -p 3000:8080 my-java-app

```

Bu komut, Docker konteynerini başlatır ve uygulamanızı 3000 portunda çalıştırır.


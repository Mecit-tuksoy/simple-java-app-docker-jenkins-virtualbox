 ####################################################################  
# Google Cloud Platform'da Ubuntu 24.04 LTS Minimal Sunucu Kurulumu  #
 ####################################################################

# Adım 1: Google Cloud Platform'da Proje Oluşturma

### Google Cloud Console'a Giriş Yapın
1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin ve Google hesabınızla giriş yapın.

### Yeni Bir Proje Oluşturun
1. Üstteki proje seçicisini tıklayın ve "Yeni Proje"yi seçin.
2. Projeye bir isim verin ve oluşturun.

# Adım 2: Compute Engine API'sini Etkinleştirme

### Compute Engine API'sini Etkinleştirin
1. Menüden "Compute Engine" -> "VM Instances" sekmesine gidin.
2. "Enable" butonuna tıklayarak Compute Engine API'sini etkinleştirin.

# Adım 3: Yeni Bir VM Oluşturma

### Yeni VM Instance Oluşturma (Jenkins için)
1. "Create Instance" butonuna tıklayın.

### VM Ayrıntılarını Belirleme
1. **Name:** VM'ye bir isim verin. **(Jenkins)**
2. **Region and Zone:** İhtiyacınıza göre bir bölge ve zona seçin. (us-central1 (Iowa)) (us-central1-a)
3. **Machine Type:** Gerekli CPU ve RAM miktarını seçin (e2-standard-2 (2 vCPU, 1 core, 8 GB memory)).

### Boot Disk (Başlangıç Diski) Ayarları
1. **Boot Disk:** "Change" butonuna tıklayın.
2. **Operating System:** "Ubuntu" seçin.
3. **Version:** "Ubuntu 24.04 LTS" seçin.
4. **Disk Type:** İhtiyacınıza göre disk tipini seçin.
5. **Size:** Disk boyutunu belirleyin (örneğin, 10 GB).

### Firewall Ayarları
1. "Allow HTTP traffic" ve "Allow HTTPS traffic" seçeneklerini işaretleyin.
2. "Allow SSH traffic" seçeneğini işaretleyin.


### Oluşturma
1. "Create" butonuna tıklayarak VM'yi oluşturun.

# Adım 4: SSH ile Bağlantı Kurma

### Google Cloud Console üzerinden SSH ile Bağlantı
1. VM Instances listesinden yeni oluşturduğunuz VM'yi bulun.
2. "SSH" butonuna tıklayarak tarayıcı üzerinden VM'ye bağlanın.


# Adım 5: Ubuntu 24.04 LTS'yi Güncelleme 

### Paketleri Güncelleme
SSH ile bağlandıktan sonra, paket listelerini güncelleyin ve sisteminizi güncel tutun:
```sh
sudo apt update
sudo apt upgrade
```


## İlgili olmayan ek paketlerin yüklü olup olmadığının kontrolü :


````bash
dpkg -l | grep xorg
dpkg -l | grep xserver
#Bu komutlar hiçbir çıktı döndürmedi, yani X Sunucusu kurulu değil. 

# xserver-xorg ve onunla ilişkili tüm paketleri tamamen kaldırmak için:
sudo apt-get remove --purge xserver-xorg* --yes

#Artık kullanılmayan bağımlılık paketlerini ve yapılandırma dosyalarını kaldırmak için:
sudo apt-get autoremove --purge --yes

#İndirme önbelleğini temizlemek için:
sudo apt-get clean
````

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


Sistemi güncelleyin:
````sh
sudo apt-get update
sudo apt-get upgrade 
````


############################
### jenkins kurulumu:  ###
############################

Jenkins serverda :

'jenkins.sh' dosyası oluşturup içine bunları yapıştırıyoruz;

````sh
nano jenkins.sh
````


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

Yetkilendirme
````sh
sudo chmod 755 jenkins.sh
````

jenkins.sh' dosyasını çalıştırıyoruz ve Jenkins kurulacak

````sh
bash ./jenkins.sh
````


###########################################
### Jenkins Server'a Docker kurulumu:  ###
###########################################

'docker.sh' dosyası oluşturma:

````sh
nano docker.sh
````
dosyanın içi:
````sh
#!/bin/bash

# Docker'ı kurmadan önce mevcut Docker kurulumlarını kaldırın
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Docker için gereksinim duyulan paketleri yükleyin
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Docker'ın resmi GPG anahtarını ekleyin
yes | curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docke>

# Docker resmi apt repository'sini kurun
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://dow>
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Paket veritabanını güncelleyin ve Docker'ı yükleyin
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Docker'ın başlangıçta başlatılmasını sağlayın
sudo systemctl enable docker
sudo systemctl start docker

# Kullanıcıyı docker grubuna ekleyin
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins

# Jenkins hizmetini yeniden başlatın
sudo systemctl restart jenkins

# Docker'ın kurulumunu ve sürümünü kontrol edin
docker --version

echo "Docker başarıyla kuruldu ve yapılandırıldı."

# Oturumu yeniden yükle
newgrp docker
````

Yetkilendirme
````sh
sudo chmod 755 docker.sh
````

jenkins.sh' dosyasını çalıştırıyoruz ve Jenkins kurulacak

````sh
bash ./docker.sh
````


####################################################
#### YENİ VM AYAĞA KALDIR (jENKİNS SERVİR GİBİ) ####
####################################################

Servere-name: 'nginx'

Bu server Nginx ve Certbot kullanarak güvenli bağlantı için kullanılacak.

**Bu serverin 'nginx server' public ip'sine Domain name ile "A record" yapacağız. "mecitdevops.com"  ve "www.mecitdevops.com" şeklinde**

### Jenkins'in Güvenli Bağlantısının Ayarlanması (SSL):

## Nginx ile Reverse Proxy Kurulumu:

Ücretsiz Let’s Encrypt Sertifikası Kullanmak

Sırası ile aşağıdaki komutları girerek 'nginx' ve 'certbot' kuruyoruz.
````sh
sudo apt update -y
sudo apt install -y nginx
sudo apt install certbot python3-certbot-nginx -y
````
# kurulumdan sonra domain name belirtiyoruz
````sh
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
sudo rm -rf default
sudo nano default
````


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
sudo nginx -t
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

Gelen ekranda **Install suggested plugins** e tıklayarak devam ediyoruz.

**Create First Admin User** sayfasında yeni kullanıcı adı ve şifre belirlip başlatma işlemini bitiriyoruz.




# Gerekli eklentilerin yüklenmesi için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet"  seçeneğine tıklayın.

3- "Eklentiler" tıklayın

4-  "Yüklenebilecek eklentiler" bölümünden **Docker** , **Docker Pipeline**, **Docker Build Step** eklentilerini yükleyin.




## GitHub'ta webhooks ayarlamak için:

1-  GitHub hesabınıza giriş yapın ve ilgili repository'yi seçin.

2-  Repository'nin üst kısmındaki menüden "Settings"e tıklayın.

3-  Sol taraftaki menüden "Webhooks" sekmesine tıklayın.

4- "Add Webhook" butonuna tıklayın.

5- "Payload URL" alanına "https://www.<domain-name>/github-webhook/" yazın.

6-  Başka bir değişiklik veya girdi yapmadan "Add Webhook" diyebiliriz. 




# Docker Hub'da bir access token oluşturmak için:

1- Docker Hub'a giriş yapın.

2- Sağ üst köşede bulunan profil simgesine tıklayın ve "Account Settings" (Hesap Ayarları) sekmesine gidin.

3- Sol taraftaki menüden "Security" (Güvenlik) sekmesine tıklayın.

4- "New Access Token" (Yeni Erişim Anahtarı) düğmesine tıklayın.

5- Gerekli izinleri seçin ve "Generate" (Oluştur) düğmesine tıklayarak yeni bir access token oluşturun.

6- Oluşturulan token'ı kopyalayın.



## Jenkins'te Docker Hub kimlik bilgilerinizi ayarlamak için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet"  seçeneğine tıklayın.

3- "Credentials" sekmesine geçin.

4- "Global credentials (unrestricted)" altında "Add Credentials" seçeneğine tıklayın.

5- Credential türü olarak "Username with password" seçin.

6- Docker Hub kullanıcı adınızı ve parolanızı (tokenda olur) girin.

7- "ID" kısmına Kimlik bilgileriniz için bir tanım verin (örneğin, "docker-hub-credentials").(Bunu Jenkinsfile'da kullanıcaz)

8- "Create" düğmesine tıklayarak bilgilerinizi kaydedin.



## Jenkins'te Google Cloud kimlik bilgilerinizi (key) ayarlamak için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet"  seçeneğine tıklayın.

3- "Credentials" sekmesine geçin.

4- "Global credentials (unrestricted)" altında "Add Credentials" seçeneğine tıklayın.

5- Credential türü olarak "Secret file" seçin.

6- Localdeki key file dosyasını yükleyin.

7- "ID" kısmına Kimlik bilgileriniz için bir tanım verin (örneğin, "gcloud-creds"). (Bunu Jenkinsfile'da kullanıcaz)

8- "Create" düğmesine tıklayarak bilgilerinizi kaydedin.




## Jenkins'de webhooks trigir ayarı için:

1- Jenkins ana sayfasında "Yeni Öğe"'ye tıklayın.

2- Öğe adını girin.

3- "Pipeline" seçin.

4- "Build Triggers" tetikleyici oluşturma kısmından "GitHub hook trigger for GITScm polling" tik atın.

5- "Pipeline" altında "Definition" kısmında "SCM" yi "Git" seçin

6- "Repository URL" kısmına github repo url girin.

7- "Branch Specifier (blank for 'any')"  kısmına hangi branch'da çalışmasını istiyorsanız yazabilirsiniz.

8- "Script Path"  Jenkinsfile ismi farklı ise onu burada belirtmelisiniz.

9- "Kaydet" diyebiliriz.



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

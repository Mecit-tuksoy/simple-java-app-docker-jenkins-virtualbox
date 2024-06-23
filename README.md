






















####################################################################

# Google Cloud Platform'da Ubuntu 24.04 LTS Minimal Sunucu Kurulumu

####################################################################

# Google Cloud Platform'da Proje Oluşturma

### Google Cloud Console'a Giriş Yapın

1. [Google Cloud Console](https://console.cloud.google.com/) adresine gidin ve Google hesabınızla giriş yapın.

### Yeni Bir Proje Oluşturun

1. Üstteki proje seçicisini tıklayın ve "New Project"yi seçin.
2. Projeye bir isim verin ve oluşturun.

# Compute Engine API'sini Etkinleştirme

### Compute Engine API'sini Etkinleştirin

1. Menüden "Compute Engine" -> "VM Instances" sekmesine gidin.
2. "Enable" butonuna tıklayarak Compute Engine API'sini etkinleştirin.

# Yeni Bir VM Oluşturma

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

### Oluşturma

1. "Create" butonuna tıklayarak VM'yi oluşturun.

### Firewall Ayarları

1. "Allow HTTP traffic", "Allow HTTPS traffic" seçeneğini işaretleyin.
2. "VM instance" sayfasından "Set up firewall rules" seçin
3. Açılan sayfadan "CREATE FIREWALL RULE" seçin
4. Açılan sayfada dolduracağımız alanlar:
   Name:jenkins-sg-8080
   Targets: All instances in the network
   Source IPv4 ranges: 0.0.0.0/0
   TCP: 8080
5. Create

## SSH ile Bağlantı Kurma

### Google Cloud Console üzerinden SSH ile Bağlantı

1. VM Instances listesinden yeni oluşturduğunuz VM'yi bulun.
2. "SSH" butonuna tıklayarak tarayıcı üzerinden VM'ye bağlanın.

# Ubuntu 24.04 LTS'yi Güncelleme

### Paketleri Güncelleme

SSH ile bağlandıktan sonra, paket listelerini güncelleyin ve sisteminizi güncel tutun:

```sh
sudo apt update
sudo apt upgrade
```

############################

### jenkins kurulumu:

############################

Jenkins serverda :

'jenkins.sh' dosyası oluşturup içine bunları yapıştırıyoruz;

```sh
nano jenkins.sh
```

```sh
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


IP=$(curl -s ifconfig.me)
# Kurulumun başarılı olup olmadığı kontrol ediliyor
if systemctl is-active --quiet jenkins; then
    echo "Jenkins başarıyla kuruldu!"
    echo "Jenkins web arayüzüne tarayıcınızdan http://$IP:8080 adresinden erişebilirsiniz."
else
    echo "Jenkins kurulumu başarısız oldu. Lütfen hataları kontrol edin."
fi
```

Yetkilendirme

```sh
ls -al
sudo chmod 755 jenkins.sh
```

jenkins.sh' dosyasını çalıştırıyoruz ve Jenkins kurulacak

```sh
bash ./jenkins.sh
```

###########################################

### Jenkins Server'a Docker kurulumu:

###########################################

'docker.sh' dosyası oluşturma:

```sh
nano docker.sh
```

dosyanın içi:

```sh
#!/bin/bash

# Docker'ı kurmadan önce mevcut Docker kurulumlarını kaldırın
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Docker için gereksinim duyulan paketleri yükleyin
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Docker'ın resmi GPG anahtarını ekleyin
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker resmi apt repository'sini kurun
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
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
```

Yetkilendirme

```sh
ls -al
sudo chmod 755 docker.sh
```

docker.sh' dosyasını çalıştırıyoruz ve Jenkins kurulacak

```sh
bash ./docker.sh

#Docker grubunda jenkins oluduğunu kontrol et:
getent group docker
```

####################################################

#### YENİ VM AYAĞA KALDIR (jENKİNS SERVİR GİBİ)

####################################################

Servere-name: 'nginx'

Bu server Nginx ve Certbot kullanarak güvenli bağlantı için kullanılacak.

**Bu serverin 'nginx server' public ip'sine Domain name ile "A record" yapacağız. "mecitdevops.com" ve "www.mecitdevops.com" şeklinde**

### Jenkins'in Güvenli Bağlantısının Ayarlanması (SSL):

## Nginx ile Reverse Proxy Kurulumu:

Ücretsiz Let’s Encrypt Sertifikası Kullanmak

Sırası ile aşağıdaki komutları girerek 'nginx' ve 'certbot' kuruyoruz.

```sh
sudo apt update -y
sudo apt install -y nginx
sudo apt install certbot python3-certbot-nginx -y
```

# kurulumdan sonra domain name belirtiyoruz

```sh
sudo certbot --nginx -d mecitdevops.com -d www.mecitdevops.com
```

# Çıktı bu şekilde olacak:

Saving debug log to /var/log/letsencrypt/letsencrypt.log
Enter email address (used for urgent renewal and security notices)
(Enter 'c' to cancel): mecit.tuksoy@gmail.com

---

Please read the Terms of Service at
https://letsencrypt.org/documents/LE-SA-v1.4-April-3-2024.pdf. You must agree in
order to register with the ACME server. Do you agree?

---

(Y)es/(N)o: y

---

Would you be willing, once your first certificate is successfully issued, to
share your email address with the Electronic Frontier Foundation, a founding
partner of the Let's Encrypt project and the non-profit organization that
develops Certbot? We'd like to send you email about our work encrypting the web,
EFF news, campaigns, and ways to support digital freedom.

---

(Y)es/(N)o: y
Account registered.
Requesting a certificate for mecitdevops.com and www.mecitdevops.com

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/mecitdevops.com/fullchain.pem
Key is saved at: /etc/letsencrypt/live/mecitdevops.com/privkey.pem
This certificate expires on 2024-09-03.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for mecitdevops.com to /etc/nginx/sites-enabled/default
Successfully deployed certificate for www.mecitdevops.com to /etc/nginx/sites-enabled/default
Congratulations! You have successfully enabled HTTPS on https://mecitdevops.com and https://www.mecitdevops.com
We were unable to subscribe you the EFF mailing list because your e-mail address appears to be invalid. You can try again later by visiting https://act.eff.org.

---

If you like Certbot, please consider supporting our work by:

- Donating to ISRG / Let's Encrypt: https://letsencrypt.org/donate
- Donating to EFF: https://eff.org/donate-le

---

```bash
cd /etc/nginx/sites-available/
```

bu dizindeki 'default' dosyasını aşağıdaki gibi değiştiriyoruz

```sh
sudo rm -rf default
sudo nano default
```

```sh
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

```

yetki kontrol:

```sh
ls -al
```

# Bu değişiklikleri yaptıktan sonra bir yanlışlık olup olmadığını kontrol etmek için:

```sh
sudo nginx -t
```

çıktısı bu şekilde ise devam edebiliriz:

nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

# nginx'i yeniden başlatmak için:

```sh
sudo systemctl restart nginx.service
```

# domain name ile güvenli bağlantı ile (domain name) jenkinse bağlanabiliriz

```sh
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

bu komutu jenkins serverinda girerek gelen şifreyi tarayıcıda ilgili yere yazıyoruz ve jenkins'e giriyoruz.

Gelen ekranda **Install suggested plugins** e tıklayarak devam ediyoruz.

**Create First Admin User** sayfasında yeni kullanıcı adı ve şifre belirlip başlatma işlemini bitiriyoruz.

# Nginx kurduğumuz makinede oluşturacağımız image çekip docker containere çalıştıracağımız için bu makineyede docker kuruyoruz:

```sh
sudo nano docker.sh
```

docker.sh dosyasının içeriği:

```sh
#!/bin/bash

# Docker'ı kurmadan önce mevcut Docker kurulumlarını kaldırın
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# Docker için gereksinim duyulan paketleri yükleyin
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Docker'ın resmi GPG anahtarını ekleyin
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Docker resmi apt repository'sini kurun
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Paket veritabanını güncelleyin ve Docker'ı yükleyin
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Docker'ın başlangıçta başlatılmasını sağlayın
sudo systemctl enable docker
sudo systemctl start docker

# Kullanıcıyı docker grubuna ekleyin
sudo usermod -aG docker $USER

# Docker'ın kurulumunu ve sürümünü kontrol edin
docker --version

echo "Docker başarıyla kuruldu ve yapılandırıldı."

# Oturumu yeniden yükle
newgrp docker
```

Çalıştırmak içim:

```sh
bash ./docker.sh
```

# Domain name ile jenkinse bağlanarak gerekli eklentilerin yüklenmesi için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet" seçeneğine tıklayın.

3- "Eklentiler" tıklayın

4- "Yüklenebilecek eklentiler" bölümünden **Docker** , **Docker Pipeline** eklentilerini yükleyin.

## GitHub'ta webhooks ayarlamak için:

1- GitHub hesabınıza giriş yapın ve ilgili repository'yi seçin.

2- Repository'nin üst kısmındaki menüden "Settings"e tıklayın.

3- Sol taraftaki menüden "Webhooks" sekmesine tıklayın.

4- "Add Webhook" butonuna tıklayın.

5- "Payload URL" alanına "https://www.<domain-name>/github-webhook/" yazın.

6- Başka bir değişiklik veya girdi yapmadan "Add Webhook" diyebiliriz.

# Docker Hub'da bir access token oluşturmak için:

1- Docker Hub'a giriş yapın.

2- Sağ üst köşede bulunan profil simgesine tıklayın ve "Account Settings" (Hesap Ayarları) sekmesine gidin.

3- Sol taraftaki menüden "Security" (Güvenlik) sekmesine tıklayın.

4- "New Access Token" (Yeni Erişim Anahtarı) düğmesine tıklayın.

5- Gerekli izinleri seçin ve "Generate" (Oluştur) düğmesine tıklayarak yeni bir access token oluşturun.

6- Oluşturulan token'ı kopyalayın.

## Jenkins'te Docker Hub kimlik bilgilerinizi ayarlamak için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet" seçeneğine tıklayın.

3- "Credentials" sekmesine geçin.

4- "Global credentials (unrestricted)" altında "Add Credentials" seçeneğine tıklayın.

5- Credential türü olarak "Username with password" seçin.

6- Docker Hub kullanıcı adınızı ve parolanızı (tokenda olur) girin.

7- "ID" kısmına Kimlik bilgileriniz için bir tanım verin (örneğin, "docker-hub-credentials").(Bunu Jenkinsfile'da kullanıcaz)

8- "Create" düğmesine tıklayarak bilgilerinizi kaydedin.

# Google Cloud'da VM instance bağlanmak için :

1- IAM & Admin bölümüne git

2- "Service accounts" tıkla

3- "CREATE SERVICE ACCOUNT" tıkla

4- "Service account details" bölümünde
isim yaz,
"Grant this service account access to project" bölümünde "Owner" seç
"DONE" tıkla bitir.

5- Oluşturduğun Service account' a tıkla

6- açılan sayfada "KEY" tıkla

7- "ADD KEY" tıkla ve "Service account" ardından json formatında "create" et ve kaydet.

## Jenkins'te Google Cloud kimlik bilgilerinizi (key) ayarlamak için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet" seçeneğine tıklayın.

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

7- "Branch Specifier (blank for 'any')" kısmına hangi branch'da çalışmasını istiyorsanız yazabilirsiniz.

8- "Script Path" Jenkinsfile ismi farklı ise onu burada belirtmelisiniz.

9- "Kaydet" diyebiliriz.

#############################

###### Jenkinsfile

#############################

```sh

pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials') # jenkinse eklediğimiz "docker-hub-credentials" id'li credentials
        DOCKER_USERNAME = 'mecit35'    #dockerhub kullanıcı adı
        REMOTE_HOST = 'nginx'          # Gcloud'da kurduğumuz ikinci makine ismi
        REMOTE_USER = 'mecit_tuksoy'   # Gcloud'da kurduğumuz ikinci makinenin kullanıcı ismi "whoami"
        PROJEKT_ID = 'deneme-426109'   # Gcloud'da çalıştığımız proje id'si
        GCLOUD_CREDS = credentials('gcloud-creds')    # jenkinse eklediğimiz "gcloud-creds" id'li credentials
        ZONE = 'us-central1-a'         # Gcloud'da kurduğumuz makinelerin Zone'ları

    }

    stages {
        stage('Clone repository') {
            steps {
                sh 'rm -rf simple-java-container-CI-CD || true'
                sh 'git clone https://github.com/Mecit-tuksoy/simple-java-container-CI-CD.git'
            }
        }

        stage('Package Application') {
            steps {
                echo 'Compiling source code'
                sh '. ./jenkins/package-application.sh'
            }
        }

        stage('Prepare Tags for Docker Images') {
            steps {
                echo 'Preparing Tags for Docker Images'
                script {
                    MVN_VERSION = sh(script: '. ${WORKSPACE}/target/maven-archiver/pom.properties && echo $version', returnStdout: true).trim()
                    env.IMAGE_TAG = "my-java-app-v${MVN_VERSION}".toLowerCase()
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --force-rm -t ${IMAGE_TAG} .'
            }
        }


        stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR')]) {
                        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                        sh "docker tag ${IMAGE_TAG}:latest ${DOCKER_USERNAME}/${IMAGE_TAG}:latest"
                        sh "docker push ${DOCKER_USERNAME}/${IMAGE_TAG}:latest"
                        }
                    }
                }
            }



        stage('Deploy on other linux machine') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKERHUB_CREDENTIALS_PSW', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR')]) {
                    sh '''
                      gcloud version
                      gcloud auth activate-service-account --key-file="$GCLOUD_CREDS"
                      gcloud compute ssh ${REMOTE_USER}@${REMOTE_HOST} --zone=${ZONE} --project=${PROJEKT_ID} --command="
                          echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin
                          docker pull ${DOCKER_USERNAME}/${IMAGE_TAG}:latest
                          docker run -d -p 8080:8080 ${DOCKER_USERNAME}/${IMAGE_TAG}:latest
                          sleep 30
                          curl http://localhost:8080
                      "
                    '''
                }
            }
        }
    }
}

```

# Pipeline "Package Application" aşamasında kullandığı "package-application.sh" dosyası:

Proje ile aynı dizinde "jenkins" klasörünün içinde olmalı.

dosya oluştur ve içine git:

```sh
mkdir jenkins && cd jenkins
# package-application.sh dosyası oluştur
nano package-application.sh
```

Dosya içeriği:

```sh
docker run --rm -v $HOME/.m2:/root/.m2 -v $WORKSPACE:/app -w /app maven:3.8-openjdk-11 mvn clean package
```

# Pipeline "Build Docker Image" aşamasında kullandığı "Dockerfile" dosyası:

```sh
nano Dockerfile
```

Dosya içeriği:

```sh
FROM openjdk:17-jdk-alpine
COPY target/my-app-1.0-SNAPSHOT.jar /myapp/app.jar
WORKDIR /myapp
CMD ["java", "-jar", "app.jar"]
```

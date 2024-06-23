 ### Ubuntu 24.04 LTS minimal kurulumunu

 Sanal makine yönetim yazılımı olarak VirtualBox kullanıldı. 

VirtualBox'ı indir: VirtualBox İndir (https://www.virtualbox.org/wiki/Downloads) (Windows host seçtim)
İndirdiğiniz kurulumu çalıştırarak VirtualBox'ı bilgisayarınıza kurun.

1- VirtualBox'ı açın.

2- "Yeni" butonuna tıklayın.

3- Sanal makine için bir isim verin (örneğin, "jenkins").

4- Ubuntu 24.04 LTS Minimal Kurulum İmajını İndir  (https://ubuntu.com/download/server)

5- "Katılımsız kurulum" kutucuğunu tik atalım. 

6- Tür olarak "Linux", Versiyon olarak "Ubuntu (64-bit)" seçili "İleri" butonuna tıklayın.

7- Sanal makine için uygun bir RAM miktarı belirleyin (örneğin, 2048 MB).

8- Sanal makine için uygun bir CPU miktarı belirleyin (örneğin, 4 MB). Daha sonra "İleri" butonuna tıklayın.

9- Sanal makine için uygun bir Sanal Sabit Disk alananı belirleyin (örneğin, 25 GB) "İleri" ve ardından "bitir" butonuna tıklayın. 

10- "Başlat" butonuna bastığımızda VM kuruluma başlamış oluruz. "Göster" seçeneğine tıklayabiliriz.

    - dil seçimini "English"yapıyoruz 
    - "Keyboard configuration" sayfasında" "Identify keyboard" seçtip yönergeleri takip ediyoruz. klavye algılaması için
    - "choose the type of istallation" sayfasında "ubuntu server" seçiyoruz
    - "Network configuration" sayfasında  bir değişkliğe gerek yok
    - "Proxy configuration" sayfası bir değişkliğe gerek yok
    - "Ubuntu archive mirror configuration" sayfasında "This mirror location passed test" (Bu ayna konumu testi geçti) mesajı çıkar devam edebiliriz
    - "Guided storage configuration" sayfasında 25 GB alanı kullanacağız devam diyoruz
    - "storage configuration" sayfasınada devam diyoruz. özet var
    - "profile configuration" sayfasını dolduruyoruz
    - "upgrate to ubuntu pro" sayfasında devam diyoruz.
    - "ssh configuration" sayfasında  "openSSH" yüklüyoruz
    - "Featured Server Snap" sayfası birşey seçmeden devam
    - "Installing system" kuruluyor
    - "Reboot Now" diyerek yeniden başlatıyoruz.
    - Gelen ekranda hatalar önemli değil Enter diyerek geçiyoruz
  
# Bu adımlar ile aynı şekilde bir tane daha Ubuntu 24.04 makine ayağa kaldırıyoruz.

  "Kurulum yaklaşık 10 dk sürüyor"

11- Makineyi kapatıp üzerinde sağ tıklayarak "ayarlar" seçeneğini açıyoruz.

12- Ayarlarda "Ağ" bölümüne gelip "Bağdaştırıcı 1"e "Köprü Bağdaştırıcısı" seçiyoruz.

13- Makineyi tekrar çalıştırıyoruz. kullanıcı adı ve şifre ile giriş yapıyoruz

 ````sh
 ip a
 ````

komutun çıktısında 2. kısımda "inet" ile başlayan satırda ip adresi var onu alıp lokal makinemizde ssh bağlantısı için kullanacağız


2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic noprefixroute eth0
       valid_lft 3587sec preferred_lft 3587sec
    inet6 fe80::f816:3eff:fe82:8fd5/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever


## Ana makinemizde PowerShell'de SSH ayarları için:

1- Windows tuşuna basarak veya sol alt köşedeki Windows simgesine tıklayarak Başlat menüsünü açın.

2- Arama çubuğuna PowerShell yazın.

3- Windows PowerShell veya Windows PowerShell (x86) üzerinde sağ tıklayın ve Yönetici olarak çalıştır seçeneğini seçin.

4- PowerShell'de aşağıdaki komutları çalıştırarak OpenSSH'nin yüklenip yüklenmediğini kontrol edin:
````sh
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'
````
Çıktı şu şekilde olmalıdır:

Name  : OpenSSH.Client~~~~0.0.1.0
State : Installed
Name  : OpenSSH.Server~~~~0.0.1.0
State : Installed


5- Eğer yukarıdaki komutlar herhangi bir sonuç vermezse veya State "Not Present" ise, OpenSSH'yi yüklemek için aşağıdaki komutları kullanın:

````sh
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
````
6- ssh-agent hizmetinin otomatik olarak başlamasını ve çalışmasını sağlamak için:

````sh
Set-Service -Name ssh-agent -StartupType Automatic
Start-Service -Name ssh-agent
````

7- sshd hizmetinin otomatik olarak başlamasını ve çalışmasını sağlamak için:

````sh
Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd
````

8- ssh-agent ve sshd hizmetlerinin durumunu kontrol etmek için:

````sh
Get-Service -Name ssh-agent, sshd
````
Çıktı şu şekilde olmalıdır:

Status   Name               DisplayName
------   ----               -----------
Running  ssh-agent          OpenSSH Authentication Agent
Running  sshd               OpenSSH SSH Server

9- Vscode'u yönetici modunda açmak için "Başlat" kısmında vscode'u bularak üzerine sağ tıklayıp yönetici modunda açıyoruz daha sonra: 

````sh
ssh deploy@192.168.1.100
````

bu komutu kullanarak, gelen ekranda şifremizi girerek virtualbox ile oluşturduğumuz sanal makineye ssh ile bağlanmış oluruz.





## Güvenlik yapılandırmaları

1- 
````sh
 sudo ufw status
````
Ubuntu üzerindeki Uncomplicated Firewall (ufw) durumunu kontrol ettiğinizde "inactive" (etkisiz) olduğunu gösterir. Bu durum, Ubuntu üzerinde varsayılan olarak kurulu gelen bir güvenlik duvarı yöneticisi olan ufw'nin etkin olmadığı anlamına gelir.

2- 
````sh
sudo ufw enable
````

3-  port açmak için:
````sh
sudo ufw allow 443
sudo ufw allow 22
# portları görmek için:
sudo ufw status numbered
# portları silmek istersek:
sudo ufw delete 1
````

### Self-Signed Sertifika ile Jenkins'e SSL Kurulumu

1- OpenSSL'in yüklü olduğundan emin olun.
````sh
sudo apt update
sudo apt install openssl
````

2- Self-signed sertifikayı oluşturmak için aşağıdaki komutları kullanın

````sh
sudo mkdir /etc/ssl/private  #"File exists" diyebilir devam edebiliriz.
sudo openssl req -newkey rsa:2048 -nodes -keyout /etc/ssl/private/jenkins.key -x509 -days 365 -out /etc/ssl/private/jenkins.crt
````

Bu komutun çıktısı (doldurmamız gereken yerler):


You are about to be asked to enter information that will be incorporated    
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN. 
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:TR
State or Province Name (full name) [Some-State]:İzmir
Locality Name (eg, city) []:İzmir
Organization Name (eg, company) [Internet Widgits Pty Ltd]:MyCompany
Organizational Unit Name (eg, section) []:IT Department
Common Name (e.g. server FQDN or YOUR name) []:jenkins.mecitdevops.com
Email Address []:mecit@mycompany.com


3- Keystore Dosyası Oluşturma:
 ````sh
openssl pkcs12 -export -in /etc/ssl/private/jenkins.crt -inkey /etc/ssl/private/jenkins.key -out /etc/ssl/private/jenkins.p12 -name jenkins -password pass:s3cR3tPa55w0rD

````
Bu komut, sertifika ve anahtarı içeren bir PKCS#12 dosyası (jenkins.p12) oluşturur.


4- Java Keystore Dosyası Oluşturma:

````sh
sudo keytool -importkeystore -deststorepass s3cR3tPa55w0rD -destkeypass s3cR3tPa55w0rD -destkeystore /etc/ssl/private/jenkins.jks -srckeystore /etc/ssl/private/jenkins.p12 -srcstoretype PKCS12 -srcstorepass s3cR3tPa55w0rD -alias jenkins
````
Oluşturduğumuz Özel Anahtar dosyasını Java KeyStore dosyasına dönüştürmek için keytool komutunu kullanıyoruz:
Bu komut, jenkins.p12 dosyasını alır ve bir Java Keystore dosyası (jenkins.jks) oluşturur.

Java KeyStore (JKS) dosyası, Jenkins gibi uygulamaların HTTPS üzerinden güvenli iletişim kurabilmesi için gerekli olan SSL/TLS sertifikalarını ve özel anahtarları depolamak ve yönetmek için kullanılır. 


5- izinlerin ayarlanması:

````sh
sudo ls -al /etc/ssl/private
sudo chown jenkins:jenkins /etc/ssl/private/jenkins.jks
sudo chmod 644 /etc/ssl/private/jenkins.jks  
````


6- Jenkins'in SSL kullanacak şekilde yapılandırılması için, Jenkins konfigürasyon dosyasını düzenlememiz gerekiyor. 

Bu dosyayı bulmak için:

```sh 
sudo systemctl status jenkins
```
bu kmutun çıktısında yapılandırma dosyasının yeri var aşağıdaki gibi görünür:

"  Loaded: loaded (/usr/lib/systemd/system/jenkins.service; enabled; preset: enabled)  "

Bu dosyanın içeriğini okumak için:

````sh
sudo nano /usr/lib/systemd/system/jenkins.service
````

Bu dosyanın içinde değiştirmemiz gereken yerleri aşağıdaki gibi değiştirebiliriz:

````sh
[Unit]
Description=Jenkins Continuous Integration Server
Requires=network.target
After=network.target

[Service]
Type=notify
NotifyAccess=main
ExecStart=/usr/bin/jenkins
Restart=on-failure
SuccessExitStatus=143



User=jenkins
Group=jenkins


Environment="JENKINS_HOME=/var/lib/jenkins"
WorkingDirectory=/var/lib/jenkins


Environment="JENKINS_WEBROOT=%C/jenkins/war"



Environment="JAVA_OPTS=-Djava.awt.headless=true"


Environment="JENKINS_PORT=-1"


Environment="JENKINS_HTTPS_PORT=443"


Environment="JENKINS_HTTPS_KEYSTORE=/etc/ssl/private/jenkins.jks"


Environment="JENKINS_HTTPS_KEYSTORE_PASSWORD=s3cR3tPa55w0rD"


AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
````

Bu dosyaya göre 443 portu hariç diğer portlar engellenmiş oluyor.


````sh
sudo systemctl daemon-reload
sudo systemctl restart jenkins
````

Jenkins hizmetinin başarılı bir şekilde çalıştığından emin olmak için hizmetin durumunu kontrol edin:

````sh
sudo systemctl status jenkins
````

7- Jenkins'e bağlanma:
  
  İp öğren:

  ````sh
  ip a
  ````

   https://<ip> 



```sh
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

bu komutu jenkins serverinda girerek gelen şifreyi tarayıcıda ilgili yere yazıyoruz ve jenkins'e giriyoruz.

Gelen ekranda **Install suggested plugins** e tıklayarak devam ediyoruz.

**Create First Admin User** sayfasında yeni kullanıcı adı ve şifre belirlip başlatma işlemini bitiriyoruz.



# Jenkins Server'a Docker kurulumu:

Jenkins'in kurulu olduğu makinede docker komutları kullanacağımız için docker kuruyoruz:

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

# Docker'ın kurulumunu ve sürümünü kontrol edin
docker --version

echo "Docker başarıyla kuruldu ve yapılandırıldı."

# Oturumu yeniden yükle
newgrp docker
```

Yetkilendirme

````sh
ls -al
sudo chmod 744 docker.sh
````

docker.sh dosyasını çalıştırıyoruz

````sh
bash ./docker.sh
#Docker grubunda jenkins oluduğunu kontrol et:
getent group docker
````



# Jenkinse bağlanarak gerekli eklentilerin yüklenmesi için:

1- Jenkins dashboard'una gidin.

2- Sol taraftaki menüden "Jenkins'i Yönet" seçeneğine tıklayın.

3- "Eklentiler" tıklayın

4- "Yüklenebilecek eklentiler" bölümünden **Docker** , **Docker Pipeline** eklentilerini yükleyin.



## GitHub'ta webhooks ayarlamak için:

1- Jenkins'e dış dünyadan erişilebilir olmasını sağlamak için Ngrok kullandım.

Ngrok'u indirmek için:
````sh
sudo snap install ngrok
````

Ngrok Authtoken Ayarlama için:

- Ngrok'un resmi web sitesi olan [ngrok.com](https://ngrok.com/) adresine gidin.
- Üst menüde bulunan "Sign Up" veya "Login" seçeneklerinden birini seçin.
- Yeni Hesap Oluşturma: Eğer daha önce Ngrok hesabı oluşturmadıysanız, "Sign Up" seçeneğini seçin ve gerekli bilgileri girerek hesap oluşturun.
- Varolan Hesaba Giriş Yapma: Eğer zaten bir hesabınız varsa, "Login" seçeneğini seçin ve kullanıcı adı ve şifrenizle giriş yapın.
- Sol menüden "Getting Started" altındaki "Your Authtoken" a tıklayın.
- Bu sayfada üst ortada kişisel authtokenınızı kopyalayıp aşağıdaki komutta kullanınız.
  
````sh
ngrok config add-authtoken <YOUR_AUTHTOKEN_HERE>
````

Ngrok'u 443 portu için çalıştırmak için:
````sh
ngrok http 443
````

çıktısı aşağıdaki gibi olacak:

````sh
ngrok                                                                                                                                                          (Ctrl+C to quit)                                                                                                                                                                               Help shape K8s Bindings https://ngrok.com/new-features-update?ref=k8s                                                                                                                                                                                                                                                                                         Session Status                online                                                                                                                                           Account                       mecit.tuksoy@gmail.com (Plan: Free)                                                                                                              Update                        update available (version 3.11.0, Ctrl-U to update)                                                                                              Version                       3.10.1                                                                                                                                           Region                        Europe (eu)                                                                                                                                      Latency                       198ms                                                                                                                                            Web Interface                 http://127.0.0.1:4040                                                                                                                            Forwarding                    https://5031-2a02-4e0-2d81-1ccf-a00-27ff-fe41-3c8a.ngrok-free.app -> https://localhost:443                                                                                                                                                                                                                                      Connections                   ttl     opn     rt1     rt5     p50     p90                                                                                                      
                              1       0       0.01    0.00    32.71   32.71  
````

- Bu çıktıdaki "https://5031-2a02-4e0-2d81-1ccf-a00-27ff-fe41-3c8a.ngrok-free.app" kısmı bizim dışarıya yayın yapan url'imiz oluyor. Bunu alıp aşağıdaki işlemleri yapacağız.


1- GitHub hesabınıza giriş yapın ve ilgili repository'yi seçin.

2- Repository'nin üst kısmındaki menüden "Settings"e tıklayın.

3- Sol taraftaki menüden "Webhooks" sekmesine tıklayın.

4- "Add Webhook" butonuna tıklayın.

5- "Payload URL" alanına "https://5031-2a02-4e0-2d81-1ccf-a00-27ff-fe41-3c8a.ngrok-free.app/github-webhook/" yazın.

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



2. linüx makinede oluşturacağımız image çekip docker container çalıştıracağımız için bu makineyede docker kuruyoruz:

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

Yetkilendirme

````sh
ls -al
sudo chmod 744 docker.sh
````

Çalıştırmak içim:

```sh
bash ./docker.sh
```














































Sadece hata (error) ve uyarı (warning) loglarını görüntülemek için:

sh
Kodu kopyala
sudo journalctl -u jenkins.service -p err
sudo journalctl -u jenkins.service -p warning
journalctl -xeu jenkins.service
systemctl show jenkins
journalctl -u jenkins.service -f






Bu komutlar Jenkins'in kaldırılması ve yeniden yüklenmesi işlemlerini gerçekleştiriyor
sudo apt-get remove --purge jenkins
sudo apt-get install jenkins





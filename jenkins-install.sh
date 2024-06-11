#!/bin/bash

# Sistemi güncelleyin
sudo apt update -y


# Adoptium GPG anahtarını ve depo ekleyin
curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/keyrings/adoptium.asc
echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print $2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

# Depoları güncelleyin ve OpenJDK 17'yi kurun
sudo apt update -y
sudo apt install openjdk-17-jdk -y

# Java sürümünü kontrol edin (Gereksiz olduğunu düşünüyorsanız bu satırı kaldırabilirsiniz)
#/usr/bin/java --version

# Jenkins GPG anahtarını ve depo ekleyin
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Depoları güncelleyin ve Jenkins'i kurun
sudo apt update -y
sudo apt install jenkins -y

# Jenkins hizmetini etkinleştirin ve başlatın
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Jenkins hizmet durumunu kontrol edin
#sudo systemctl status jenkins

IP=$(curl -s ifconfig.me)
# Kurulumun başarılı olup olmadığı kontrol ediliyor
if systemctl is-active --quiet jenkins; then
    echo "Jenkins başarıyla kuruldu!"
    echo "Jenkins web arayüzüne tarayıcınızdan http://$IP:8080 adresinden erişebilirsiniz."
else
    echo "Jenkins kurulumu başarısız oldu. Lütfen hataları kontrol edin."
fi


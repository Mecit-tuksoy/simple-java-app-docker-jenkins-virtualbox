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

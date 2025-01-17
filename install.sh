#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" != "0" ]; then
  echo "Skrip ini harus dijalankan sebagai root." >&2
  exit 1
fi

# Update repository dan sistem
echo "Mengupdate repository..."
nano /etc/apt/sources.list
apt update

# Instalasi layanan dan aplikasi yang dibutuhkan
echo "Menginstal layanan dan aplikasi..."
apt install -y openssh-sftp-server apache2 mariadb-server php phpmyadmin wget unzip

# Unduh WordPress
echo "Mengunduh WordPress..."
wget http://172.16.90.2/unduh/wordpress.zip

# Ekstrak file WordPress
echo "Ekstrak WordPress..."
unzip wordpress.zip

# Pindahkan WordPress ke direktori web server
echo "Memindahkan WordPress ke direktori web server..."
mv wordpress /var/www/html/

# Ubah ke direktori web server
cd /var/www/html/wordpress || exit

# Konfigurasi database MySQL
echo "Mengonfigurasi database MySQL..."
mysql_secure_installation

# Buat database untuk WordPress
echo "Membuat database WordPress..."
mysql -u root -p <<EOF
CREATE DATABASE wordpress_db;
CREATE USER 'wordpress_user'@'localhost' IDENTIFIED BY 'password_kuat';
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF

# Konfigurasi SSH
echo "Mengonfigurasi SSH..."
nano /etc/ssh/sshd_config
service ssh restart

# Menampilkan IP server
echo "IP server adalah:"
ip a

# Selesai
echo "Proses instalasi WordPress selesai!"

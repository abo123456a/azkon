#!/bin/bash

# Skrip untuk menginstal WordPress secara otomatis

# Periksa apakah skrip dijalankan sebagai root
if [[ $EUID -ne 0 ]]; then
   echo "Skrip ini harus dijalankan sebagai root" 
   exit 1
fi

# Variabel konfigurasi
domain_name="example.com"
wp_directory="/var/www/$domain_name"
db_name="wordpress_db"
db_user="wordpress_user"
db_password="strongpassword"
db_root_password="rootpassword"

# Memperbarui dan menginstal paket yang dibutuhkan
apt update && apt upgrade -y
apt install -y apache2 mysql-server php php-mysql libapache2-mod-php wget unzip

# Konfigurasi MySQL
mysql -u root <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$db_root_password';
CREATE DATABASE $db_name;
CREATE USER '$db_user'@'localhost' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# Unduh dan ekstrak WordPress
wget https://wordpress.org/latest.zip -O /tmp/wordpress.zip
unzip /tmp/wordpress.zip -d /tmp/

# Pindahkan file WordPress ke direktori tujuan
mkdir -p $wp_directory
cp -r /tmp/wordpress/* $wp_directory
chown -R www-data:www-data $wp_directory
chmod -R 755 $wp_directory

# Buat file konfigurasi Apache
cat <<EOL > /etc/apache2/sites-available/$domain_name.conf
<VirtualHost *:80>
    ServerName $domain_name
    DocumentRoot $wp_directory

    <Directory $wp_directory>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

a2ensite $domain_name

# Aktifkan mod_rewrite dan restart Apache
a2enmod rewrite
systemctl restart apache2

# Hapus file sementara
rm -rf /tmp/wordpress /tmp/wordpress.zip

echo "Instalasi WordPress selesai. Akses situs Anda di http://$domain_name"

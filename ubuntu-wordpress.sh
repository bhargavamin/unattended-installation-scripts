#!/bin/bash -e
clear
export DEBIAN_FRONTEND="noninteractive"
echo "============================================"
echo "Installing Pre-Requistes"
echo "============================================"
sudo apt-get install -y debconf-utils apache2 libapache2-mod-auth-mysql php5-mysql php5 libapache2-mod-php5 php5-mcrypt



sudo service apache2 start
sudo service mysql start
sudo update-rc.d apache2 enable
sudo update-rc.d mysql enable


# configuring the MySQL server

echo "============================================"
echo "Installing and Configuring MySQL server"
echo "============================================"

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root@123"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root@123"
sudo apt-get install -y mysql-server

# Creating a mysql database


mysql -u root -proot@123 -e "create database wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO root@localhost IDENTIFIED BY 'root@123';FLUSH PRIVILEGES;"

echo "============================================"
echo "Installing WordPress.."
echo "============================================"

cd /var/www/html
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#change dir to wordpress
cd wordpress
#copy file to parent dir
cp -rf . ..
#move back to parent dir
cd ..
#remove files from wordpress folder
rm -R wordpress
#create wp config
cp wp-config-sample.php wp-config.php
#set database details with perl find and replace
sudo perl -pi -e "s/database_name_here/wordpressdb/g" wp-config.php
sudo perl -pi -e "s/username_here/<mysqlusername>/g" wp-config.php
sudo perl -pi -e "s/password_here/<mysqlrootpassword>/g" wp-config.php

#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php

#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads
echo "Cleaning..."
#remove zip file
rm latest.tar.gz
#remove bash script
echo "========================="
echo "Installation is complete."
echo "========================="

echo " Please note your MySQL Root password : root@123"
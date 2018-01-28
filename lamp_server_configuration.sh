#!/bin/bash

############################################################################
########################### LAMP configuration #############################
############################################################################

apache_install() {

	echo -e "\e[32m Installl Apache..."
	printf "\n"
	sudo pacman -Sy apache --noconfirm
	sudo sed -i 's/LoadModule unique_id_module modules\/mod_unique_id.so/#LoadModule unique_id_module modules\/mod_unique_id.so/' /etc/httpd/conf/httpd.conf
	printf "\n"
	echo -e "\e[34m Enabling apache service at boot..."
	printf "\n"
	sudo systemctl enable httpd
	sudo systemctl start httpd
	printf "\n"
	echo -e "\e[92m Apache installed successfully!"
	printf "\n"
}

mariadb_install() {
	echo -e "\e[32m Installing Mariadb..."
	printf "\n"
	sudo pacman -S mariadb --noconfirm
	printf "\n"
	echo -e "\e[34m Initializing Mariadb data directory..."
	printf "\n"
	sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
	printf "\n"
	echo -e "\e[34m Enabling Mariadb service at boot..."
	printf "\n"
	sudo systemctl enable mariadb.service
	sudo systemctl start mariadb.service
	printf "\n"
	echo -e "\e[33m Now carefully configure mariadb database security according to your choice..."
	printf "\n"
	sudo /usr/bin/mysql_secure_installation
	printf "\n"
	echo -e "\e[92m Mariadb installed successfully!"
	printf "\n"
}

php_install() {
	echo -e "\e[32m Installing php..."
	printf "\n"
	sudo pacman -S php php-apache --noconfirm
	printf "\n"
	echo -e "\e[34m Configuring php modules..."
	printf "\n"
	sudo sed -i 's/;extension=bz2.so/extension=bz2.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=mcrypt.so/extension=mcrypt.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=mysqli.so/extension=mysqli.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=pdo_mysql.so/extension=pdo_mysql.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=pdo_sqlite.so/extension=pdo_sqlite.so/' /etc/php/php.ini
	sudo sed -i 's/;extension=zip.so/extension=zip.so/' /etc/php/php.ini
	sudo sed -i 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/'  /etc/httpd/conf/httpd.conf
	sudo sed -i 's/^#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf/httpd.conf
	sudo sed -i '68 i\LoadModule php7_module modules/libphp7.so' /etc/httpd/conf/httpd.conf
	sudo sed -i '69 i\AddHandler php7-script php' /etc/httpd/conf/httpd.conf
	sudo sed -i '70 i\Include conf/extra/php7_module.conf' /etc/httpd/conf/httpd.conf
	printf "\n"
	sudo systemctl restart httpd
	printf "\n"
	echo -e "\e[92m php installed successfully!"
	printf "\n"
}

phpmyadmin_install() {
	echo -e "\e[32m Installing phpmyadmin..."
	printf "\n"
	sudo pacman -S php-mcrypt phpmyadmin --noconfirm
	printf "\n"
	echo -e "\e[34m Configuring phpmyadmin..."
	printf "\n"
	sudo touch /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'Alias /phpmyadmin "/usr/share/webapps/phpMyAdmin"' > /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo '<Directory "/usr/share/webapps/phpMyAdmin">' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'DirectoryIndex index.php' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'AllowOverride All' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'Options FollowSymlinks' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo 'Require all granted' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo echo '</Directory>' >> /etc/httpd/conf/extra/phpmyadmin.conf
	sudo sed -i '$a\\nInclude conf\/extra\/phpmyadmin.conf' /etc/httpd/conf/httpd.conf
	sudo sed -i '29s/cookie/config/' /etc/webapps/phpmyadmin/config.inc.php
	sudo sed -i '30 i\$cfg['Servers'][$i]['user'] = 'root';' /etc/webapps/phpmyadmin/config.inc.php
	sudo sed -i '31 i\$cfg['Servers'][$i]['password'] = '';' /etc/webapps/phpmyadmin/config.inc.php
	sudo sed -i '35s/false/true/' /etc/webapps/phpmyadmin/config.inc.php
	printf "\n"
	sudo systemctl restart httpd
	printf "\n"
	echo -e "\e[92m phpMyAdmin installed successfully!"
	printf "\n"
	echo -e "\e[92m phpMyAdmin status!"
	sudo systemctl status phpMyAdmin

	printf "\n"
}

finalize() {
	echo -e "\e[36m Finalizing..."
	printf "\n"
	sudo cp -f httpd.conf /etc/httpd/conf/httpd.conf
	sudo cp -f php.ini /etc/php/php.ini
	sudo cp -f phpmyadmin.conf /etc/httpd/conf/extra/phpmyadmin.conf
	sudo cp -f config.inc.php /etc/webapps/phpmyadmin/config.inc.php
	printf "\n"
	echo -e "\e[92m Configured successfully!"
}

 certbot-apache () {

  echo -e "Installing certbot-apache"
	printf "\n"
	sudo trize -Sy -certbot-apache --noconfirm
	sudo certbot --apache
	echo -e "\e[34m Enabling -certbot-apache servie at boot..."
	printf "\n"
	sudo systemctl enable certbot-apache
	sudo systemctl start certbot-apache
	sudo sed -i 'Include conf/extra/httpd-acme.conf' /etc/httpd/conf/httpd.conf
	printf "\n"
	echo -e "\e[92m Apache installed successfully!"
	printf "\n"

 }

 ### 5.1 PostgreSQL
+
+Install Postgresql 9.1:
+
+sud mkdir /tmp/postgresql
+    cd /tmp/postgresql
+    wget -o https://aur.archlinux.org/packages/po/postgresql-9.1/postgresql-9.1.tar.gz
+    makepkg --asroot
+   sudo  pacman -U postgres*.tar.xz
+
+    # If you get this message, accept the 'yes' resolution.
+    # :: postgresql and postgresql-libs are in conflict. Remove postgresql-libs? [y/N] y
+
+Initialize the database:
+
+   sudo mkdir /var/lib/postgres
+    sudo chown -R postgres:postgres /var/lib/postgres
+   sudo chmod -R 700 /var/lib/postgres
+    su - postgres initdb --locale en_US.UTF-8 -E UTF8 -D '/var/lib/postgres/data'
+    # return to the root user (from postgres user)
+    logout
+    systemctl start postgresql
+    systemctl enable postgresql
+
+Configure the database user and password:
+
+    su - postgres
+    psql -d template1
+    # psql (9.1.13)
+
+    template1=# CREATE USER git WITH PASSWORD 'your-password-here';
+    CREATE ROLE
+    template1=# CREATE DATABASE gitlabhq_production OWNER git;
+    CREATE DATABASE
+    template1=# \q
+
+    # return to root user (from postgres user)
+    logout

clear
echo -e "\e[36m Now installing the LAMP server..."
printf "\n"
printf "\n"
apache_install
printf "\n"
mariadb_install
printf "\n"
php_install
printf "\n"
phpmyadmin_install
printf "\n"
finalize
printf "\n"
echo -e "\e[33m phpMyAdmin installed successfully!"
sleep 2
exit

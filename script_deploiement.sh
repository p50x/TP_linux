#!/bin/bash

apt update && apt upgrade -y
apt install curl apache2 php php-mysql mariadb-server -y

conf_apache2() {
	cd /etc/apache2/sites-available
	cat << "EOF" > $site-wordpress.conf
<VirtualHost *:80>
	ServerName wordpress.$site.lan
	DocumentRoot /var/www/$site/wordpress
</VirtualHost>
EOF
	a2ensite $site-wordpress
	systemctl restart apache2
}

install_wordpress() {
	mkdir -p /var/www/$site
	cd /var/www/$site
        echo "Install wordpress v$version"
        wget https://wordpress.org/wordpress-"$version".tar.gz -O ./wordpress.tar.gz
        tar xvf wordpress.tar.gz
        cd wordpress
        sed -i "s/username_here/$user/" wp-config-sample.php
        sed -i "s/password_here/$password/" wp-config-sample.php
        sed -i "s/database_name_here/$database/" wp-config-sample.php
        cp wp-config-sample.php wp-config.php
	systemctl restart apache2
}

config_database() {

        mysql -u root << EOL
create database if not exists $site-$database;
create user if not exists $user@localhost identified by "$password";
grant all privileges on $site-$database.* to $user@localhost;
flush privileges;
EOL

}

while getopts "d:v:u:p:" option; do
  case $option in
    d) database=$OPTARG ;;      # set database name
    v) version=$OPTARG ;;       # set wordpress version
    u) user=$OPTARG ;;          # set user name
    p) password=$OPTARG ;;      # set password
    s) site=$OPTARG ;;		# set site name
    *) echo
       echo "Invalid $OPTARG option"
       exit 1 ;;
  esac
done

conf_apache2
config_database
install_wordpress


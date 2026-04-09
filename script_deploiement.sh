#!/bin/bash

set -e

apt update && apt upgrade -y
apt install curl apache2 php php-mysql mariadb-server -y

install_wordpress() {
	cd /var/www/
	echo "Install wordpress v$version"
	wget https://wordpress.org/wordpress-"$version".tar.gz -o ./wordpress.tar.gz
	tar xvf wordpress.tar.gz
	cd wordpress
	sed -i "s/username_here/$username"
	sed -i "s/password_here/$password"
	sed -i "s/database_name_here/$database"
	a2ensite wordpress
	systemctl restart apache2
}

config_database() {

	mysql -u root << EOL
create database if not exists "$database";
create user if not exists "$user"@localhost identified by "$password";
grant all privileges on "$database".* to "$user"@localhost;
flush privileges;
EOL

}

while getopts "d:v:u:p" option; do
  case $option in
    d) database=$OPTARG ;;      # set database name
    v) version=$OPTARG ;;      	# set wordpress version
    u) user=$OPTARG ;; 		# set user name
    p) password=$OPTARG ;;      # set password
    *) echo
       echo "Invalid $OPTARG option"
       exit 1 ;;
  esac
done

config_database
install_wordpress

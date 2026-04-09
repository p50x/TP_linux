#!/bin/bash

set -e

apt update && apt upgrade -y

install_wordpress() {
	cd /var/www/
	echo "Install wordpress v$1"
	wget https://wordpress.org/wordpress-$1.tar.gz
	
}


## https://nginx.org/en/linux_packages.html#Debian
## https://nginx.org/en/docs/
nginx_from_official_website_()
{
	SOURCE_FILE=/etc/apt/sources.list.d/nginx.list
	APT_PINNING_FILE=/etc/apt/preferences.d/99nginx
	SIGNING_KEY_FILE=/etc/apt/trusted.gpg.d/nginx-archive-keyring.gpg
	apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring -y
	echo "## https://nginx.org/en/linux_packages.html#Debian" > $SOURCE_FILE
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$SIGNING_KEY_FILE] https://nginx.org/packages/mainline/debian $(lsb_release -sc) nginx" >> $SOURCE_FILE
	curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee $SIGNING_KEY_FILE >/dev/null
	gpg --dry-run --quiet --import --import-options import-show $SIGNING_KEY_FILE
	echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/nginx
	apt update
	apt install -y nginx
	systemctl stop nginx
	systemctl disable nginx
}

## https://mariadb.org/download/
## https://mariadb.org/download/?t=mariadb
## MariaDB 10.x repository:
mariadb_()
{
	VERSION="10.6"
	SOURCE_FILE=/etc/apt/sources.list.d/mariadb.list
	APT_PINNING_FILE=/etc/apt/preferences.d/mariadb
	SIGNING_KEY_FILE=/etc/apt/trusted.gpg.d/mariadb-keyring.gpg
	apt install -y lsb-release dirmngr
	wget --https-only -qO- https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor | tee $SIGNING_KEY_FILE >/dev/null
	echo "## MariaDB $VERSION repository list" > $SOURCE_FILE
	echo "## https://mariadb.org/download/" >> $SOURCE_FILE
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=${SIGNING_KEY_FILE}] https://mirror.yongbok.net/mariadb/repo/$VERSION/debian $(lsb_release -sc) main #South Korea" >> $SOURCE_FILE
	echo -e "#deb-src\t[arch=$(dpkg --print-architecture) signed-by=${SIGNING_KEY_FILE}] https://mirror.yongbok.net/mariadb/repo/$VERSION/debian $(lsb_release -sc) main #South Korea" >> $SOURCE_FILE
	echo -e "Package: *\nPin: origin mirror.mva-n.net\nPin-Priority: 900" > $APT_PINNING_FILE
	#apt update
	#apt install -y mariadb-server
	#systemctl stop mariadb && systemctl disable mariadb
}

php_()
{
	VERSION_=7.4
	apt install -y php$VERSION_-fpm php$VERSION_-mysql
	systemctl stop php$VERSION_-fpm.service
	systemctl disable php$VERSION_-fpm.service
}

lemp_()
{
	## https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10

	nginx_from_official_website_
	mariadb_
	php_
}

lemp_

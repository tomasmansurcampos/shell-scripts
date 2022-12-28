## https://nginx.org/en/linux_packages.html#Debian
## https://nginx.org/en/docs/
nginx_()
{
	SOURCE_FILE=/etc/apt/sources.list.d/nginx.list
	APT_PINNING_FILE=/etc/apt/preferences.d/99nginx
	SIGNING_KEY_FILE=/etc/apt/trusted.gpg.d/nginx-archive-keyring.gpg
	apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$SIGNING_KEY_FILE] http://nginx.org/packages/mainline/debian $(lsb_release -sc) nginx" > $SOURCE_FILE
	curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee $SIGNING_KEY_FILE >/dev/null
	gpg --dry-run --quiet --import --import-options import-show $SIGNING_KEY_FILE
	echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | tee /etc/apt/preferences.d/nginx
	apt update
	apt install -y nginx
	systemctl stop nginx
	systemctl disable nginx
}

mariadb_()
{
	VERSION_=10.6
	SIGNING_KEY_FILE_=/etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc
	curl -o $SIGNING_KEY_FILE_ 'https://mariadb.org/mariadb_release_signing_key.asc'
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$SIGNING_KEY_FILE_] http://dlm.mariadb.com/repo/mariadb-server/$VERSION_/repo/debian $(lsb_release -sc) main" > /etc/apt/sources.list.d/mariadb.list
	apt update
	apt install -y mariadb-server
	systemctl stop mariadb.service
	systemctl disable mariadb.service
}

php_()
{
	apt install -y php-fpm php-mysql
	PHP_VERSION_=$(/usr/bin/apt show php-fpm | awk '/Depends: /{print $2}')
	systemctl stop $PHP_VERSION_.service
	systemctl disable $PHP_VERSION_.service
}

php_sury_()
{
	SIGNING_KEY_FILE_=/etc/apt/trusted.gpg.d/php.gpg
	wget -O $SIGNING_KEY_FILE_ https://packages.sury.org/php/apt.gpg
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$SIGNING_KEY_FILE_] http://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
	apt update
	apt install -y php-fpm php-mysql
	PHP_VERSION_=$(apt show php-fpm | awk '/Depends: /{print $2}')
	systemctl stop $PHP_VERSION_.service
	systemctl disable $PHP_VERSION_.service
}

lemp_()
{
	nginx_
	mariadb_
	php_
}

lemp_

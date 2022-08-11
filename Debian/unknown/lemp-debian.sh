## https://nginx.org/en/linux_packages.html#Debian
## https://nginx.org/en/docs/
nginx_()
{
	apt install -y nginx-light
	systemctl stop nginx.service
	systemctl disable nginx.service
}
mariadb_()
{
	apt install mariadb-server
	##systemctl stop mariadb && systemctl disable mariadb
}

php_()
{
	apt install php-fpm php-mysql
	systemctl stop php7.4-fpm.service
	systemctl disable php7.4-fpm.service
}

lemp_()
{
	## https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-10
	apt update
	nginx_
	mariadb_
	php_
}

lemp_

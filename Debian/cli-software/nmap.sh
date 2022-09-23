## https://nmap.org/download.html
## https://nmap.org/book/inst-source.html
nmap_()
{
	NMAP_VERSION_=7.93
	PWD_=$(pwd)
	DIR_="/usr/local/src/nmap*"
	if [[ $(wget -q --spider https://nmap.org/dist/nmap-$NMAP_VERSION_.tar.bz2) -eq "0" ]]; then
		if [ -d "$DIR_" ]; then
			cd /usr/local/src/nmap*
			make uninstall
		fi
		cd /usr/local/src/
		rm -rf /usr/local/src/nmap*
		apt update
		apt install -y gcc g++ openssl libssl-dev build-essential make
		cd $PWD_
		/usr/bin/wget --https-only https://nmap.org/dist/nmap-$NMAP_VERSION_.tar.bz2
		bzip2 -cd ./nmap-$NMAP_VERSION_.tar.bz2 | tar xf -
		mv nmap-$NMAP_VERSION_ /usr/local/src/
		rm -rf nmap-$NMAP_VERSION_.tar.bz2
		cd /usr/local/src/nmap-$NMAP_VERSION_
		./configure --without-zenmap
		make -j $(expr $(nproc) - 1)
		make install
	else
		echo "Nmap source code 404."
	fi
	cd $PWD_
}
nmap_

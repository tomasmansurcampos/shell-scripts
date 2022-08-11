## https://nmap.org/download.html
## https://nmap.org/book/inst-source.html
nmap_from_source_code_()
{
	VERSION_="7.92"
	PWD_=$(pwd)
	mkdir --parents /root/.src/
	cd /root/.src/nmap*
	make uninstall
	cd /root/.src/
	rm -rf /root/.src/nmap*
	apt update
	apt install -y gcc g++ openssl libssl-dev build-essential make
	wget --https-only https://nmap.org/dist/nmap-${NMAP_VERSION}.tar.bz2
	mkdir --parents /root/.src
	tar -C /root/.src -xf nmap-${NMAP_VERSION}.tar.bz2
	rm -rf nmap-${NMAP_VERSION}.tar.bz2
	cd /root/.src/nmap-${NMAP_VERSION}
	./configure
	make -j $(expr $(nproc) - 1)
	make install
	cd $PWD
}
nmap_from_source_code_

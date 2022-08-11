## https://support.torproject.org/apt/tor-deb-repo/
## http://rzuwtpc4wb3xdzrj3yeajsvm3fkq4vbeubm2tdxaqruzzzgs5dwemlad.onion/apt/tor-deb-repo/index.html
tor_()
{
	## Debian:
	## https://support.torproject.org/apt/
	## http://rzuwtpc4wb3xdzrj3yeajsvm3fkq4vbeubm2tdxaqruzzzgs5dwemlad.onion/apt

	## Source code:
	## https://www.torproject.org/download/tor/
	## http://2gzyxa5ihm7nsggfxnu52rck2vv4rvmdlkiu3zzui5du4xyclen53wid.onion/download/tor/index.html

	## Hidden services links:
	## onion.torproject.org
	## http://xao2lxsmia2edq2n5zxg6uahx6xox2t7bfjw6b5vdzsxi7ezmqob6qid.onion/

	## http://xmrhfasfg5suueegrnc4gsgyi2tyclcy5oz7f5drnrodmdtob6t2ioyd.onion/relay/setup/

	CONFIG_FILE=/etc/tor/torrc
	SOURCE_LIST_FILE=/etc/apt/sources.list.d/tor.list
	APT_PINNING_FILE=/etc/apt/preferences.d/tor
	SIGNING_KEY_FILE=/etc/apt/trusted.gpg.d/tor-archive-keyring.gpg
	apt update
	apt install lsb-release wget gnupg -y
	echo "## https://support.torproject.org/apt/" > $SOURCE_LIST_FILE
	echo "## http://rzuwtpc4wb3xdzrj3yeajsvm3fkq4vbeubm2tdxaqruzzzgs5dwemlad.onion/apt" >> $SOURCE_LIST_FILE
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$SIGNING_KEY_FILE] http://deb.torproject.org/torproject.org $(lsb_release -sc) main" > $SOURCE_LIST_FILE
	wget --https-only -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee $SIGNING_KEY_FILE >/dev/null
	#echo -e "Package: *\nPin: origin deb.torproject.org\nPin-Priority: 900" > $APT_PINNING_FILE
	#echo -e "Package: *\nPin: origin apow7mjfryruh65chtdydfmqfpj5btws7nbocgtaovhvezgccyjazpqd.onion\nPin-Priority: 900" > $APT_PINNING_FILE-hidden-service
	apt update
	apt install -y deb.torproject.org-keyring
	apt install -y tor
	systemctl stop tor
	cp $CONFIG_FILE $CONFIG_FILE.original
	echo -e "SocksPort\t127.0.0.3:9050" > $CONFIG_FILE
	echo -e "#DNSPort\t127.0.0.3:53" >> $CONFIG_FILE
	echo -e "Log\tnotice file /var/log/tor/log" >> $CONFIG_FILE
	echo "#!/bin/sh
systemctl stop tor
rm -f /var/log/tor/log
systemctl restart tor
" > /sbin/start-tor
	chmod +x /sbin/start-tor
	echo "#!/bin/sh
systemctl stop tor
" > /sbin/stop-tor
	chmod +x /sbin/stop-tor
	systemctl disable tor
	#/sbin/start-tor
}
tor_

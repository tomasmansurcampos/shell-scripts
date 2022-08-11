#!/bin/bash

### if you don't use Debian you are gay.

## https://www.server-world.info/en/note?os=Debian_11
## https://www.linuxcapable.com/category/debian/
## https://www.digitalocean.com/community/tags/debian-10
## 

## some reference:
## https://stackoverflow.com/questions/6212219/passing-parameters-to-a-bash-function

##check architecture system type:
check_arch_()
{
	if [ "$ARCHITECTURE" = "amd64" ]; then
		echo "OK: computer system architecture is $ARCHITECTURE."
	else
		CONTINUE=0
		echo "ERROR: computer system architecture is not amd64."
		echo -e "\tcomputer system architecture is $ARCHITECTURE"
	fi
}

##check debian release codename:
check_debian_codename_()
{
	if [ "$DEB_CODENAME" = "bullseye" ]; then
		echo "OK: debian distribution is $DEB_CODENAME."
	elif [ "$DEB_CODENAME" = "buster" ]; then
		echo "OK: debian distribution is $DEB_CODENAME."
	else
		CONTINUE=0
		echo "ERROR: debian distribution codename is not bullseye nor buster."
		echo -e "\tdebian distribution codename is $DEB_CODENAME"
	fi
}

##check if debian has systemd init:
check_systemd_()
{
	if [[ $INIT_SYSTEM == *"systemd"* ]]; then
		echo "OK: init system is systemd."
	else
		CONTINUE=0
		echo "ERROR: init system is not systemd."
	fi
}

##leave:
leave_()
{
	echo -e "\nleaving..."
	exit 2
}

##check arch, codename and systemd:
initial_checking_()
{
	if [ $"command -v cat" == 1 ]
	then
    	echo "something weird is happening here."
		leave_
	fi
	if [ $"cat /etc/os-release | grep debian" == 1 ]
	then
    	echo "this is not a debian system."
		leave_
	fi
	export CONTINUE=1
	export ARCHITECTURE=$(dpkg --print-architecture)
	export DEB_CODENAME=$(lsb_release -sc)
	export INIT_SYSTEM=$(readlink /sbin/init)


	check_arch_
	check_debian_codename_
	check_systemd_

	echo ""

	##if something above hasn't true condition:
	if [ "$CONTINUE" = "0" ]; then
		leave_
	fi
}



ntp_config_()
{
	## reference of configuration:
	## https://wiki.archlinux.org/title/Systemd-timesyncd
	CONFIG_FILE=/etc/systemd/timesyncd.conf
	if [ "$CONFIG_FILE" = "0" ]; then
		cp $CONFIG_FILE $CONFIG_FILE.original
		sed -i '/#NTP=/!b;cNTP=216.239.35.0 216.239.35.4 216.239.35.8 216.239.35.12 162.159.200.1 162.159.200.123' $CONFIG_FILE
		sed -i '/FallbackNTP/!b;cFallbackNTP=time.google.com time1.google.com time2.google.com time3.google.com time.apple.com time.windows.com 0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org' $CONFIG_FILE
		#sed -i s/#RootDistanceMaxSec/RootDistanceMaxSec/g $CONFIG_FILE
		#sed -i s/#PollIntervalMinSec/PollIntervalMinSec/g $CONFIG_FILE
		#sed -i s/#PollIntervalMaxSec/PollIntervalMaxSec/g $CONFIG_FILE
		systemctl daemon-reload
		systemctl restart systemd-timesyncd
		sleep 10
		systemctl stop systemd-timesyncd
		systemctl disable systemd-timesyncd
	fi
}

check_path_()
{
	if [ -d "/sbin" ]; then
		#echo "export PATH=$PATH:/sbin" >> /root/.bashrc 
	fi
	if [ -d "/usr/sbin" ]; then
		#echo "export PATH=$PATH:/usr/sbin" >> /root/.bashrc 
	fi
	if [ -d "/usr/local/sbin" ]; then
		#echo "export PATH=$PATH:/usr/local/sbin" >> /root/.bashrc 
	fi
	echo "export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin" >> /root/.bashrc && source /root/.bashrc
}

official_debian_sources_list_()
{
	FILE=/etc/apt/sources.list
	cp $FILE $FILE.original
	if [ "$(lsb_release -sr)" = "11" ]; then
		echo -e "deb\thttps://deb.debian.org/debian\t$(lsb_release -sc) main contrib non-free
deb\thttps://security.debian.org/debian-security/\t$(lsb_release -sc)-security main contrib non-free
deb\thttps://deb.debian.org/debian\t$(lsb_release -sc)-updates main contrib non-free" > $FILE
	elif [ "$(lsb_release -sr)" = "10" ]; then
		echo -e "deb\thttps://deb.debian.org/debian/\tbuster main contrib non-free
deb\thttps://deb.debian.org/debian/\tbuster-updates main contrib non-free
deb\thttps://security.debian.org/debian-security\tbuster/updates main contrib non-free" > $FILE
	fi
}

apt_trough_local_tor_socks5_proxy_()
{
	## you don't need apt-transport-tor...
	## you need this:
	APT_TOR_PROXY_CONFIG_FILE_=/etc/apt/apt.conf.d/tor-proxy
	echo 'Acquire::http::Proxy "socks5h://127.0.0.1:9040";' > $APT_TOR_PROXY_CONFIG_FILE_
	echo 'Acquire::https::Proxy "socks5h://127.0.0.1:9040";' >> $APT_TOR_PROXY_CONFIG_FILE_
}

debian_http_repositories_to_debian_hidden_services_repositories_()
{
	SCRIPT_FILE=/sbin/debian_http_repositories_to_debian_hidden_services_repositories.sh
	echo '#!/bin/sh
FILE=/etc/apt/sources.list
sed -i s/https/http/g $FILE
sed -i s/deb.debian.org/2s4yqjx5ul6okpp3f2gaunr2syex5jgbfpfvhxxbbjwnrsvbk5v3qbid.onion/g $FILE
sed -i s/security.debian.org/5ajw6aqf3ep7sijnscdzw77t7xq4xjpsy335yb2wiwgouo7yfxtjlmid.onion/g $FILE' > $SCRIPT_FILE
	#bash $SCRIPT_FILE
}

debian_hidden_services_repositories_to_debian_http_repositories_()
{
	SCRIPT_FILE=/sbin/debian_hidden_services_repositories_to_debian_http_repositories.sh
	echo '#!/bin/sh
FILE=/etc/apt/sources.list
sed -i s/2s4yqjx5ul6okpp3f2gaunr2syex5jgbfpfvhxxbbjwnrsvbk5v3qbid.onion/deb.debian.org/g $FILE
sed -i s/5ajw6aqf3ep7sijnscdzw77t7xq4xjpsy335yb2wiwgouo7yfxtjlmid.onion/security.debian.org/g $FILE
sed -i s/https/http/g $FILE
sed -i s/http/https/g $FILE' > /sbin/debian_hidden_services_repositories_to_debian_http_repositories.sh
	#bash $SCRIPT_FILE
}

tor_http_repository_to_tor_hidden_services_repository()
{
	SCRIPT_FILE=/sbin/tor_http_repository_to_tor_hidden_services_repository.sh
	echo '#!/bin/sh
FILE=/etc/apt/sources.list.d/tor.list
sed -i s/https/http/g $FILE
sed -i s/deb.torproject.org/apow7mjfryruh65chtdydfmqfpj5btws7nbocgtaovhvezgccyjazpqd.onion/g $FILE' > $SCRIPT_FILE
	#bash $SCRIPT_FILE
}

tor_hidden_services_repository_to_http_repository()
{
	SCRIPT_FILE=/sbin/tor_hidden_services_repository_to_http_repository.sh
	echo '#!/bin/sh
FILE=/etc/apt/sources.list.d/tor.list
sed -i s/https/http/g $FILE
sed -i s/http/https/g $FILE
sed -i s/apow7mjfryruh65chtdydfmqfpj5btws7nbocgtaovhvezgccyjazpqd.onion/deb.torproject.org/g $FILE' > $SCRIPT_FILE
	#bash $SCRIPT_FILE
}

## https://github.com/DNSCrypt/dnscrypt-proxy
dnscrypt_proxy_from_github_()
{
	VERSION=2.1.1
	## architecture checker
	if [ "$(uname -m)" = "x86_64" ]; then
		ARCH_=x86_64
	elif [ "$(uname -m)" = "i386" ]; then
		ARCH_=i386
	elif [ "$(uname -m)" = "mips" ]; then
		ARCH_=mips
	elif [ "$(uname -m)" = "aarch64" ]; then
		ARCH_=arm64
	fi
	## os checker
	fi [ "$(uname -s)" = "Linux" ]; then
		OS_=linux
	elif [ "$(uname -s)" = "OpenBSD" ]; then
		OS_=openbsd
	elif [ "$(uname -s)" = "FreeBSD" ]; then
		OS_=freebsd
	elif [ "$(uname -s)" = "NetBSD" ]; then
		OS_=netbsd
	fi
	LINK=https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${VERSION}/dnscrypt-proxy-linux_$ARCH_-${VERSION}.tar.gz
	BASE_FOLDER=/opt/software
	LOGS_FOLDER=/var/log/dnscrypt-proxy

	## removing other dns servers
	apt --purge autoremove -y dnsmasq unbound bind9 dnscrypt-proxy
	systemctl stop systemd-resolved && systemctl disable systemd-resolved

	torsocks --port 9040 wget -q --https-only $LINK
	tar -xf dnscrypt-proxy-linux_$ARCH_-${VERSION}.tar.gz --directory .
	mv linux-$ARCH_ $BASE_FOLDER/dnscrypt-proxy
	echo "listen_addresses = ['0.0.0.0:53']
max_clients = 1000000 ## up to 1M request per second.
ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = false
odoh_servers = false
require_dnssec = true
require_nolog = true
require_nofilter = true
force_tcp = false
#proxy = 'socks5://127.0.0.1:9040' ## adjust the port!
timeout = 5000
keepalive = 30
cert_refresh_delay = 240
tls_disable_session_tickets = false
bootstrap_resolvers = ['127.0.0.1:1053']##['8.8.8.8:53','8.8.4.4:53']
ignore_system_dns = true
#netprobe_timeout = 60
#netprobe_address = '9.9.9.9:53'
block_ipv6 = true
block_unqualified = true
block_undelegated = true
reject_ttl = 10
forwarding_rules = 'forwarding-rules.txt'
cache = false

[captive_portals]

[local_doh]

[query_log]
	file = '/var/log/dnscrypt-proxy/query.log'
	format = 'tsv'

[nx_log]
	file = '/var/log/dnscrypt-proxy/nx.log'
	format = 'tsv'

[blocked_names]
	blocked_names_file = '/opt/software/dnscrypt-proxy/blocked-names.txt'
	log_file = '/var/log/dnscrypt-proxy/blocked-names.log'
	log_format = 'tsv'

[blocked_ips]

[allowed_names]

[allowed_ips]

[schedules]

[sources]
  ## An example of a remote source from https://github.com/DNSCrypt/dnscrypt-resolvers
  [sources.'public-resolvers']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://download.dnscrypt.net/resolvers-list/v3/public-resolvers.md']
    cache_file = 'public-resolvers.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''

  ## Anonymized DNS relays

  [sources.'relays']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md', 'https://download.dnscrypt.info/resolvers-list/v3/relays.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/relays.md', 'https://download.dnscrypt.net/resolvers-list/v3/relays.md']
    cache_file = 'relays.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''

[broken_implementations]
fragments_blocked = ['cisco', 'cisco-ipv6', 'cisco-familyshield', 'cisco-familyshield-ipv6', 'cleanbrowsing-adult', 'cleanbrowsing-adult-ipv6', 'cleanbrowsing-family', 'cleanbrowsing-family-ipv6', 'cleanbrowsing-security', 'cleanbrowsing-security-ipv6']

[doh_client_x509_auth]

[anonymized_dns]

skip_incompatible = false

[dns64]

[static]

  # [static.'myserver']
  # stamp = 'sdns://AQcAAAAAAAAAAAAQMi5kbnNjcnlwdC1jZXJ0Lg'" > $BASE_FOLDER/dnscrypt-proxy/dnscrypt-proxy.toml
	echo "*.local
*.lan
eth0.me
*.workgroup
fibertel.com.ar
*fibertel.com.ar" > $BASE_FOLDER/dnscrypt-proxy/blocked-names.txt
	echo "localhost	127.0.0.1
localhost ip6-localhost ip6-loopback	::1
ip6-allnodes	ff02::1
ip6-allrouters	ff02::2" > $BASE_FOLDER/dnscrypt-proxy/forwarding-rules.txt
	mkdir --parents $LOGS_FOLDER
	chown -R user:user $BASE_FOLDER/dnscrypt-proxy/
	cd $BASE_FOLDER/dnscrypt-proxy/
	$BASE_FOLDER/dnscrypt-proxy/dnscrypt-proxy -service install
	echo "#!/bin/bash
systemctl restart dnscrypt-proxy.service" > /sbin/start-dns
	chmod +x /sbin/start-dns
	echo "#!/bin/bash
systemctl stop dnscrypt-proxy.service" > /sbin/stop-dns
	chmod +x /sbin/stop-dns
	/sbin/start-dns
	cd /tmp
}

dns_fowarding_()
{
	apt update && apt install socat -y
	## bash script:
	echo "#!/bin/sh
/usr/bin/socat -T4 UDP4-LISTEN:53,reuseaddr,fork UDP4:localhost:53
#/usr/bin/socat -T4 UDP6-LISTEN:53,reuseaddr,fork UDP6:localhost:53" > /sbin/dns-fowarding.sh
	chmod 755 /sbin/dns-fowarding.sh
	## systemd service:
	echo "[Unit]
Wants=network-online.target
After=network-online.target
Description=...

[Service]
ExecStart=bash /sbin/dns-fowarding.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/dns-fowarding.service
	systemctl daemon-reload
	systemctl stop dns-fowarding
	systemctl disable dns-fowarding
}f

static_resolv_conf_()
{
	BASH_SCRIPT_FILE_=/sbin/static-resolv-conf.sh
	SYSTEMD_SERVICE_FILE_=/etc/systemd/system/static-resolv-conf.service
	## bash script:
	echo "#!/bin/sh
chattr -i /etc/resolv.conf
echo 'nameserver 127.0.0.1' > /etc/resolv.conf
#echo 'nameserver ::1' >> /etc/resolv.conf
chattr +i /etc/resolv.conf" > $BASH_SCRIPT_FILE_
	chmod +x $BASH_SCRIPT_FILE_
	## systemd service:
	echo "[Unit]
Description=Set file /etc/resolv.conf static with particular configuration
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=bash /sbin/static-resolv-conf.sh

[Install]
WantedBy=multi-user.target" > $SYSTEMD_SERVICE_FILE_
	systemctl daemon-reload
	systemctl enable static-resolv-conf
	systemctl restart static-resolv-conf
}

python3_pip_()
{
	apt install -y python3-pip
	pip install libpcap
	pip install shodan
	pip install beautifulsoup4
	pip install lxml
	## https://scapy.readthedocs.io/en/latest/installation.html#installing-scapy-v2-x
	if [ $(uname -m) = "x86_64" ]; then
		pip install --pre scapy[complete]
	elif [ $(uname -m) = "arm64" ]; then
		pip install --pre scapy[basic] ## on arm64 there's problems with certain scapy dependencie.
	fi
}

essential_tools_()
{
	cookie_fortune_
	command_line_applications_
	lemp_

	## uncategorized
	apt update
	apt install -y rsync bzip2 htop p7zip-full p7zip-rar neofetch man man-db psmisc hello cowsay lsb-release file
	
	## developing stuff
	apt install -y nasm perl gcc gdb binutils clang git make cmake libpcap-dev libssl-dev libsystemd-dev
	echo "alias gcc-c89='gcc -std=c89 -pedantic-errors -Wall -Werror'
alias gcc-c99='gcc -std=c99 -pedantic-errors -Wall -Werror'
alias gcc-c17='gcc -std=c17 -pedantic-errors -Wall -Werror'" >> /etc/profile.d/command_alias.sh
	#apt install -y install linux-headers-$(uname -r)
	if [ $(uname -m) = "x86_64" ]; then
		apt install -y gcc-multilib
	fi
	python3_pip_
	openjdk_17_
	net_sdk_6_dot_zero_
	mono_
	nodejs_18_dot_x_
	emacs_
	
	## net stuff
	apt install -y ncat ndiff netcat-openbsd masscan putty-tools socat ethtool sipcalc dnsutils bmon whois openssh-client wget lynx tcpdump
	#libpcap_
	#tcpdump_
	nmap_from_source_code_
	weechat_
	## anti forensic tool
	#apt install secure-delete foremost -y #srm command. foremost is for file recovering
}

emacs_()
{
	## https://www.emacswiki.org/emacs/IndentingC
	apt install --no-install-recommends -y emacs-nox emacs-el ## this way avoids exim4 installation.
	if id "user" &>/dev/null; then
		CONFIG_FOLDER_=/home/user/.emacs.d
	elif id "root" &>/dev/null; then
		CONFIG_FOLDER_=/root/.emacs.d
	fi
	rm -rf $CONFIG_FOLDER_ && mkdir --parents $CONFIG_FOLDER_
	FILE_CONFIG_=$CONFIG_FOLDER_/init.el && rm -rf $FILE_CONFIG_ && touch $FILE_CONFIG_
	echo "(global-linum-mode)" > $FILE_CONFIG_
	echo '(setq c-default-style "linux"
          c-basic-offset 4)' >> $FILE_CONFIG_
}


universal_configuration_()
{
	echo 'alias a="apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt update"' >> /root/.bashrc && source /root/.bashrc
	ntp_config_
	check_path_
	tor_
	#apt_trough_local_tor_socks5_proxy_
	debian_http_repositories_to_debian_hidden_services_repositories_
	tor_http_repositories_to_tor_hidden_services_repositories_
	static_resolv_conf_
	dnscrypt_proxy_from_github_
	dns_fowarding_
}

desktop_hostname_changer()
{
	## bash script:
	echo "#!/bin/sh
STRING='DESKTOP'
head /dev/urandom > /tmp/r
R_STRING=\$(cat /tmp/r | tr -dc 'A-Z0-9' | fold -w \${1:-7} | head -n 1)
NEW_HOSTNAME=\$STRING-\$R_STRING #example: DESKTOP-A8FLM4C
OLD_HOSTNAME=\$(hostname)
hostnamectl set-hostname \$NEW_HOSTNAME
sed -i s/\$OLD_HOSTNAME/\$NEW_HOSTNAME/g /etc/hosts
rm -rf /tmp/r" > /sbin/hostname-changer.sh
	chmod u+x /sbin/hostname-changer.sh
	## systemd servcie configuration:
	echo "[Unit]
Description=Change the hostname at startup.

[Service]
ExecStart=bash /sbin/hostname-changer.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/hostname-changer.service
	systemctl daemon-reload
	systemctl enable hostname-changer
}

home_server_hostname_changer()
{
	## bash script:
	echo "#!/bin/sh
STRING='SERVER'
head /dev/urandom > /tmp/r
R_STRING=\$(cat /tmp/r | tr -dc '0-9' | fold -w \${1:-13} | head -n 1)
NEW_HOSTNAME=\$STRING-\$R_STRING #example: SERVER-2457824658356
OLD_HOSTNAME=\$(hostname)
hostnamectl set-hostname \$NEW_HOSTNAME
sed -i s/\$OLD_HOSTNAME/\$NEW_HOSTNAME/g /etc/hosts
rm -rf /tmp/r
	" > /sbin/hostname-changer
	chmod 755 /sbin/hostname-changer
	## systemd servcie configuration:
	echo "[Unit]
Description=Change the hostname at startup.

[Service]
ExecStart=bash /sbin/hostname-changer

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/hostname-changer.service
	systemctl daemon-reload
	systemctl enable hostname-changer
}

mac_address_spoofing()
{
	## Now it's time to configure permanent random mac address for every wifi adaptaer card and wired card connected to pc at boot time thanks to systemd-networkd.
	## systemd-networkd supports MAC address spoofing via link files (see systemd.link(5) for details).
	## https://wiki.archlinux.org/index.php/MAC_address_spoofing
	## mac addresses of:
	apt update
	apt install ethtool -y #this tool will get hardware mac address of device.
	INTERFACES=$(ls /sys/class/net/)
	INTERFACES=${INTERFACES/lo}
	CONFIG_FILE=/etc/systemd/network/00-default.link
	COMMAND=ethtool
	if test -f "$CONFIG_FILE"
	then
		cp $CONFIG_FILE $CONFIG_FILE.backup
	fi
	rm -rf $CONFIG_FILE
	touch $CONFIG_FILE
	if ! command -v $COMMAND &> /dev/null #Why this? In case offline configuration or apt didn't get the package, else procede with ethtool command.
	then
    	echo "ethtool software cannot be executed for some reason..."
		echo "adding mac address of local host by /sys/class/net/*/address on 00-default.link file..."
		echo -e "[Match]\n" > $CONFIG_FILE
		for i in $INTERFACES
		do
			MAC_ADDRESS=$(cat /sys/class/net/$i/address)
			echo "MACAddress=$MAC_ADDRESS" >> $CONFIG_FILE
			echo "$MAC_ADDRESS added."
		done
		echo "MACAddress=ec:08:6b:1f:80:a1 ## Atheros AR9271 150Mbps Wireless USB LAN Adapter 802.11b/g/n WiFi Card" >> $CONFIG_FILE
		echo "
[Link]
MACAddressPolicy=random
NamePolicy=kernel database onboard slot path" >> $CONFIG_FILE
	else
    	echo -e "[Match]\n" > $CONFIG_FILE
		for i in $INTERFACES
		do
			MAC_ADDRESS=$(ethtool -P $i)
			MAC_ADDRESS=${MAC_ADDRESS:19:17}
			echo "MACAddress=$MAC_ADDRESS" >> $CONFIG_FILE
		done
		## additionals mac address of my wifi cards:
		echo "MACAddress=ec:08:6b:1f:80:a1 ## Atheros AR9271 150Mbps Wireless USB LAN Adapter 802.11b/g/n WiFi Card" >> $CONFIG_FILE
		echo "
[Link]
MACAddressPolicy=random
NamePolicy=kernel database onboard slot path" >> $CONFIG_FILE
	fi
	#systemctl enable systemd-networkd
}

packages_for_desktop_()
{
	## general stuff
	apt update
	apt install lm-sensors lshw acpitool lsb-release ascii
	bleachbit_

	## gaming stuff
	## https://blends.debian.org/games/tasks/
	## see https://blends.debian.org/games/tasks/console for console games
	apt update
	apt install blastem dosbox hex-a-hop -y
	steam_

	## developing stuff
	apt install geany -y
	visual_studio_code_
	virtual_box_

	## web/net stuff
	apt update
	apt install -y qbittorrent mumble putty
	firefox_stable_
	palemoon_
	opera_web_browser_
	google_chrome_
	microsoft_edge_
	discord_
	telegram_
	google_earth_pro_
	zoom_
	signal_

	## multimedia stuff
	apt update
	apt install -y audacious vlc k3b soundconverter gimp mixxx bluez
	## https://www.codegrepper.com/code-examples/shell/Connection+Failed%3A+blueman.bluez.errors.DBusFailedError%3A+Protocol+not+available
	audacity_
	kdenlive_
	spotify_

	## CAD software and similar
	apt update
	apt install freecad kicad

	## security
	apt install -y wireshark
	keepass2_
	wasabi_bitcoin_wallet_

}

## https://www.bleachbit.org/download/linux
bleachbit_()
{
	FILE=bleachbit_4.4.2-0_all_debian$(lsb_release -sr).deb
	wget -q --https-only https://download.bleachbit.org/${FILE}
	apt install -y ./${FILE}
	rm -rf ${FILE}
}

libpcap_()
{
	VERSION=1.10.1
	torsocks --port 9040 wget -q --https-only https://www.tcpdump.org/release/libpcap-$VERSION.tar.gz
	tar -xf libpcap-$VERSION.tar.gz
	rm -f libpcap-$VERSION.tar.gz
	cd libpcap-$VERSION
	./configure
	make
	make install
}

## https://www.tcpdump.org/index.html#latest-releases
tcpdump_()
{
	VERSION=4.99.1
	torsocks --port 9040 wget -q --https-only https://www.tcpdump.org/release/tcpdump-$VERSION.tar.gz
	tar -xf tcpdump-$VERSION.tar.gz
	rm -f tcpdump-$VERSION.tar.gz
	cd tcpdump-$VERSION
}

command_line_applications_()
{
	powershell_
	#docker_
	#metasploit_framework_
	aircrack_ng_
	speedtest_install_
	youtube_dl_
	sqlmap_
}

popularity_contest_()
{
	apt install -y --no-install-recommends popularity-contest ## this evades exim4 installation, as data is sent over http.
	echo 'USETOR="yes"' >> /etc/popularity-contest.conf
}


## main function:
main_()
{
	initial_checking_
	universal_configuration_
	essential_tools_
	#desktop_hostname_changer_
	#mac_address_spoofing_
	packages_for_desktop_
}

main_
exit 0


warning_tip_message_()
{
	echo "#####################################################"
	echo "#                    WARNING                        #"
	echo "#####################################################"
	echo "# NEVER LET YOUR ISP, OR SOME [LONG RANGE] ANTENNA  #"
	echo "# LIKE THE ONE COULD BE ON ON 2G/5G TOWERS          #" 
	echo "# SNIFFING 802.x SIGNALS, KNOWS WHAT OS AND DEVICE  #"
	echo "# HARDWARE YOU ARE USING.                           #"
	echo "#####################################################"
	echo ""
	echo "#####################################################"
	echo "#                     TIPS                          #"
	echo "#####################################################"
	echo "# SPOOF MAC ADDRESS AND HOSTNAME AT EVERY BOOT.     #"
	echo "# TORIFY UPDATES AND UPGRADES OF OS AND SOFTWARE.   #"
	echo "# DISABLE NTP CLIENT OR RESOLVE NTP TROUGHT tor.    #"
	echo "# ENCRYPT DNS REQUESTS, DOH OVER TOR IS COOL.       #"
	echo "# TELEMETRY IS FINE WHILE THERE ARE ANONYMOUS AND   #"
	echo "# IS SENT TROUGHT TOR.                              #"
	echo "#####################################################"
	echo ""
	sleep 6
}

opt_software_folder_()
{
	BASE_FOLDER=/opt/software
	mkdir --parents $BASE_FOLDER
	chown -R user:user $BASE_FOLDER
	chmod 755 $BASE_FOLDER
}

locales_config_()
{
	## https://www.thomas-krenn.com/en/wiki/Perl_warning_Setting_locale_failed_in_Debian
	apt update
	apt install locales-all -y
	source /etc/default/locale
	export LANGUAGE=en_US.UTF-8
	export LANG=en_US.UTF-8
	export LC_ALL=en_US.UTF-8
	export LC_TIME=en_IN.UTF-8
	locale-gen en_US.UTF-8
	dpkg-reconfigure locales
}

mumble_server_()
{
	## https://www.spinup.com/install-mumble-on-debian-10/
	apt install mumble-server -y
	systemctl stop mumble-server
	systemctl disable mumble-server
}

disable_ipv6_()
{
	export IPV6_IS_ENABLED=1
	## via sysctl.conf:
	if [ -f /etc/sysctl.conf ]
	then
		echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
		echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
		echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
		sysctl -p
		IPV6_IS_ENABLED=0
	fi
	## via grub:
	## googled: find matching text and replace that line
	## https://stackoverflow.com/questions/18620153/find-matching-text-and-replace-next-line
	if [ -f /etc/default/grub ]
	then
		cp /etc/default/grub /etc/default/grub.original
		sed -i '/GRUB_TIMEOUT=/!b;cGRUB_TIMEOUT=1' /etc/default/grub
		sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/!b;cGRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"' /etc/default/grub
		sed -i '/GRUB_CMDLINE_LINUX=/!b;cGRUB_CMDLINE_LINUX="ipv6.disable=1"' /etc/default/grub
		update-grub
		IPV6_IS_ENABLED=0
	fi
	if [ $IPV6_IS_ENABLED -eq 1 ]; then
		echo "WARNING: Can't disable ipv6. Check why..."
	fi
}

microcode_installation()## it bugs Debian with GNOME with arp or network or something, i do not know exactly.
{
	## finally installing the appropriate microcode...
	##  https://wiki.debian.org/Microcode
	vendor_processor=$(cat /proc/cpuinfo | grep vendor | uniq)
	if [[ $vendor_processor = *"Intel"* ]]; then
		apt remove amd64-microcode -y
		apt purge amd64-microcode -y
		apt autoremove -y
		apt update
		apt install intel-microcode -y
	elif [[ $vendor_processor = *"AMD"* ]]; then
		apt remove intel-microcode -y
		apt purge intel-microcode -y
		apt autoremove -y
		apt update
		apt install amd64-microcode -y
	else
		echo "pc has no intel nor amd cpu."
	fi
}

dnsmasq_()
{
	## reference of configuration:
	## https://wiki.archlinux.org/title/Stubby#dnsmasq
	## https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby
	
	CONFIG_FILE=/etc/dnsmasq.conf

	## in case of systemd-resolved running:
	systemctl stop systemd-resolved
	systemctl disable systemd-resolved
	## dnsmasq software installation:
	apt install dnsmasq -y
	systemctl stop dnsmasq
	## dnsmasq file configuartion:
	cp $CONFIG_FILE $CONFIG_FILE.original
	echo "cache-size=0
no-resolv
proxy-dnssec
domain-needed

## DNSCrypt resolver:
server=127.0.0.1#5300
server=::1#5300

#listen-address=::1,127.0.0.1
#interface=lo
#bind-interfaces
#bogus-priv" > $CONFIG_FILE
	## editing /etc/hosts...
	##	export IP=""
	##	read -p "Direccion ip a la cual redirigir hola.com: " IP
	##	echo -e "${IP}\thola.com" >> /etc/hosts

	#restart services
	systemctl restart stubby
	systemctl enable stubby
	systemctl restart dnsmasq
	systemctl enable dnsmasq
}

no_ads_()
{
	HOSTS_FILE_=/etc/hosts
	cp $HOSTS_FILE_ $HOSTS_FILE_.original
	wget -q --https-only https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
}

stubby_()
{
	## reference of configuration:
	## https://wiki.archlinux.org/title/Stubby#dnsmasq
	## https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby
	CONFIG_FILE=/etc/stubby/stubby.yml
	apt update
	apt install stubby dnsutils -y
	systemctl stop stubby
	cp $CONFIG_FILE $CONFIG_FILE.original
	echo '## reference of configuration:
## https://wiki.archlinux.org/title/Stubby#dnsmasq
## https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby

dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 1 ## default 1.
idle_timeout: 60000 #default 5000.
tls_connection_retries: 1 ## default 2.
tls_min_version: GETDNS_TLS1_2
tls_max_version: GETDNS_TLS1_3
listen_addresses:
#  - 0::1@53000
  - 127.0.0.1@53000
#dnssec: GETDNS_EXTENSION_TRUE ## increase security and lag. disabled by default.
#appdata_dir: "/tmp/stubby"
upstream_recursive_servers:
####### IPv6 addresses #######
## Google Public DNS (IPv6):
#  - address_data: 2001:4860:4860::8888
#    tls_port: 853
#    tls_auth_name: "dns.google"
#  - address_data: 2001:4860:4860::8844
#    tls_port: 853
#    tls_auth_name: "dns.google"
####### IPv4 addresses ######
## Google Public DNS (IPv4):
  - address_data: 8.8.8.8
    tls_port: 853
    tls_auth_name: "dns.google"
  - address_data: 8.8.4.4
    tls_port: 853
    tls_auth_name: "dns.google"' > $CONFIG_FILE
	systemctl restart stubby
	systemctl enable stubby
}

get_latest_github_release_()
{
	echo '#!/bin/bash
## https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
## example 
curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
grep '"tag_name":' |                                            # Get tag line
sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
exit 0" > /sbin/get_latest_github_release
	chmod 755 /sbin/get_latest_github_release
}

freecad_()
{
	## https://www.freecadweb.org/downloads.php
	LINK="https://github.com/FreeCAD/FreeCAD/releases/download/0.19.2/FreeCAD_0.19-24291-Linux-Conda_glibc2.12-x86_64.AppImage"
	wget -q --https-only $LINK
	mv FreeCAD*.AppImage /opt/freecad.AppImage
	chmod +x /opt/freecad.AppImage
	wget -q --https-only https://upload.wikimedia.org/wikipedia/commons/thumb/f/f7/FreeCAD-logo.svg/240px-FreeCAD-logo.svg.png
	mv 240px-FreeCAD-logo.svg.png /usr/share/icons/hicolor/240x240/apps/freecad.org
	echo "
[Desktop Entry]
Name=FreeCAD
GenericName=Your own 3D parametric modeler
Exec=/opt/FreeCAD/FreeCAD_0.19-24291-Linux-Conda_glibc2.12-x86_64.AppImage
Icon=freecad
Terminal=false
Type=Application
StartupNotify=false
Categories=Utility;
MimeType=application/x-freecad;" > /usr/share/applications/freecad.desktop
}

tor_from_source_()
{
	# https://github.com/steampug/tor-service/blob/master/torrc
	# https://gist.github.com/gtank/f6a8f99c70f682cd8d4acd6a4a9ee696

	# debian-tor:x:106:112::/var/lib/tor:/bin/false

	# actually this way of install and run tor is cuasi equal to this: https://support.torproject.org/operators/packaged-tor/

	"""
Nickname hellothere
ORPort 443 IPv4Only
ExitRelay 0
ControlSocket 0
ContactInfo < moreonionsporfavor AT protonmail DOT com >
	"""

	# https://tor.stackexchange.com/questions/4587/run-tor-in-the-background-via-the-shell
	# https://wiki.parabola.nu/Tor
	# https://wiki.archlinux.org/title/Tor

	# http://xmrhfasfg5suueegrnc4gsgyi2tyclcy5oz7f5drnrodmdtob6t2ioyd.onion/relay/setup/

	#configure: Some libraries need pkg-config, including systemd, nss, lzma, zstd, and custom mallocs.
	#configure: To use those libraries, install pkg-config, and check the PKG_CONFIG_PATH environment variable.

	apt update
	apt install -y wget pkg-config libevent-dev libssl-dev zlib1g zlib1g-dev liblzma-dev libzstd-dev

	export TOR_VERSION=0.4.6.7
	# torsocks --address localhost --port 9050 wget --https-only http://scpalcwstkydpa3y7dbpkjs2dtr7zvtvdbyj3dqwkucfrwyixcl5ptqd.onion/tor-${VERSION}.tar.gz
	cd /tmp
	wget --https-only -q https://dist.torproject.org/tor-${TOR_VERSION}.tar.gz
	tar xf tor-${TOR_VERSION}.tar.gz
	cd tor-${TOR_VERSION}
	./configure
	make
	make install
	cd /tmp

	# non-root user to run tor:
	# man 8 adduser
	adduser --disabled-password --quiet --home /home/tor-service/ --gecos "" tor-service

	# allow tor binary to open ports below 1024 from a non-root user:
	# http://xmrhfasfg5suueegrnc4gsgyi2tyclcy5oz7f5drnrodmdtob6t2ioyd.onion/relay/setup/bridge/debian-ubuntu/
	setcap cap_net_bind_service=+ep /usr/local/bin/tor

	# config file:
	TOR_CONFIG_FILE=/usr/local/etc/tor/torrc
	echo "SocksPort 9050

## logs files:
Log notice file /tmp/tor-notices.log
#Log debug file /tmp/tor-debug.log" > $TOR_CONFIG_FILE

	# systemd service:
	# https://tor.stackexchange.com/questions/4587/run-tor-in-the-background-via-the-shell
	# https://unix.stackexchange.com/questions/330637/how-to-resolve-systemd-code-exited-status-227-no-new-privileges
	echo '[Unit]
Description=Anonymizing overlay network for TCP
Wants=network-online.target
After=network-online.target

[Service]
User=tor-service
Type=simple
ExecStart=/usr/local/bin/tor -f /usr/local/etc/tor/torrc
ExecReload=/usr/bin/kill -HUP $MAINPID
KillSignal=SIGINT
LimitNOFILE=32768
NoNewPrivileges=no
PrivateDevices=no

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/tor.service
	systemctl daemon-reload
	systemctl enable tor.service
	systemctl start tor.service
	## dummy package for tor:
	apt install equivs -y
	echo "Package: tor
Version: 999.99
Maintainer: nobody <nobody@nobody.com>
Architecture: all
Description: dummy tor package
 A dummy package with a version number so high that the real tor packages
 will never reach it." > anti-tor.equivs
	equivs-build anti-tor.equivs
	rm -rf anti-tor.equivs
	dpkg -i tor*.deb
	rm -rf tor*.deb
	## dummy package for tor-geoipdb:
	apt install equivs -y
	echo "Package: tor-geoipdb
Version: 999.99
Maintainer: nobody <nobody@nobody.com>
Architecture: all
Description: dummy tor-geoipdb package
 A dummy package with a version number so high that the real tor-geoipdb package
 will never reach it." > anti-tor-geoipdb.equivs
	equivs-build anti-tor-geoipdb.equivs
	rm -rf anti-tor-geoipdb.equivs
	dpkg -i tor-geoipdb*.deb
	rm -rf tor-geoipdb*.deb
}

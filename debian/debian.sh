#!/bin/bash

ESSENTIAL_PACKAGES="build-essential dnsutils kpcli man fwupd gnupg gcc gcc-doc nasm gdb python-is-python3 stubby curl wget jq git make binutils tcpdump lynx screen nala lm-sensors fancontrol lsb-release htop bmon locales-all ascii ipcalc sipcalc rar unrar zip unzip p7zip p7zip-full p7zip-rar ffmpeg sox flac"

PACKAGES="keepassxc keepass2 putty bleachbit gnome-disk-utility vlc audacity spek geany"

UNWANTED_PACKAGES="firefox-esr firefox* synaptic smtube qps quassel meteo-qt audacious popularity-contest evolution qbittorrent quodlibet parole exfalso yelp seahorse totem cheese" #malcontent

INTEL_THINGS="intel-microcode iucode-tool *nvidia* firmware-intel* intel-media-va-driver-non-free"

GNOME_THINGS="gnome-games* gnome-weather gnome-software-common gnome-boxes gnome-system-monitor rhythmbox transmission-common gnome-games gnome-clocks zutty gnome-characters debian-reference-common gnome-sound-recorder gnome-connections gnome-music gnome-weather gnome-calculator gnome-calendar gnome-contacts gnome-maps" #gnome-tour libreoffice*

OPENBOX="openbox menu obconf lightdm xfce4-terminal network-manager git kpcli nnn pcmanfm geany"

_flatpak()
{
	#apt purge flatpak -y && rm -rf /var/lib/flatpak/ && rm -rf /home/*/.cache/flatpak/ && rm -rf /home/*/.local/share/flatpak/ && rm -rf /home/*/.var/app/* && rm -rf /root/.local/share/flatpak/

	apt update && apt install --reinstall -y flatpak

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

	flatpak --user update -y ## this avoid restart current session nor reboot pc.
	flatpak update -y

	flatpak install -y flathub com.github.tchx84.Flatseal
	flatpak install -y flathub io.github.dosbox-staging
	#flatpak install -y flathub org.keepassxc.KeePassXC
	#flatpak install -y flathub org.mozilla.firefox
	#rm -rf /usr/bin/firefox
	#ln -sf /var/lib/flatpak/exports/bin/org.mozilla.firefox /usr/bin/firefox
	#update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 200 && update-alternatives --set x-www-browser /usr/bin/firefox
	flatpak install -y flathub io.github.thetumultuousunicornofdarkness.cpu-x
	#flatpak install -y flathub io.missioncenter.MrissionCenter
	#flatpak install -y flathub io.gitlab.librewolf-community
	#flatpak install -y flathub io.github.ungoogled_software.ungoogled_chromium
	#flatpak install -y flathub org.gnome.TextEditor
	#ln -sf /var/lib/flatpak/app/org.gnome.TextEditor/current/active/export/bin/org.gnome.TextEditor /usr/bin/gedit
	#flatpak install -y flathub com.vscodium.codium
	#ln -sf /var/lib/flatpak/app/com.vscodium.codium/current/active/export/bin/com.vscodium.codium /usr/bin/code
	#ln -sf /var/lib/flatpak/app/com.vscodium.codium/current/active/export/bin/com.vscodium.codium /usr/bin/codium
	#ln -sf /var/lib/flatpak/app/com.vscodium.codium/current/active/export/bin/com.vscodium.codium /usr/bin/vscodium
	#flatpak install -y flathub org.onlyoffice.desktopeditors
	#flatpak install -y flathub org.libreoffice.LibreOffice
	#flatpak install -y flathub org.gimp.GIMP
	#flatpak install -y flathub io.github.peazip.PeaZip
	flatpak install -y flathub network.loki.Session
	#flatpak install -y flathub io.github.Hexchat
	flatpak install -y flathub org.telegram.desktop
	flatpak install -y flathub com.discordapp.Discord
	#flatpak install -y flathub io.bassi.Amberol
	#flatpak install -y flathub io.freetubeapp.FreeTube
	#flatpak install -y flathub com.spotify.Client
	#flatpak install -y flathub org.qbittorrent.qBittorrent
	#flatpak install -y flathub com.warlordsoftwares.youtube-downloader-4ktube
	flatpak install -y flathub org.nicotine_plus.Nicotine
	#flatpak install -y flathub org.mixxx.Mixxx
	#flatpak install -y flathub com.bitwig.BitwigStudio
	#flatpak install -y flathub org.shotcut.Shotcut
	#flatpak install -y flathub com.github.PintaProject.Pinta
	
	flatpak update -y

	#chmod 755 /home/*/.local/share/flatpak
}

_basic_setup()
{
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi

	cp -v /root/.bashrc /root/.bashrc.bak
	cat <<"EOF" >> /root/.bashrc # this is IMPORTANT.
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin
EOF
	cat <<"EOF" >> /root/.bashrc
alias apt-clean='apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean'
EOF
	source /root/.bashrc

	mkdir -v -p /opt/apps
	mkdir -v -p /usr/share/bg-wp

	### PURGING SHIT
	#apt purge -y $UNWANTED_PACKAGES $GNOME_THINGS $INTEL_THINGS
	#apt autopurge -y
	
	### Disable Gnome Software from Startup Apps
	#apt remove -y unattended-upgrades
	#mv -v /etc/xdg/autostart/org.gnome.Software.desktop /etc/xdg/autostart/.org.gnome.Software.desktop

	### BEST SOURCES LIST FILES EVER, REALLY. $(lsb_release -cs)
	cat <<EOF > /etc/apt/sources.list.d/debian.sources
Types: deb deb-src
URIs: http://debian.web.trex.fi/debian/
Suites: $(lsb_release -cs) $(lsb_release -cs)-updates
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: http://debian.web.trex.fi/debian-security
Suites: $(lsb_release -cs)-security
Components: main contrib non-free non-free-firmware
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
	mv -v /etc/apt/sources.list /etc/apt/.sources.list.bak
	rm -f /etc/apt/sources.list
	rm -f /etc/apt/sources.list~
	apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean

	### BASIC PACKAGES TO GET LETS START.
	apt update
	apt install -y $ESSENTIAL_PACKAGES

	### EMACS NOX NO EXIM4 SERVER
	apt update
	apt install --no-install-recommends -y emacs-nox
	
	### CPU
	if wget --inet4-only --https-only --quiet --spider "https://dl.xanmod.org/check_x86-64_psabi.sh"; then
		wget --inet4-only --https-only https://dl.xanmod.org/check_x86-64_psabi.sh -O /usr/bin/check_x86-64_psabi
		chmod 755 /usr/bin/check_x86-64_psabi
		/usr/bin/awk -f /usr/bin/check_x86-64_psabi
	else
		echo "Error https://dl.xanmod.org/check_x86-64_psabi.sh not found." 
	fi
}

_networking()
{
	### DISABLING IPV6
 	### SYSCTL.CONF FILE
	cp -v /etc/sysctl.conf /etc/sysctl.conf.bak
	cat << "EOF" > /etc/sysctl.d/99-noipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
	sysctl -p
 	sysctl --system
	systemctl restart procps.service
	### GRUB
 	cp -v /etc/default/grub /etc/default/grub.bak
 	sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="ipv6.disable=1"/' /etc/default/grub
  	/usr/sbin/update-grub

	### STUBBY DOT SERVERS CONFIGURATION
	systemctl stop stubby.service
	cp -v /etc/stubby/stubby.yml /etc/stubby/stubby.yml.bak

	### GOOGLE PUBLIC DNS
	cat <<"EOF" > /etc/stubby/stubby.yml.google
### GOOGLE PUBLIC DNS
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 0
idle_timeout: 10000
tls_min_version: GETDNS_TLS1_3
tls_max_version: GETDNS_TLS1_3
listen_addresses:
  - 127.0.0.3
#  - 0::1
#dnssec: GETDNS_EXTENSION_TRUE
upstream_recursive_servers:
  - address_data: 8.8.8.8
    tls_auth_name: "dns.google"
  - address_data: 8.8.4.4
    tls_auth_name: "dns.google"
#  - address_data: 2001:4860:4860::8888
#    tls_auth_name: "dns.google"
#  - address_data: 2001:4860:4860::8844
#    tls_auth_name: "dns.google"
EOF

	### DNS.SB
	cat <<"EOF" > /etc/stubby/stubby.yml.dns.sb
### DNS.SB
resolution_type: GETDNS_RESOLUTION_STUB
dns_transport_list:
  - GETDNS_TRANSPORT_TLS
tls_authentication: GETDNS_AUTHENTICATION_REQUIRED
tls_query_padding_blocksize: 128
edns_client_subnet_private : 1
round_robin_upstreams: 0
idle_timeout: 10000
tls_min_version: GETDNS_TLS1_3
tls_max_version: GETDNS_TLS1_3
listen_addresses:
  - 127.0.0.3
#  - 0::1
#dnssec: GETDNS_EXTENSION_TRUE
upstream_recursive_servers:
  - address_data: 185.222.222.222
    tls_auth_name: "dot.sb"
    tls_pubkey_pinset:
      - digest: "sha256"
        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
  - address_data: 45.11.45.11
    tls_auth_name: "dot.sb"
    tls_pubkey_pinset:
      - digest: "sha256"
        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
#- address_data: 2a09:0000:0000:0000:0000:0000:0000:0000
#    tls_auth_name: "dot.sb"
#    tls_pubkey_pinset:
#      - digest: "sha256"
#        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
#  - address_data: 2a11:0000:0000:0000:0000:0000:0000:0000
#    tls_auth_name: "dot.sb"
#    tls_pubkey_pinset:
#      - digest: "sha256"
#        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=
EOF

	cp -v /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
	systemctl enable --now stubby.service
	systemctl restart stubby.service

	### STATIC RESOLV CONF FILE
	cp -v /etc/resolv.conf /etc/resolv.conf.bak
	cat <<"EOF" > /etc/resolv.conf.stubby
nameserver 127.0.0.3
options trust-ad
EOF
	cp -v /etc/resolv.conf.stubby /etc/resolv.conf
	chattr +i /etc/resolv.conf

	cp -v /etc/hosts /etc/hosts.bak

	### GOOGLE
	cat <<"EOF" > /usr/bin/dnsgoogle
#!/bin/bash
chattr -i /etc/resolv.conf
cp -v /etc/resolv.conf.stubby /etc/resolv.conf
chattr +i /etc/resolv.conf
cp -v /etc/hosts.bak /etc/hosts
cp -v /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
systemctl restart stubby.service
EOF
	chmod +x /usr/bin/dnsgoogle
	
	### DNS.SB
	cat <<"EOF" > /usr/bin/dnssb
#!/bin/bash
chattr -i /etc/resolv.conf
cp -v /etc/resolv.conf.stubby /etc/resolv.conf
chattr +i /etc/resolv.conf
cp -v /etc/hosts.bak /etc/hosts
cp -v /etc/stubby/stubby.yml.dns.sb /etc/stubby/stubby.yml
systemctl restart stubby.service
EOF
	chmod +x /usr/bin/dnssb

	### NTP ENCRYPTED
	apt update && apt install -y ntpsec
	systemctl stop ntpsec.service
	cp -v /etc/ntpsec/ntp.conf /etc/ntpsec/ntp.conf.bak
	cat <<"EOF" > /etc/ntpsec/ntp.conf
driftfile /var/lib/ntpsec/ntp.drift
leapfile /usr/share/zoneinfo/leap-seconds.list
tos maxclock 11
tos minclock 4 minsane 3
server time.cloudflare.com nts
restrict default kod nomodify nopeer noquery limited
restrict 127.0.0.1
#restrict ::1
EOF
	systemctl restart ntpsec.service
}

_debian_desktop()
{
	### OFFICIAL DEBIAN PACKAGES
	apt update
	apt install -y $PACKAGES
	
	### LIQUORIX KERNEL
 	### curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
	curl -s "https://liquorix.net/liquorix-keyring.gpg" | gpg --batch --yes --output /etc/apt/keyrings/liquorix-keyring.gpg --dearmor
	chmod 0644 /etc/apt/keyrings/liquorix-keyring.gpg
	cat <<EOF > /etc/apt/sources.list.d/liquorix.sources
Types: deb deb-src
URIs: https://liquorix.net/debian
Suites: $(lsb_release -cs)
Components: main
Architectures: amd64
Signed-By: /etc/apt/keyrings/liquorix-keyring.gpg
EOF
	#apt update && apt install --install-recommends -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64

	### TOR BROWSER
	cat <<"EOF" > /usr/bin/installer-tor-browser
#!/bin/bash
LINK="https://www.torproject.org"
TOR_BROWSER_LINK=$(curl -s "$LINK"/download/ | grep -oP 'href="/dist/torbrowser/[^"]*"' | grep 'linux-x86_64' | sed 's/href="\///' | sed 's/"//' | head -n 1)
URL="$LINK"/"$TOR_BROWSER_LINK"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    tar xf "$FILE"
    mv -v tor-browser/ /opt/apps
    rm -rf "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-tor-browser
	bash /usr/bin/installer-tor-browser

	### GOOGLE CHROME
	cat <<"EOF" > /usr/bin/installer-google-chrome
#!/bin/bash
URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    apt install -y "./$FILE"
	rm -f "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-google-chrome
	bash /usr/bin/installer-google-chrome

	### FIREFOX
	#apt update && apt install --install-recommends -y firefox-esr
	apt purge -y firefox* && rm -rf /home/*/.mozilla && rm -rf /home/*/.cache/mozilla
	install -d -m 0755 /etc/apt/keyrings
	wget --inet4-only --https-only -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
	gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
	cat <<EOF > /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
	cat <<EOF > /etc/apt/preferences.d/mozilla
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF
	apt update && apt install -y firefox

	### VIRTUAL BOX
	wget --inet4-only --https-only -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
	cat <<EOF > /etc/apt/sources.list.d/vbox.sources
Types: deb
URIs: https://download.virtualbox.org/virtualbox/debian
Suites: $(lsb_release -cs)
Components: contrib
Architectures: amd64
Signed-By: /usr/share/keyrings/oracle-virtualbox-2016.gpg
EOF
	apt update && apt install --install-recomends -y virtualbox-7.2 linux-headers-amd64 linux-headers-$(uname -r)

	### VSCODE
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
	install -D -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
	rm -f microsoft.gpg
	cat <<EOF > /etc/apt/sources.list.d/vscode.sources
Types: deb
URIs: https://packages.microsoft.com/repos/code
Suites: stable
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/microsoft.gpg
EOF
	apt update && apt install -y code

	### FASTFETCH
    cat <<"EOF" > /usr/bin/installer-fastfetch-cli
#!/bin/bash
URL="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    apt install -y "./$FILE"
	rm -f "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-fastfetch-cli
	bash /usr/bin/installer-fastfetch-cli
}

_cookie_fortune()
{
	## https://stackoverflow.com/questions/414164/how-can-i-select-random-files-from-a-directory-in-bash
	apt update && apt install -y cowsay fortunes
	cat <<"EOF" > /usr/bin/cookie-fortune
#!/bin/bash
CHARACTER=$(ls /usr/share/cowsay/cows/ | shuf -n 1)
fortune -s | cowsay -f $CHARACTER
EOF
	rm -rf /usr/share/applications/fortune.desktop
	chmod 755 /usr/bin/cookie-fortune
	bash /usr/bin/cookie-fortune
}

_basic_setup
_networking
#_debian_desktop
#_flatpak
_cookie_fortune

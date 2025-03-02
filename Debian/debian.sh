#!/bin/bash

_PACKAGES="nala flatpak bleachbit python-is-python3 rar unrar zip unzip p7zip-full p7zip-rar gnome-disk-utility ffmpeg flac audacity vlc sox spek gnupg git make binutils gcc g++"

_UNDESIRED_PACKAGES="intel-microcode iucode-tool *nvidia* firmware-intel* intel-media-va-driver-non-free synaptic firefox-esr libreoffice-core libreoffice-common popularity-contest gnome-software-common gnome-boxes gnome-system-monitor rhythmbox transmission-common gnome-games malcontent gnome-games-app gnome-weather evolution qbittorrent qbittorrent-nox quodlibet parole exfalso yelp seahorse simple-scan gnome-clocks zutty gnome-characters debian-reference-common totem cheese gnome-sound-recorder gnome-connections gnome-music gnome-weather gnome-calculator gnome-calendar gnome-contacts gnome-maps gnome-text-editor gnome-tour"

_flatpak()
{
	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

	flatpak --user update -y ## this avoid restart current session nor reboot pc.
	flatpak update -y

	flatpak install -y flathub com.github.tchx84.Flatseal
	flatpak install -y flathub io.github.thetumultuousunicornofdarkness.cpu-x
	flatpak install -y flathub io.missioncenter.MissionCenter
	flatpak install -y flathub org.mozilla.firefox #&& update-alternatives --set x-www-browser /var/lib/flatpak/exports/bin/org.mozilla.firefox
	flatpak install -y flathub org.gnome.TextEditor
	flatpak install -y flathub org.onlyoffice.desktopeditors
	flatpak install -y flathub org.libreoffice.LibreOffice
	flatpak install -y flathub org.keepassxc.KeePassXC
	flatpak install -y flathub org.gnome.Boxes
	flatpak install -y flathub io.github.peazip.PeaZip
	flatpak install -y flathub com.discordapp.Discord
	flatpak install -y flathub io.bassi.Amberol
	flatpak install -y flathub com.spotify.Client
	flatpak install -y flathub org.qbittorrent.qBittorrent
	flatpak install -y flathub org.nicotine_plus.Nicotine
	flatpak install -y flathub org.mixxx.Mixxx
	flatpak install -y flathub com.bitwig.BitwigStudio
	flatpak install -y flathub org.shotcut.Shotcut
	
	flatpak update -y
}

_main()
{
	if [ "$EUID" -ne 0 ]
	  then echo "Please run as root"
	  exit
	fi

	cp /root/.bashrc /root/.bashrc.original
	echo "export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin" >> /root/.bashrc # this is IMPORTANT.
	echo "alias apt-clean='apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean'" >> /root/.bashrc
	echo "alias nala-clean='apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean'" >> /root/.bashrc
	echo "alias wget='wget --inet4-only --https-only'" >> /root/.bashrc

	source /root/.bashrc

	mkdir -p -v /opt
	
	### Disable Gnome Software from Startup Apps
	rm -rf /etc/xdg/autostart/org.gnome.Software.desktop

	### BEST SOURCES LIST FILES EVER, REALLY.
	cp /etc/apt/sources.list /etc/apt/sources.list.original
	apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean
	echo "deb http://deb.debian.org/debian/ $(lsb_release -cs) main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ $(lsb_release -cs) main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security $(lsb_release -cs)-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security $(lsb_release -cs)-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ $(lsb_release -cs)-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ $(lsb_release -cs)-updates main contrib non-free non-free-firmware" > /etc/apt/sources.list

	### BASIC PACKAGES TO GET LETS START.
	apt update
	apt install -y stubby ntpsec ntpsec-doc wget tcpdump elinks software-properties-common ca-certificates lm-sensors fancontrol curl lsb-release htop bmon locales-all hello-traditional ascii

	### STUBBY DOT SERVERS CONFIGURATION
	systemctl stop stubby.service
	cp /etc/stubby/stubby.yml /etc/stubby/stubby.yml.original
	echo 'resolution_type: GETDNS_RESOLUTION_STUB
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
upstream_recursive_servers:
  - address_data: 8.8.8.8
    tls_auth_name: "dns.google"
  - address_data: 8.8.4.4
    tls_auth_name: "dns.google"' > /etc/stubby/stubby.yml.google
	echo 'resolution_type: GETDNS_RESOLUTION_STUB
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
upstream_recursive_servers:
  - address_data: 1.1.1.1
    tls_auth_name: "one.one.one.one"
  - address_data: 1.0.0.1
    tls_auth_name: "one.one.one.one"' > /etc/stubby/stubby.yml.cloudflare
		echo 'resolution_type: GETDNS_RESOLUTION_STUB
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
        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=' > /etc/stubby/stubby.yml.dns.sb
	cp /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
	systemctl enable --now stubby.service
	systemctl restart stubby.service

	### STATIC RESOLV CONF FILE
	cp /etc/resolv.conf /etc/resolv.conf.original
	echo "nameserver 127.0.0.3
options trust-ad" > /etc/resolv.conf
	chattr +i /etc/resolv.conf
	cp /etc/resolv.conf /etc/resolv.conf.stubby
	
	### CLOUDFLARE NTPSEC CLIENT
	cp /etc/ntpsec/ntp.conf /etc/ntpsec/ntp.conf.original
	echo "driftfile /var/lib/ntpsec/ntp.drift
leapfile /usr/share/zoneinfo/leap-seconds.list
tos maxclock 11
tos minclock 4 minsane 3
server time.cloudflare.com nts
restrict default kod nomodify nopeer noquery limited
restrict 127.0.0.1
#restrict ::1" > /etc/ntpsec/ntp.conf.cloudflare-encrypted
	cp /etc/ntpsec/ntp.conf.cloudflare-encrypted /etc/ntpsec/ntp.conf
	systemctl restart ntpsec.service

	### AD BLOCKING BY HOSTS FILE DIRECTLY
	cp /etc/hosts /etc/hosts.original
	echo "#!/bin/bash
chattr -i /etc/hosts
wget --inet4-only --https-only https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts -O /etc/hosts-steven-black
wget --inet4-only --https-only https://someonewhocares.org/hosts/zero/hosts -O /etc/hosts-dan-pollock
cat /etc/hosts.original > /etc/hosts-ad-blocker
cat /etc/hosts-steven-black >> /etc/hosts-ad-blocker
cat /etc/hosts-dan-pollock >> /etc/hosts-ad-blocker
sed -i -e 's/click.discord.com/0.0.0.0/g' /etc/hosts-ad-blocker
cp /etc/hosts-ad-blocker /etc/hosts
chattr +i /etc/hosts" > /usr/bin/make-hosts-block-ads
	chmod +x /usr/bin/make-hosts-block-ads
	bash /usr/bin/make-hosts-block-ads

	### PURGING PACKAGES
	apt purge -y $_UNDESIRED_PACKAGES
	apt autopurge -y

	### LIQUORIX KERNEL
	curl -s 'https://liquorix.net/install-liquorix.sh' | bash

	### FASTFETCH
	echo "#!/bin/bash
wget --inet4-only --https-only https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
apt install -y ./fastfetch-linux-amd64.deb
rm -rf ./fastfetch-linux-amd64.deb" > /usr/bin/fastfetch-update
	chmod +x /usr/bin/fastfetch-update
	bash /usr/bin/fastfetch-update

	### TELEGRAM
	wget --inet4-only --https-only https://telegram.org/dl/desktop/linux -O telegram.tar.xz
	tar xf telegram.tar.xz
	rm -rf telegram.tar.xz
	mv Telegram /opt
	echo "[Desktop Entry]
Name=Telegram
Comment=New era of messaging
TryExec=/opt/Telegram/Telegram
Exec=/opt/Telegram/Telegram -- %u
Icon=telegram
Terminal=false
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;x-scheme-handler/tonsite;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
Actions=quit;
DBusActivatable=true
SingleMainWindow=true
X-GNOME-UsesNotifications=true
X-GNOME-SingleWindow=true

[Desktop Action quit]
Exec=/opt/Telegram/Telegram -quit
Name=Quit Telegram
Icon=application-exit" > /usr/share/applications/telegram.desktop

	### GOOGLE CHROME
	wget --inet4-only --https-only https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	apt install -y ./google-chrome-stable_current_amd64.deb
	rm -rf ./google-chrome-stable_current_amd64.deb

	### VISUAL STUDIO CODE
	wget --inet4-only --https-only -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	rm -f packages.microsoft.gpg
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
	apt update
	apt install -y code

	### STEAM
	dpkg --add-architecture i386
	apt update
	apt install -y steam-installer
	apt install -y mesa-vulkan-drivers mesa-vulkan-drivers:i386 libglx-mesa0:i386 libgl1-mesa-dri:i386 #pipewire:i386 libgtk2.0-0:i386
	apt install -y mangohud mangohud:i386

	### YOUTUBE DOWNLOADER
	apt purge -y yt-dlp
	rm -rf /opt/yt-*
	wget --inet4-only --https-only https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /opt/yt-dlp
	chmod 755 /opt/yt-dlp
	ln -sf /opt/yt-dlp /usr/bin/yt-dlp

	mkdir -v -p /opt/songs
	touch /opt/songs/SONG{001..101}.flac

	chown tomas:tomas -R /opt

	### OFFICIAL DEBIAN PACKAGES
	apt update
	apt install -y $_PACKAGES

	### required libraries for 64-bit machines for Android Studio
	#apt install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

}

_cookie_fortune()
{
	## https://stackoverflow.com/questions/414164/how-can-i-select-random-files-from-a-directory-in-bash
	apt update
	apt install -y cowsay fortunes
	cat << EOF > /usr/bin/cookie-fortune
#!/bin/bash
main_()
{
    CHARACTER_=\$(ls /usr/share/cowsay/cows/ | shuf -n 1)
    fortune -s | cowsay -f \$CHARACTER_
}
main_
exit 0
EOF
	chmod 755 /usr/bin/cookie-fortune
	rm -rf /usr/share/applications/fortune.desktop
}

_main
_flatpak
_cookie_fortune

/usr/bin/cookie-fortune




### SOME OWN REFERENCE:

#fwupdmgr get-devices
#fwupdmgr refresh --force
#fwupdmgr get-updates
#fwupdmgr update

### NO LIMIT MEMORY IN ARDOUR
	#cp /etc/security/limits.conf /etc/security/limits.conf.original
	#echo "@audio                -       memlock         unlimited" >> /etc/security/limits.conf
	#cp /etc/pam.d/common-session /etc/pam.d/common-session.original
	#echo "session required pam_limits.so" >> /etc/pam.d/common-session
	### restart session please.

### GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3"

#apt install -y linux-xanmod-rt-x64v$(/usr/bin/awk -f check_x86-64_psabi.sh | cut -f2 -d"v")

#VERSION_=$(curl --silent "https://api.github.com/repos/someone/something/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

#VERSION_=$(curl --silent "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

#wget --inet4-only --https-only https://download.bleachbit.org/bleachbit_4.6.2-0_all_debian12.deb -O bleachbit.deb

#xorriso -indev debian-12.9.0-amd64-netinst.iso \
#        -outdev my_debian-12.9.0-amd64-netinst.iso \
#        -add debian.sh -- \
#       -boot_image any replay --

#lsblk

#sudo dd bs=1M if=my_debian-12.9.0-amd64-netinst.iso of=/dev/sdx conv=fsync oflag=direct status=progress

### 24 bit depth and 192 Khz audio support.
#cp /etc/pulse/daemon.conf /etc/pulse/daemon.conf.original
#echo "default-sample-format = s24le
#default-sample-rate = 192000
#alternate-sample-rate = 48000
#default-sample-channels = 2
#default-channel-map = front-left,front-right" >> /etc/pulse/daemon.conf


#PARTICIPATE="yes"
#ENCRYPT="yes"
#USEHTTP="yes"
#DAY="6"


# systemctl --type=service --state=running

_others()
{
	### SQLMAP
	apt purge -y sqlmap
	rm -rf /opt/sqlmap*
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap-dev
	ln -sf /opt/sqlmap-dev/sqlmap.py /usr/bin/sqlmap

	### VENTOY
	rm -rf /opt/ventoy*
	wget --inet4-only --https-only $(curl --silent "https://api.github.com/repos/ventoy/Ventoy/releases/latest" | jq -r '(.assets[1].browser_download_url)') -O ventoy-linux.tar.gz
	tar -xf ventoy-linux.tar.gz
	rm -rf ventoy-linux.tar.gz
	mv ventoy-* /opt/ventoy

	### NMAP
	PWD_=$(pwd)
	_SOURCE_CODE_=$(curl -s https://nmap.org/download | grep tar.bz2 | head -n 1 | cut -d " " -f 3)
	if [[ `wget --inet4-only --https-only --server-response --spider https://nmap.org/dist/$_SOURCE_CODE_ 2>&1 | grep '200 OK'` ]]; then
		apt purge -y nmap*
		rm -rf /opt/nmap*
		apt update
		apt install -y python3-pip gcc g++ make liblua5.4-dev libssl-dev libssh2-1-dev libtool-bin
		mkdir -p -v /opt/nmap-suite
		wget --inet4-only --https-only https://nmap.org/dist/$_SOURCE_CODE_
		tar xjf $_SOURCE_CODE_
		rm -rf $_SOURCE_CODE_
		cd nmap-*
		./configure --quiet --prefix=/opt/nmap-suite --without-zenmap --without-ndiff --without-ncat --without-nping
		make -j 1
		make install
		ln -sf /opt/nmap-suite/bin/nmap /usr/bin/nmap
	else
		echo "Nmap source code 404."
	fi
	cd $PWD_

	### WINE HQ
	dpkg --add-architecture i386
	mkdir -pm755 /etc/apt/keyrings
	wget --inet4-only --https-only -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
	wget --inet4-only --https-only -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
	apt update
	apt install --install-recommends -y winehq-devel
	#wine winecfg
	#wine clock

	### XANMOD REAL TIME KERNEL
	wget --inet4-only --https-only -qO - https://dl.xanmod.org/archive.key | gpg --dearmor -vo /etc/apt/keyrings/xanmod-archive-keyring.gpg
	echo 'deb [signed-by=/etc/apt/keyrings/xanmod-archive-keyring.gpg] http://deb.xanmod.org releases main' | tee /etc/apt/sources.list.d/xanmod-release.list
	wget --inet4-only --https-only https://dl.xanmod.org/check_x86-64_psabi.sh -O /usr/bin/check_x86-64_psabi
	chmod 755 /usr/bin/check_x86-64_psabi
	#apt update
	#apt install -y linux-xanmod-rt-x64v$(/usr/bin/awk -f /usr/bin/check_x86-64_psabi | cut -f2 -d"v") linux-xanmod-x64v$(/usr/bin/awk -f /usr/bin/check_x86-64_psabi | cut -f2 -d"v")

	### IVPN
	curl -fsSL https://repo.ivpn.net/stable/debian/generic.gpg | gpg --dearmor > ~/ivpn-archive-keyring.gpg
	mv ~/ivpn-archive-keyring.gpg /usr/share/keyrings/ivpn-archive-keyring.gpg
	chown root:root /usr/share/keyrings/ivpn-archive-keyring.gpg && chmod 644 /usr/share/keyrings/ivpn-archive-keyring.gpg
	curl -fsSL https://repo.ivpn.net/stable/debian/generic.list | tee /etc/apt/sources.list.d/ivpn.list
	chown root:root /etc/apt/sources.list.d/ivpn.list && chmod 644 /etc/apt/sources.list.d/ivpn.list
	apt update
	apt install ivpn-ui
	apt install ivpn

	### TOR
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org unstable main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/deb.torproject.org-keyring.gpg] https://deb.torproject.org/torproject.org unstable main" > /etc/apt/sources.list.d/tor.list
	wget --inet4-only --https-only -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
	echo '
Package: *
Pin: origin deb.torproject.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/tor
	apt update
	apt install -y tor deb.torproject.org-keyring
	systemctl stop tor.service
	systemctl disable tor.service

	### MICROSOFT PRODUCTS: OPENJDK 21 LTS AND POWERSHELL LTS
	wget --inet4-only --https-only https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb
	apt install -y ./packages-microsoft-prod.deb
	rm -rf ./packages-microsoft-prod.deb
	apt update
	apt install -y msopenjdk-21 powershell-lts

	### GHIDRA
	rm -rf /opt/ghidra/
	wget --inet4-only --https-only $(curl --silent "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" | jq -r '(.assets[].browser_download_url)')
	unzip -q ghidra_*.zip
	rm -rf ghidra_*.zip
	mv ghidra_* /opt/ghidra
	ln -sf /opt/ghidra/ghidraRun /usr/bin/ghidra
	rm -rf /opt/ghidra/ghidraRun.bat
    echo "[Desktop Entry]
Categories=Application;Development;
Comment[en_US]=Ghidra Software Reverse Engineering Suite
Comment=Ghidra Software Reverse Engineering Suite
Exec=/opt/ghidra/ghidraRun
GenericName[en_US]=Ghidra Software Reverse Engineering Suite
GenericName=Ghidra Software Reverse Engineering Suite
Icon=/opt/ghidra/docs/images/GHIDRA_1.png
MimeType=
Name[en_US]=Ghidra
Name=Ghidra
Path=/opt/ghidra
StartupNotify=false
Terminal=false
TerminalOptions=
Type=Application
Version=1.0
X-DBUS-ServiceName=
X-DBUS-StartupType=none
X-KDE-SubstituteUID=false
X-KDE-Username=" > /usr/share/applications/ghidra.desktop

	### GOOGLE EARTH PRO
	wget --inet4-only --https-only https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb
	apt install -y ./google-earth-pro-stable_current_amd64.deb
	rm -rf ./google-earth-pro-stable_current_amd64.deb

	### VIRTUAL BOX
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee /etc/apt/sources.list.d/vbox.list > /dev/null
	wget --inet4-only --https-only -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
	apt update
	apt install -y virtualbox-7.1
	apt install -y linux-headers-amd64
	apt install -y linux-headers-$(uname -r)

	### NFSIISE
    ### Copy fedata and gamedata directories from the Need For Speed™ II SE original CD-ROM into Need For Speed II SE directory.
    ### All files and directories copied from CD-ROM must have small letters on Unix-like systems!!!
    ###     Please use the Need For Speed II SE/convert_to_lowercase script if you have UPPERCASE names.
	### OPTIONAL: mangohud --dlsym nfs2se
    dpkg --add-architecture i386
    apt update
    apt install -y git libsdl2-dev:i386 gcc g++ gcc-multilib g++-multilib yasm clang lld lld:i386 mangohud mangohud:i386
    git clone https://github.com/zaps166/NFSIISE /opt/NFSIISE
    cd /opt/NFSIISE
    git submodule update --init --recursive
    ./compile_nfs cpp
    mv /opt/NFSIISE/Need\ For\ Speed\ II\ SE/ /opt/NeedForSpeedIISE
	rm -rf /opt/NFSIISE
	cd /tmp

	### ANYDESK
	install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://keys.anydesk.com/repos/DEB-GPG-KEY -o /etc/apt/keyrings/keys.anydesk.com.asc
	chmod a+r /etc/apt/keyrings/keys.anydesk.com.asc
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/keys.anydesk.com.asc] http://deb.anydesk.com all main" | tee /etc/apt/sources.list.d/anydesk-stable.list > /dev/null
	apt update
	apt install -y anydesk
	systemctl stop anydesk.service
	systemctl disable anydesk.service
	
	### FIREFOX
	install -d -m 0755 /etc/apt/keyrings
	wget --inet4-only --https-only -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
	gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
	echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla
	apt update
	apt install -y firefox
	apt install -y firefox-l10n-es-ar

	### FIREFOX from tarball, dont worry about manual updates using apt nor flatpak.
	cp /usr/share/applications/firefox.desktop /usr/share/applications/firefox.desktop.example
	cp /usr/share/applications/firefox-esr.desktop /usr/share/applications/firefox-esr.desktop.example
	wget --https-only --inet4-only -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
	tar -xf firefox.tar.bz2
	rm -rf firefox.tar.bz2
	mv firefox /opt/
	echo "[Desktop Entry]
Name=Firefox
Comment=Browse the World Wide Web
Comment[es]=Navegue por la web
GenericName=Web Browser
GenericName[es]=Navegador web
X-GNOME-FullName=Firefox Web Browser
X-GNOME-FullName[es]=Navegador web Firefox
Exec=/opt/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupWMClass=firefox
StartupNotify=true" > /usr/share/applications/firefox.desktop
}

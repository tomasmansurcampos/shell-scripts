#!/bin/bash

_PACKAGES="flatpak keepassxc fwupd bleachbit python-is-python3 rar unrar zip unzip p7zip-full p7zip-rar gnome-disk-utility audacity flac ffmpeg bpm-tools sox spek gnupg git make binutils geany gcc gcc-doc picard clementine"

_UNDESIRED_PACKAGES="firefox-esr firefox* synaptic vlc vlc-bin vlc-data smplayer smtube mpv qps quassel meteo-qt audacious popularity-contest evolution qbittorrent qbittorrent-nox quodlibet parole exfalso yelp seahorse totem cheese" #malcontent

_INTEL_SHIT="intel-microcode iucode-tool *nvidia* firmware-intel* intel-media-va-driver-non-free"

_GNOME_SHIT="gnome-games* gnome-weather gnome-software-common gnome-boxes gnome-system-monitor rhythmbox transmission-common gnome-games gnome-clocks zutty gnome-characters debian-reference-common gnome-sound-recorder gnome-connections gnome-music gnome-weather gnome-calculator gnome-calendar gnome-contacts gnome-maps" #gnome-tour libreoffice*

_flatpak()
{
	#apt purge flatpak -y && rm -rf /var/lib/flatpak/ && rm -rf /home/*/.cache/flatpak/ && rm -rf /home/*/.local/share/flatpak/ && rm -rf /home/*/.var/app/* && rm -rf /root/.local/share/flatpak/

	flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

	flatpak --user update -y ## this avoid restart current session nor reboot pc.
	flatpak update -y

	flatpak install -y flathub com.github.tchx84.Flatseal
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
	flatpak install -y flathub io.github.Hexchat
	flatpak install -y flathub org.telegram.desktop
	flatpak install -y flathub com.discordapp.Discord
	#flatpak install -y flathub io.bassi.Amberol
	#flatpak install -y flathub io.freetubeapp.FreeTube
	flatpak install -y flathub com.spotify.Client
	flatpak install -y flathub org.qbittorrent.qBittorrent
	#flatpak install -y flathub com.warlordsoftwares.youtube-downloader-4ktube
	flatpak install -y flathub org.nicotine_plus.Nicotine
	flatpak install -y flathub org.mixxx.Mixxx
	#flatpak install -y flathub com.bitwig.BitwigStudio
	#flatpak install -y flathub org.shotcut.Shotcut
	flatpak install -y flathub com.github.PintaProject.Pinta
	
	flatpak update -y

	chmod 755 /home/*/.local/share/flatpak
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
	source /root/.bashrc
	
	### PURGING SHIT
	apt purge -y $_UNDESIRED_PACKAGES $_GNOME_SHIT $_INTEL_SHIT
	apt autopurge -y
	
	### Disable Gnome Software from Startup Apps
	#rm -rf /etc/xdg/autostart/org.gnome.Software.desktop

	### BEST SOURCES LIST FILES EVER, REALLY. $(lsb_release -cs)
	cp /etc/apt/sources.list /etc/apt/sources.list.original
	apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean
	echo "deb http://debian.web.trex.fi/debian/ $(lsb_release -cs) main contrib non-free non-free-firmware
#deb-src http://debian.web.trex.fi/debian/ $(lsb_release -cs) main contrib non-free non-free-firmware

deb http://debian.web.trex.fi/debian-security $(lsb_release -cs)-security main contrib non-free non-free-firmware
#deb-src http://debian.web.trex.fi/debian-security $(lsb_release -cs)-security main contrib non-free non-free-firmware

deb http://debian.web.trex.fi/debian/ $(lsb_release -cs)-updates main contrib non-free non-free-firmware
#deb-src http://debian.web.trex.fi/debian/ $(lsb_release -cs)-updates main contrib non-free non-free-firmware

#deb http://debian.web.trex.fi/debian/ $(lsb_release -cs)-backports main contrib non-free non-free-firmware
#deb-src http://debian.web.trex.fi/debian/ $(lsb_release -cs)-backports main contrib non-free non-free-firmware
" > /etc/apt/sources.list

	### BASIC PACKAGES TO GET LETS START.
	apt update
	apt install -y keepassxc stubby wget tcpdump elinks nala software-properties-common ca-certificates lm-sensors fancontrol curl lsb-release htop bmon locales-all hello-traditional ascii ipcalc nmap ncat sipcalc #jq

	### STUBBY DOT SERVERS CONFIGURATION
	systemctl stop stubby.service
	cp /etc/stubby/stubby.yml /etc/stubby/stubby.yml.original
	### GOOGLE PUBLIC DNS
	echo '### GOOGLE PUBLIC DNS
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
#    tls_auth_name: "dns.google"' > /etc/stubby/stubby.yml.google
	### DNS.SB
	echo '### DNS.SB
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
        value: amEjS6OJ74LvhMNJBxN3HXxOMSWAriaFoyMQn/Nb5FU=' > /etc/stubby/stubby.yml.dns.sb
	cp /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
	systemctl enable --now stubby.service
	systemctl restart stubby.service

	### STATIC RESOLV CONF FILE
	cp /etc/resolv.conf /etc/resolv.conf.original
	echo "nameserver 127.0.0.3
#nameserver ::1
options trust-ad" > /etc/resolv.conf.stubby
	cp /etc/resolv.conf.stubby /etc/resolv.conf
	chattr +i /etc/resolv.conf

	### TIME SERVER CONFIG
	# timedatectl show-timesync | grep ServerName
	#time.google.com
	#216.239.35.0 216.239.35.4 216.239.35.8 216.239.35.12
	#0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
	#1.ar.pool.ntp.org 2.south-america.pool.ntp.org 3.south-america.pool.ntp.org
	#Servicio de Hidrografía Naval República Argentina:
	#ntp2.hidro.gob.ar
	#Ministerio de Defensa República Argentina:
	#ntp.ign.gob.ar
	#0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org
	cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.original
	echo "[Time]
NTP=time.google.com
FallbackNTP=216.239.35.0 216.239.35.4 216.239.35.8 216.239.35.12
RootDistanceMaxSec=5
PollIntervalMinSec=32
PollIntervalMaxSec=2048
ConnectionRetrySec=30
SaveIntervalSec=60" > /etc/systemd/timesyncd.conf
	systemctl restart systemd-timesyncd.service

	cp /etc/hosts /etc/hosts.original
	### GOOGLE
	echo "#!/bin/bash
chattr -i /etc/resolv.conf
cp /etc/resolv.conf.stubby /etc/resolv.conf
chattr +i /etc/resolv.conf
cp /etc/hosts.original /etc/hosts
cp /etc/stubby/stubby.yml.google /etc/stubby/stubby.yml
systemctl restart stubby.service" > /usr/bin/dnsgoogle
	chmod +x /usr/bin/dnsgoogle
	### DNS.SB
	echo "#!/bin/bash
chattr -i /etc/resolv.conf
cp /etc/resolv.conf.stubby /etc/resolv.conf
chattr +i /etc/resolv.conf
cp /etc/hosts.original /etc/hosts
cp /etc/stubby/stubby.yml.dns.sb /etc/stubby/stubby.yml
systemctl restart stubby.service" > /usr/bin/dnssb
	chmod +x /usr/bin/dnssb

	### FASTFETCH
	echo "#!/bin/bash
wget --inet4-only --https-only https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
apt install -y ./fastfetch-linux-amd64.deb
rm -rf ./fastfetch-linux-amd64.deb" > /usr/bin/installer-fastfetch-cli
	chmod +x /usr/bin/installer-fastfetch-cli
	bash /usr/bin/installer-fastfetch-cli

	### LIQUORIX KERNEL
	curl -s 'https://liquorix.net/install-liquorix.sh' | bash

	### FIREFOX
	#apt update && apt install --install-recommends -y firefox-esr
	apt purge -y firefox* && rm -rf /home/*/.mozilla && rm -rf /home/*/.cache/mozilla
	install -d -m 0755 /etc/apt/keyrings
	wget --inet4-only --https-only -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
	gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
	echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
	echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | tee /etc/apt/preferences.d/mozilla
	apt update && apt install -y firefox

	### GOOGLE CHROME
	wget --inet4-only --https-only https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	apt install -y ./google-chrome-stable_current_amd64.deb
	rm -rf ./google-chrome-stable_current_amd64.deb
	
	### STEAM
	### cleaning previous steam files.
	apt purge -y steam*
	apt-get --allow-remove-essential purge -y ".*:i386"
	dpkg --remove-architecture i386
	apt autopurge -y
	rm -rf /home/*/.steam*
	apt autoclean && apt clean && rm -rf /var/lib/apt/lists/* && apt clean
	apt update
	### installation:
	dpkg --add-architecture i386
	apt update
	apt install -y steam-installer
	apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
	#apt install -y mangohud mangohud:i386
	
	### VIRTUAL BOX
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib" | tee /etc/apt/sources.list.d/vbox.list > /dev/null
	wget --inet4-only --https-only -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor
	apt update && apt install -y virtualbox-7.0 linux-headers-amd64 linux-headers-$(uname -r)

	### ZOOM
	echo "#!/bin/bash
wget --inet4-only --https-only https://zoom.us/client/latest/zoom_amd64.deb
apt install -y ./zoom_amd64.deb
rm -rf ./zoom_amd64.deb" > /usr/bin/installer-zoom
	chmod +x /usr/bin/installer-zoom
	bash /usr/bin/installer-zoom

	mkdir -v -p /opt/songs
	touch /opt/songs/SONG{001..102}.flac
	
	### YOUTUBE DOWNLOADER
	apt purge -y yt-dlp
	rm -rf /opt/apps/yt-*
	rm -rf /usr/bin/yt-*
	mkdir -v -p /opt/apps/
	wget --inet4-only --https-only https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O /opt/apps/yt-dlp
	chmod 755 /opt/apps/yt-dlp
	ln -sf /opt/apps/yt-dlp /usr/bin/yt-dlp
	
	### SQLMAP
	apt purge -y sqlmap*
	rm -rf /opt/apps/sqlmap*
	rm -rf /usr/bin/sqlmap*
	mkdir -v -p /opt/apps/
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/apps/sqlmap-dev
	ln -sf /opt/apps/sqlmap-dev/sqlmap.py /usr/bin/sqlmap
	
	### FFMPEG
	echo "#!/bin/bash
rm -rf /opt/apps/ffmpeg*
rm -rf /usr/bin/master-ff*
mkdir -v -p /opt/apps/
wget --inet4-only --https-only https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz
tar xf ffmpeg-master-latest-linux64-gpl.tar.xz
rm -rf ffmpeg-master-latest-linux64-gpl.tar.xz
mv ffmpeg-master-latest-linux64-gpl /opt/apps
ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg /usr/bin/master-ffmpeg
ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffplay /usr/bin/master-ffplay
ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffprobe /usr/bin/master-ffprobe" > /usr/bin/installer-ffmpeg-master
	chmod +x /usr/bin/installer-ffmpeg-master
	bash /usr/bin/installer-ffmpeg-master

	### OFFICIAL DEBIAN PACKAGES
	apt update
	apt install -y $_PACKAGES
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


#!/bin/bash

_others()
{
	### FIREFOX
	#apt update && apt install --install-recommends -y firefox-esr
	apt purge -y firefox* && rm -vrf /home/*/.mozilla && rm -vrf /home/*/.cache/mozilla
	install -d -m 0755 /etc/apt/keyrings
	wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
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
 
	### OLLAMA
	curl -fsSL https://ollama.com/install.sh | sh
	systemctl disable ollama
	systemctl stop ollama

	### NFSIISE
    ### Copy fedata and gamedata directories from the Need For Speed™ II SE original CD-ROM into Need For Speed II SE directory.
    ### All files and directories copied from CD-ROM must have small letters on Unix-like systems!!!
    ###     Please use the Need For Speed II SE/convert_to_lowercase script if you have UPPERCASE names.
	### OPTIONAL: mangohud --dlsym nfs2se
    dpkg --add-architecture i386
    apt update
    apt install -y git libsdl2-dev:i386 gcc g++ gcc-multilib g++-multilib yasm clang lld lld:i386 mangohud mangohud:i386
    git clone https://github.com/zaps166/NFSIISE /opt/third-apps/NFSIISE
    cd /opt/third-apps/NFSIISE
    git submodule update --init --recursive
    ./compile_nfs cpp
    mv /opt/NFSIISE/Need\ For\ Speed\ II\ SE/ /opt/NeedForSpeedIISE
	rm -rf /opt/third-apps/NFSIISE
	cd /tmp
}

_daily_desktop()
{
	### QBITTORRENT-NOX
	apt install -y qbittorrent-nox
	cat <<"EOF" > /etc/systemd/system/qbittorrent-nox.service
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
Type=forking
User=someone
Group=someone
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=8080 --save-path=/home/someone
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
	systemctl daemon-reload
	systemctl start qbittorrent-nox.service
	systemctl enable qbittorrent-nox.service
	
	### PACKET TRACER NO-NETWORK
	cat <<EOF > /usr/share/applications/packet-tracer-no-network.desktop
[Desktop Entry]
Type=Application
Exec=unshare -rn /opt/pt/packettracer
Name=PacsitoTreiser NO-NETWORK
Icon=/opt/pt/art/app.png
Terminal=false
StartupNotify=true
MimeType=application/x-pkt;application/x-pka;application/x-pkz;application/x-pks;application/x-pksz;
EOF

	### IVPN-UI
	curl -fsSL https://repo.ivpn.net/stable/debian/generic.gpg | gpg --dearmor > ~/ivpn-archive-keyring.gpg
	mv ~/ivpn-archive-keyring.gpg /usr/share/keyrings/ivpn-archive-keyring.gpg
	chown root:root /usr/share/keyrings/ivpn-archive-keyring.gpg && chmod 644 /usr/share/keyrings/ivpn-archive-keyring.gpg
	cat <<EOF > /etc/apt/sources.list.d/ivpn.sources
Types: deb
URIs: https://repo.ivpn.net/stable/debian
Suites: ./generic
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/ivpn-archive-keyring.gpg
EOF
	chown root:root /etc/apt/sources.list.d/ivpn.sources && chmod 644 /etc/apt/sources.list.d/ivpn.sources
	apt update && apt install -y ivpn-ui

	### TOR
	wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/deb.torproject.org-keyring.gpg >/dev/null
	cat <<EOF > /etc/apt/sources.list.d/tor.sources
Types: deb
URIs: https://deb.torproject.org/torproject.org
Suites: $(lsb_release -cs)
Components: main
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/deb.torproject.org-keyring.gpg
EOF
	apt update && apt install --install-recommends -y tor deb.torproject.org-keyring
	systemctl stop tor.service
	systemctl disable tor.service

	### WASABI
	cat <<"EOF" > /usr/bin/installer-wasabi
#!/bin/bash
URL=$(curl --silent "https://api.github.com/repos/WalletWasabi/WalletWasabi/releases/latest" | grep browser_download_url | grep ".deb" | head -n 1 | cut -d '"' -f 4)
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    apt install -y "./$FILE"
	rm -f "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-wasabi
	bash /usr/bin/installer-wasabi

	### GOOGLE EARTH
	cat <<"EOF" > /usr/bin/installer-google-earth
#!/bin/bash
URL="https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	apt install -y "./$FILE"
	rm -f "$FILE"
	cp -v /opt/google/earth/pro/google-earth-pro.desktop /usr/share/applications/google-earth-pro.desktop
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-google-earth
	bash /usr/bin/installer-google-earth

	### MULLVAD
	curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
	cat <<EOF > /etc/apt/sources.list.d/mullvad.sources
Types: deb
URIs: https://repository.mullvad.net/deb/stable
Suites: stable
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/mullvad-keyring.asc
EOF
	apt update && apt install -y mullvad-browser

	### STEAM
	dpkg --add-architecture i386
	apt update
	apt install -y steam-installer
	apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386

	### ZOOM
    cat <<"EOF" > /usr/bin/installer-zoom
#!/bin/bash
URL="https://zoom.us/client/latest/zoom_amd64.deb"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	apt install -y "./$FILE"
	rm -f "$FILE"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-zoom
	bash /usr/bin/installer-zoom
	
	### WINE-HQ
	dpkg --add-architecture i386
	wget -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
	wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -cs)/winehq-$(lsb_release -cs).sources
	apt update && apt install --install-recommends -y winehq-devel

	### OFFICIAL OPEN JDK
	cat <<"EOF" > /usr/bin/installer-jdk
#!/bin/bash
LATEST_JDK_=$(curl --silent https://jdk.java.net/ | grep 'Ready for use' | sed -E 's/.*href="\/([0-9]+)\/.*/\1/')
URL=$(curl -s https://jdk.java.net/$LATEST_JDK_/ | grep linux-x64_bin.tar.gz | sed -E 's/.*href="([^"]+)".*/\1/' | head -n 1)
BUILD_VERSION=$(echo $URL | sed -E 's/.*\/jdk([0-9]+\.[0-9]+\.[0-9]+)\/.*/\1/')
FILE=$(basename $URL)
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -rf /opt/apps/jdk*
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    tar xf "$FILE"
    mv jdk-$BUILD_VERSION /opt/apps/
    rm -rf "$FILE"
    JAVA_HOME_PATH="/opt/apps/jdk-$BUILD_VERSION"
    export JAVA_HOME="$JAVA_HOME_PATH"
    export PATH="$PATH:$JAVA_HOME/bin"
    export CLASSPATH=".:$JAVA_HOME/lib"
    echo "export JAVA_HOME=$JAVA_HOME_PATH" | tee /etc/profile.d/jdk-path.sh > /dev/null
    echo "export PATH=\$PATH:$JAVA_HOME/bin" | tee -a /etc/profile.d/jdk-path.sh > /dev/null
    echo "export CLASSPATH=.:$JAVA_HOME/lib" | tee -a /etc/profile.d/jdk-path.sh > /dev/null
    echo "Ruta de Open JDK agregada a /etc/profile.d/jdk-path.sh para todos los usuarios."
    update-alternatives --install /usr/bin/java java "$JAVA_HOME/bin/java" 10033
    update-alternatives --install /usr/bin/javac javac "$JAVA_HOME/bin/javac" 10033
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-jdk
	bash /usr/bin/installer-jdk

	### GHIDRA
    cat <<"EOF" >/usr/bin/installer-ghidra
#!/bin/bash
URL=$(curl --silent "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest" | jq -r '.assets[] | select(.name | endswith(".zip")) | .browser_download_url' | head -n 1)
FILE=$(basename "$URL")
DIR_NAME="${FILE%.zip}"
UNZIPPED_DIR="${DIR_NAME%_*}"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -rf /opt/apps/ghidra*
    rm -f /usr/bin/ghidra
    rm -rf ghidra*.zip
    wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
    unzip -q "$FILE" -d /opt/apps
    rm -f "$FILE"
    ln -sf "/opt/apps/$UNZIPPED_DIR/ghidraRun" /usr/bin/ghidra
    bash -c "echo '[Desktop Entry]
Categories=Application;Development;
Comment=Ghidra Software Reverse Engineering Suite
Exec=/opt/apps/$UNZIPPED_DIR/ghidraRun
GenericName=Ghidra Software Reverse Engineering Suite
Icon=/opt/apps/$UNZIPPED_DIR/docs/images/GHIDRA_1.png
MimeType=
Name=Ghidra
Path=/opt/apps/$UNZIPPED_DIR
StartupNotify=false
Terminal=false
TerminalOptions=
Type=Application
Version=1.0' > /usr/share/applications/ghidra.desktop"
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-ghidra
	bash /usr/bin/installer-ghidra

	### YOUTUBE DOWNLOADER
    cat <<"EOF" >/usr/bin/installer-yt-dlp
#!/bin/bash
URL="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    apt purge -y yt-dlp
	rm -rf /opt/apps/yt-*
	rm -rf /usr/bin/yt-*
	mkdir -v -p /opt/apps/
    wget --inet4-only --https-only --show-progress -q "$URL" -O /opt/apps/yt-dlp
	chmod 755 /opt/apps/yt-dlp
	ln -sf /opt/apps/yt-dlp /usr/bin/yt-dlp
else
    echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-yt-dlp
	bash /usr/bin/installer-yt-dlp

	### NMAP
	cat <<"EOF" > /usr/bin/installer-nmap-suite
#!/bin/bash
CURRENT_DIR=$(pwd)
SOURCE_CODE_FILE=$(curl -s https://nmap.org/download | grep tar.bz2 | head -n 1 | cut -d " " -f 3)
URL="https://nmap.org/dist/$SOURCE_CODE_FILE"
INSTALL_DIR="/opt/apps/nmap-suite"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	apt purge -y nmap*
	rm -rf "$INSTALL_DIR"
	rm -rf /usr/bin/nmap /usr/bin/ncat /usr/bin/nping /usr/bin/zenmap /usr/bin/ndiff
	apt update && apt build-dep -y nmap
	mkdir -p -v /opt/apps/nmap-suite
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$SOURCE_CODE_FILE"
	tar xjf "$SOURCE_CODE_FILE"
	rm -rf "$SOURCE_CODE_FILE"
	EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "nmap-*" -print -quit)
	cd "$EXTRACTED_DIR"
	./configure --quiet --prefix="$INSTALL_DIR"
	make -j 1
	make install
	if ! grep -q "export PATH=\"\$PATH:/opt/apps/nmap-suite/bin\"" /etc/profile; then
		export PATH="$PATH:$INSTALL_DIR/bin"
		echo "export PATH=\$PATH:$INSTALL_DIR/bin" | tee /etc/profile.d/nmap-path.sh > /dev/null
		echo "Nmap PATH added for all users."
	else
		echo "La ruta de Nmap ya está configurada en /etc/profile."
	fi
	echo "$SOURCE_CODE_FILE installed successfully!"
else
	echo "Error $URL not found."
fi
cd "$CURRENT_DIR"
rm -rf "$CURRENT_DIR"/nmap-* "$SOURCE_CODE_FILE"
EOF
	chmod +x /usr/bin/installer-nmap-suite
	bash /usr/bin/installer-nmap-suite
	
	### SQLMAP
	apt purge -y sqlmap*
	rm -rf /opt/apps/sqlmap*
	rm -rf /usr/bin/sqlmap*
	mkdir -v -p /opt/apps/
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/apps/sqlmap-dev
	ln -sf /opt/apps/sqlmap-dev/sqlmap.py /usr/bin/sqlmap
	
	### FFMPEG
    cat <<"EOF" > /usr/bin/installer-ffmpeg-master
#!/bin/bash
URL="https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-linux64-gpl.tar.xz"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
    rm -rf /opt/apps/ffmpeg*
    rm -rf /usr/bin/master-ff*
    wget --inet4-only --https-only --show-progress -q "$URL"
    tar xf ffmpeg-master-latest-linux64-gpl.tar.xz
    rm -rf ffmpeg-master-latest-linux64-gpl.tar.xz
    mv -v ffmpeg-master-latest-linux64-gpl /opt/apps
    ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg /usr/bin/master-ffmpeg
    ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffplay /usr/bin/master-ffplay
    ln -sf /opt/apps/ffmpeg-master-latest-linux64-gpl/bin/ffprobe /usr/bin/master-ffprobe
else
    echo "Error: The URL '$URL' is not available."
fi
EOF
	chmod +x /usr/bin/installer-ffmpeg-master
	bash /usr/bin/installer-ffmpeg-master

	### Android SDK Platform-Tools - adb and fastboot
	cat <<"EOF" >/usr/bin/installer-android-tools
#!/bin/bash
URL="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	rm -rf /opt/apps/platform-tools*
	rm -rf /usr/bin/adb /usr/bin/fastboot
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	unzip "$FILE"
	rm -rf "$FILE"
	mv platform-tools /opt/apps
	ln -sf /opt/apps/platform-tools/adb /usr/bin/adb
	ln -sf /opt/apps/platform-tools/fastboot /usr/bin/fastboot
else
	echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-android-tools
	bash /usr/bin/installer-android-tools

	### GO LANGUAGE
	cat <<"EOF" > /usr/bin/installer-go
#!/bin/bash
ARCH="amd64"
OS="linux"
GO_URL_BASE="https://go.dev/dl"
LATEST_VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | head -n 1)
FILE="$LATEST_VERSION.$OS-$ARCH.tar.gz"
URL="$GO_URL_BASE/$FILE"
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	rm -rf /usr/local/go
	rm -rf /opt/apps/go
	tar -C /opt/apps -xzf "$FILE"
	rm -rf "$FILE"
	if ! grep -q "export PATH=\"\$PATH:/opt/apps/go/bin\"" /etc/profile; then
		echo "export PATH=\$PATH:/opt/apps/go/bin" | tee /etc/profile.d/go-path.sh > /dev/null
		echo "Ruta de Go agregada a /etc/profile.d/go-path.sh para todos los usuarios."
	else
		echo "La ruta de Go ya está configurada en /etc/profile."
	fi
	echo "Go $VERSION installed successfully!"
else
	echo "Error $URL not found."
fi
EOF
	chmod +x /usr/bin/installer-go
	bash /usr/bin/installer-go

	### LATEST PYTHON
	cat << 'EOF' | tee /usr/bin/installer-python > /dev/null
#!/bin/bash
CURRENT_DIR=$(pwd)
INSTALL_DIR="/opt/apps"
VERSION=$(curl -s https://www.python.org/ | grep Latest | head -n 1 | sed -E 's/.*Python\s([0-9.]*).*/\1/')
#VERSION=$(curl -s https://www.python.org/ | grep -oP 'Latest: <a href="/downloads/release/python-\K[0-9.]+' | head -n 1)
URL="https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tar.xz"
FILE=$(basename "$URL")
if wget --inet4-only --https-only --quiet --spider "$URL"; then
	wget --inet4-only --https-only --show-progress -q "$URL" -O "$FILE"
	apt update && apt build-dep -y python3
	tar xf "$FILE"
	mv Python-"$VERSION"
	./configure --prefix="$INSTALL_DIR"/python --enable-optimizations --enable-ipv6
	make
	make test
	make install
else
	echo "Error $URL not found."
fi
cd "$CURRENT_DIR"
rm -rf "$FILE"
rm -rf Python-"$VERSION"
EOF
	chmod +x /usr/bin/installer-python
	#bash /usr/bin/installer-python

	### OLLAMA
	curl -fsSL https://ollama.com/install.sh | sh
	systemctl disable ollama
	systemctl stop ollama

	###
	chown -R someone:someone /opt/apps/*

	mkdir -v -p /opt/songs
	touch /opt/songs/SONG{001..102}.flac
}

#_others
#_daily_desktop

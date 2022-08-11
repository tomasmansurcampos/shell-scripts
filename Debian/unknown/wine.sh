## https://wiki.winehq.org/Debian
libfaudio0_()
{
	## libfaudio0 for winehq:
	## https://forum.winehq.org/viewtopic.php?f=8&t=32192
	## https://forum.winehq.org/viewtopic.php?f=8&t=32192#p121683
	SOURCE_FILE_=/etc/apt/sources.list.d/faudio.list
	SIGNING_KEY_FILE_=/etc/apt/trusted.gpg.d/libfaudio.gpg
	dpkg --add-architecture i386
    curl https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_$(lsb_release -sr)/Release.key | gpg --dearmor | tee $SIGNING_KEY_FILE_ >/dev/null
	echo -e "deb\t[arch=amd64,i386 signed-by=$SIGNING_KEY_FILE_] https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_$(lsb_release -sr) ./" >> $SOURCE_FILE_
	apt update
	apt install -y libfaudio0 libfaudio0:i386
}
winehq_()
{
	## winehq:
	## https://wiki.winehq.org/Debian
	SOURCE_FILE_=/etc/apt/sources.list.d/winehq.list
	SIGNING_KEY_FILE_=/etc/apt/trusted.gpg.d/winehq.gpg
	dpkg --add-architecture i386
    wget -nc https://dl.winehq.org/wine-builds/winehq.key
	mv winehq.key /usr/share/keyrings/winehq-archive.key
	wget -nc https://dl.winehq.org/wine-builds/debian/dists/$(lsb_release -sc)/winehq-$(lsb_release -sc).sources
	mv winehq-$(lsb_release -sc).sources /etc/apt/sources.list.d/
	apt update
	apt install -y --install-recommends winehq-devel
}
#apt update
#apt install -y gpg wget curl lsb-release
libfaudio0_
winehq_

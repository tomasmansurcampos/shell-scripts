## https://www.mono-project.com/download/stable/#download-lin-debian
mono_()
{
	if [ "$(lsb_release -sr)" -le "10" ]; then
		SOURCE_FILE=/etc/apt/sources.list.d/mono-official-stable.list
		apt update
		apt install -y dirmngr gnupg ca-certificates
		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
		echo -e "deb\t[arch=$(dpkg --print-architecture)] http://download.mono-project.com/repo/debian stable-$(lsb_release -sc)   main" | tee $SOURCE_FILE
		apt update
		apt install -y mono-complete
	elif [ "$(lsb_release -sr)" -ge "11" ]; then
		apt install -y mono-complete
	fi
	systemctl stop mono-xsp4
	systemctl disable mono-xsp4

}
mono_

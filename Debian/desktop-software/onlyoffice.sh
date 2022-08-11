onlyoffice_()
{
	## https://helpcenter.onlyoffice.com/installation/desktop-install-ubuntu.aspx
	mkdir -p ~/.gnupg
	chmod 700 ~/.gnupg
	gpg --no-default-keyring --keyring gnupg-ring:/tmp/onlyoffice.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CB2DE8E5
	chmod 644 /tmp/onlyoffice.gpg
	chown root:root /tmp/onlyoffice.gpg
	mv /tmp/onlyoffice.gpg /etc/apt/trusted.gpg.d/
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/onlyoffice.gpg] http://download.onlyoffice.com/repo/debian squeeze main" | tee /etc/apt/sources.list.d/onlyoffice.list
	apt update
	apt install -y onlyoffice-desktopeditors
}
onlyoffice_

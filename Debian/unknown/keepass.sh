keepass2_()
{
	## see https://sourceforge.net/projects/keepass/files/
	## https://sourceforge.net/projects/keepass/files/KeePass%202.x/
	VERSION=2.51.1
	LINK=https://sourceforge.net/projects/keepass/files/KeePass%202.x/${VERSION}/KeePass-${VERSION}.zip/download
	BASE_FOLDER=/opt/software
	apt install unzip -y
	wget -q --https-only -O keepass.zip $LINK
	unzip -q keepass.zip -d $BASE_FOLDER/keepass
	chmod 755 -R $BASE_FOLDER/keepass
	rm -rf keepass.zip
	wget -q --https-only https://keepass.info/images/icons/keepass_256x256.png
	cp keepass_256x256.png /usr/share/icons/hicolor/256x256/apps/keepass.png
	echo "[Desktop Entry]
Name=KeePass
GenericName=Password manager
Exec=mono $BASE_FOLDER/keepass/KeePass.exe %f
Icon=keepass
Terminal=false
Type=Application
StartupNotify=true
Categories=Utility;
MimeType=application/x-keepass;" > /usr/share/applications/keepass.desktop
	gtk-update-icon-cache -f /usr/share/icons/hicolor
	chown user:user -R $BASE_FOLDER/
}
keepass2_

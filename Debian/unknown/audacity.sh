## https://www.audacityteam.org/download/linux/
audacity_()
{
	VERSION_=3.1.3
	LINK=https://github.com/audacity/audacity/releases/download/Audacity-$VERSION_/audacity-linux-$VERSION_-x86_64.AppImage
	BASE_FOLDER_=/opt/software
	PNG_FILE_=audacity512.png
	BIN_FILE_=audacity.appimage
	mkdir --parents $BASE_FOLDER_
	mkdir --parents $BASE_FOLDER_/audacity
	wget -q --https-only $LINK -O $BIN_FILE_
	mv $BIN_FILE_ $BASE_FOLDER_/audacity/$BIN_FILE_
	chmod +x $BASE_FOLDER_/audacity/$BIN_FILE_
	chown -R user:user $BASE_FOLDER_/audacity/$BIN_FILE_
	rm -rf /usr/bin/audacity
	ln -s $BASE_FOLDER_/audacity/$BIN_FILE_ /usr/bin/audacity
	## desktop 
	mv $PNG_FILE_ $BASE_FOLDER_/audacity
	rm -rf /usr/share/icons/hicolor/512x512/apps/audacity.png
	ln -s $BASE_FOLDER_/audacity/$PNG_FILE_ /usr/share/icons/hicolor/512x512/apps/audacity.png
	cp audacity.desktop /usr/share/applications/audacity.desktop
	gtk-update-icon-cache -f /usr/share/icons/hicolor
}
audacity_

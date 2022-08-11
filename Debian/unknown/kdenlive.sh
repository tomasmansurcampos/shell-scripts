## https://kdenlive.org/en/download/
kdenlive_()
{
	BASE_FOLDER_=/opt/software
	BIN_FILE_=kdenlive.appimage
	LINK_=https://download.kde.org/stable/kdenlive/21.12/linux/kdenlive-21.12.0-x86_64.appimage
	rm -rf $BASE_FOLDER_/kdenlive
	mkdir --parents $BASE_FOLDER_/kdenlive
	wget --https-only $LINK_ -O $BIN_FILE_
	mv $BIN_FILE_ $BASE_FOLDER_/kdenlive
	chmod +x $BASE_FOLDER_/kdenlive/$BIN_FILE_
	rm -rf /usr/bin/kdenlive
	ln -s $BASE_FOLDER_/kdenlive/$BIN_FILE_ /usr/bin/kdenlive
	cp kdenlive.desktop /usr/share/applications/kdenlive.desktop
	cp kdenlive512.png $BASE_FOLDER_/kdenlive/kdenlive512.png
	rm -rf /usr/share/icons/hicolor/512x512/apps/kdenlive.png
	ln -s $BASE_FOLDER_/kdenlive/kdenlive512.png /usr/share/icons/hicolor/512x512/apps/kdenlive.png
	gtk-update-icon-cache -f /usr/share/icons/hicolor
}
kdenlive_

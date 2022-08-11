#!/bin/bash
freac_()
{
	VERSION_=1.1.6
	LINK_="https://github.com/enzo1982/freac/releases/download/$VERSION_/freac-$VERSION_-linux-x86_64.AppImage"
	BASE_FOLDER_=/opt/software
	FILE_=freac.appimage
	mkdir --parents $BASE_FOLDER_
	wget --https-only $LINK_ -O $FILE_
	mv $FILE_ $BASE_FOLDER_
	cp freac256.png /usr/share/icons/hicolor/256x256/apps/freac.png
	cp freac.desktop /usr/share/applications/
	gtk-update-icon-cache -f /usr/share/icons/hicolor
}
freac_

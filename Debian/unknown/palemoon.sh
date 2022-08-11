#!/bin/bash
palemoon_()
{
	VERSION=31.1.0
	BASE_FOLDER=/opt/software
	mkdir --parents $BASE_FOLDER
	apt update
	apt install libstdc++6 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0
	wget -q --https-only https://linux.palemoon.org/datastore/release/palemoon-$VERSION.linux-x86_64-gtk3.tar.xz
	tar xf palemoon-$VERSION.linux-x86_64-gtk3.tar.xz
	rm -rf palemoon-$VERSION.linux-x86_64-gtk3.tar.xz
	mv palemoon/ $BASE_FOLDER
	chown user:user -R $BASE_FOLDER/palemoon
	chmod 755 -R $BASE_FOLDER/palemoon
	ln -s $BASE_FOLDER/palemoon/palemoon /usr/local/bin/palemoon
	echo "[Desktop Entry]
Version=1.0
Name=Pale Moon Web Browser
Comment=Browse the World Wide Web
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=palemoon %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/software/palemoon/browser/icons/mozicon128.png
Categories=Network;WebBrowser;Internet
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true" > /usr/share/applications/palemoon.desktop
	chown -R user:user $BASE_FOLDER
}
palemoon_

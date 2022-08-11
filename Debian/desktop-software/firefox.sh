## https://wiki.debian.org/Firefox
## https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
firefox_stable_()
{
	rm -rf /home/*/.cache/mozill*
	rm -rf /home/*/.mozill*
	rm -rf /usr/lib/mozilla/
	rm -rf /usr/lib/mozilla/*
	## firefox rolling release installation:
	## please note that the links describe in
	## https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
	## differs from the Official Firefox Website https://www.mozilla.org/en-US/firefox/all/#product-desktop-release
	## from product=firefox-latest to product=firefox-latest-ssl...
	## i follow the link that points https://www.mozilla.org/ not https://ftp.mozilla.org/pub/firefox/releases/latest/README.txt
	BASE_FOLDER_=/opt/software
	apt install -y libdbus-glib-1-2
	wget --https-only -O firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
	tar xf firefox.tar.bz2
	rm -rf firefox.tar.bz2
	mv firefox $BASE_FOLDER_
	## creation for void user:
	chown user:user -R /opt/software
	##
	rm -rf /usr/local/bin/firefox
	rm -rf /usr/bin/firefox
	ln -s $BASE_FOLDER_/firefox/firefox /usr/bin/firefox
	echo "[Desktop Entry]
Version=1.0
Name=Firefox Stable
Comment=Web Browser
Exec=firefox %u
Terminal=false
Type=Application
Icon=/opt/software/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true" > /usr/share/applications/firefox.desktop
	#update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /opt/firefox/firefox 200
	#update-alternatives --set  gnome-www-browser /opt/firefox/firefox
	#update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
	#update-alternatives --set x-www-browser /opt/firefox/firefox
	#xdg-settings set default-web-browser firefox.desktop
}
firefox_stable_

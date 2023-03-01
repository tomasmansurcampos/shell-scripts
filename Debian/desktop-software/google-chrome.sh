google_chrome_()
{
	## https://linuxnightly.com/how-to-install-google-chrome-on-debian-linux/
	LINK_="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
	wget --https-only $LINK_
	rm -rf /etc/default/google-chrome
	apt update
	apt install -y ./google-chrome-stable_current_amd64.deb
	rm -rf google-chrome-stable_current_amd64.deb
	
	echo "[Desktop Entry]
Version=1.0
Name=Google Chrome (Private)
# Only KDE 4 seems to use GenericName, so we reuse the KDE strings.
# From Ubuntu's language-pack-kde-XX-base packages, version 9.04-20090413.
GenericName=Web Browser
# Gnome and KDE 3 uses Comment.
Comment=Access the Internet
Exec=/usr/bin/google-chrome-stable --incognito %U
StartupNotify=true
Terminal=false
Icon=google-chrome
Type=Application
Categories=Network;WebBrowser;
MimeType=application/pdf;application/rdf+xml;application/rss+xml;application/xhtml+xml;application/xhtml_xml;application/xml;image/gif;image/jpeg;image/png;image/webp;text/html;text/xml;x-scheme-handler/http;x-scheme-handler/https;
Actions=new-window;new-private-window;

[Desktop Action new-window]
Name=New Window
Exec=/usr/bin/google-chrome-stable --incognito

[Desktop Action new-private-window]
Name=New Incognito Window
Exec=/usr/bin/google-chrome-stable --incognito" > /usr/share/applications/google-chrome-private.desktop
}
google_chrome_


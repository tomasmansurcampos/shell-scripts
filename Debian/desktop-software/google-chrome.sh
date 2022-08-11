google_chrome_()
{
	## https://linuxnightly.com/how-to-install-google-chrome-on-debian-linux/
	LINK_="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
	wget --https-only $LINK_
	apt update
	apt install -y ./google-chrome-stable_current_amd64.deb
	rm -rf google-chrome-stable_current_amd64.deb
}
google_chrome_


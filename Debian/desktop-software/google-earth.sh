google_earth_()
{
	wget --https-only https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb
	apt install -y ./google-earth-pro-stable_current_amd64.deb
	rm google-earth-pro-stable_current_amd64.deb
}
google_earth_

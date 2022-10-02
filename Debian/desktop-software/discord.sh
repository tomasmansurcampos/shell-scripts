discord_()
{
	## https://linuxconfig.org/how-to-install-discord-on-linux
	## https://itsfoss.com/install-discord-linux/
	BASE_FOLDER_=/usr/local
	wget --https-only -O discord.tar.gz "https://discord.com/api/download?platform=linux&format=tar.gz"
	tar xf discord.tar.gz
	rm -rf discord.tar.gz
	mv -f Discord/ $BASE_FOLDER_
	ln -sf $BASE_FOLDER_/Discord/Discord /usr/bin/discord
	ln -sf $BASE_FOLDER_/Discord/discord.png /usr/share/icons/hicolor/256x256/apps/discord.png
	echo "[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=discord
Icon=discord
Type=Application
Categories=Network;InstantMessaging;" > /usr/share/applications/discord.desktop
	gtk-update-icon-cache -f /usr/share/icons/hicolor
	chown -R $1:$1 $BASE_FOLDER_
}
discord_

## https://www.torproject.org/dist/torbrowser/
tor_browser_()
{
	VERSION_=11.5.1
	BASE_FOLDER_=/opt/software
	mkdir --parents $BASE_FOLDER_
	wget --https-only https://www.torproject.org/dist/torbrowser/${VERSION_}/tor-browser-linux64-${VERSION_}_en-US.tar.xz
	tar -xJf tor-browser-linux64-${VERSION_}_en-US.tar.xz
	rm -rf tor-browser-linux64-${VERSION_}_en-US.tar.xz
	mkdir --parents $BASE_FOLDER_
	mv tor-browser_en-US $BASE_FOLDER_
	chown user:user -R $BASE_FOLDER_
}
tor_browser_

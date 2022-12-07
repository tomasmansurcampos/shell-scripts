## https://www.torproject.org/dist/torbrowser/
version_scrapped_()
{
	
}
tor_browser_()
{
	VERSION_=12.0
	BASE_FOLDER_=/usr/local
	mkdir --parents $BASE_FOLDER_
	wget --https-only https://www.torproject.org/dist/torbrowser/${VERSION_}/tor-browser-linux64-${VERSION_}_ALL.tar.xz
	tar -xJf tor-browser-linux64-${VERSION_}_en-US.tar.xz
	rm -rf tor-browser-linux64-${VERSION_}_en-US.tar.xz
	mkdir --parents $BASE_FOLDER_
	mv tor-browser_en-US $BASE_FOLDER_
	chown -R $1:$1 $BASE_FOLDER_/tor-browser_en-US
}
tor_browser_

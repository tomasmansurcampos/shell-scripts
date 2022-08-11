telegram_()
{
	## https://desktop.telegram.org/
	BASE_FOLDER_=/opt/software
	LINK="https://telegram.org/dl/desktop/linux"
	mkdir --parents $BASE_FOLDER_
	wget --https-only $LINK -qO telegram.tar.xz
	tar xf telegram.tar.xz
	rm -rf telegram.tar.xz
	mv Telegram/ $BASE_FOLDER_
	chown user:user -R $BASE_FOLDER_
	chmod 755 -R $BASE_FOLDER_/Telegram
}
telegram_

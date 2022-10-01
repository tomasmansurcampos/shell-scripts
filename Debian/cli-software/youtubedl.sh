youtube_dl_()
{
	## https://youtube-dl.org/
	BASE_FOLDER_=$HOME
	BINARY_FILE_=$BASE_FOLDER_/youtube-dl
	mkdir --parents $BASE_FOLDER_
	rm -rf $BINARY_FILE_
	/usr/bin/wget --https-only https://yt-dl.org/downloads/latest/youtube-dl -qO $BINARY_FILE_
	ln -sf $BINARY_FILE_ /usr/local/bin/youtube-dl
	chmod +x $BINARY_FILE_
	echo "alias youtube-dl='youtube-dl --verbose'
alias youtube-dl-tor='youtube-dl --verbose --proxy socks5://127.0.0.1:9050'" >> /etc/profile.d/command_alias.sh
}
youtube_dl_

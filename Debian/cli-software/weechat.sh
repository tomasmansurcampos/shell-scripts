## https://weechat.org/download/debian/
weechat_()
{
	SOURCE_FILE_=/etc/apt/sources.list.d/weechat.list
	SINGING_KEY_FILE_=/etc/apt/trusted.gpg.d/weechat.gpg
	wget --https-only -qO- https://weechat.org/dev/info/debian_repository_signing_key/ | tee $SINGING_KEY_FILE_ >/dev/null
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$SINGING_KEY_FILE_] http://weechat.org/debian $(lsb_release -sc) main" > $SOURCE_FILE_
	apt update
	apt install -y weechat-curses weechat-plugins weechat-python weechat-perl
}
weechat_

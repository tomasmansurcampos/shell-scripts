sqlmap_()
{
	## https://github.com/sqlmapproject/sqlmap
	BASE_FOLDER_=/usr/local
	SQLMAP_FOLDER_=$BASE_FOLDER_/sqlmap-dev
	apt -y install git
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $SQLMAP_FOLDER_
	ln -sf $BASE_FOLDER_/sqlmap-dev/sqlmap.py /usr/local/bin/sqlmap
	echo "alias sqlmap='sqlmap -o --beep --force-ssl --mobile --smart'" >> /etc/profile.d/command_alias.sh
}
sqlmap_

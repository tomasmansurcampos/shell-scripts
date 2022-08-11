sqlmap_()
{
	## https://github.com/sqlmapproject/sqlmap
	BASE_FOLDER_=/opt/software
	SQLMAP_FOLDER_=$BASE_FOLDER_/sqlmap-dev
	mkdir --parents $BASE_FOLDER_
	apt -y install git
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $SQLMAP_FOLDER_
	echo "alias sqlmap='python /opt/software/sqlmap-dev/sqlmap.py -o --beep --force-ssl --mobile --smart'" >> /etc/profile.d/command_alias.sh
}
sqlmap_

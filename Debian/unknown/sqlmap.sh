sqlmap_()
{
	## https://github.com/sqlmapproject/sqlmap
	BASE_FOLDER=/opt/software
	SQLMAP_FOLDER=$FOLDER/sqlmap-dev
	mkdir --parents $BASE_FOLDER
	apt -y install git
	git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git $SQLMAP_FOLDER
	echo "alias sqlmap='python /opt/software/sqlmap-dev/sqlmap.py -o --beep --force-ssl --mobile --smart'" >> /etc/profile.d/command_alias.sh
}
sqlmap_

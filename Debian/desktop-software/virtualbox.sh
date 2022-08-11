virtual_box_()
{
	## https://www.virtualbox.org/wiki/Linux_Downloads
	SOURCE_LIST_FILE_=/etc/apt/sources.list.d/virtualbox.list
	SIGNING_KEY_FILE_=/etc/apt/trusted.gpg.d/virtual_box.gpg
	wget --https-only -qO- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor | tee $SIGNING_KEY_FILE_ >/dev/null
	echo -e "deb\t[arch=amd64 signed-by=${SIGNING_KEY_FILE_}] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" > $SOURCE_LIST_FILE_
	apt update
	apt install -y virtualbox-6.1
}
virtual_box_

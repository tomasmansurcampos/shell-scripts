#!/bin/bash
protonvpn_()
{
	KEY_LINK_="https://protonvpn.com/download/public_key.asc"
	SOURCE_FILE_=/etc/apt/sources.list.d/protonvpn.list
	GPG_KEY_FILE_=/usr/share/keyrings/protonvpn-stable.gpg
	wget --https-only -qO- $KEY_LINK_ | gpg --dearmor | tee $GPG_KEY_FILE_ >/dev/null
	echo -e "deb\t[arch=$(dpkg --print-architecture) signed-by=$GPG_KEY_FILE_] http://repo.protonvpn.com/debian stable main" > $SOURCE_FILE_
	#apt update
	#apt install -y protonvpn
}
protonvpn_

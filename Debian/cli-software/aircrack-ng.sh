#!/bin/bash
ac_()
{
	apt update
	apt install -y build-essential autoconf automake libtool pkg-config libnl-3-dev libnl-genl-3-dev libssl-dev ethtool shtool rfkill zlib1g-dev libpcap-dev libsqlite3-dev libpcre3-dev libhwloc-dev libcmocka-dev hostapd wpasupplicant tcpdump screen iw usbutils
	git clone https://github.com/aircrack-ng/aircrack-ng /usr/local/src/aircrack-ng
	cd /usr/local/src/aircrack-ng
	autoreconf -i
	./configure
	make
	make check
	make integration
	make install
	cd $HOME
}
ac_

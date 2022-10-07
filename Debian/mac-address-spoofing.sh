#!/bin/bash
mac_address_spoofing_()
{
	## Now it's time to configure permanent random mac address for every wifi adaptaer card and wired card connected to pc at boot time thanks to systemd-networkd.
	## systemd-networkd supports MAC address spoofing via link files (see systemd.link(5) for details).
	## https://wiki.archlinux.org/index.php/MAC_address_spoofing
	## mac addresses of:
	apt update
	apt install ethtool -y #this tool will get hardware mac address of device.
	INTERFACES=$(ls /sys/class/net/)
	INTERFACES=${INTERFACES/lo}
	CONFIG_FILE=/etc/systemd/network/00-default.link
	COMMAND=ethtool
	if test -f "$CONFIG_FILE"
	then
		cp $CONFIG_FILE $CONFIG_FILE.backup
	fi
	rm -rf $CONFIG_FILE
	touch $CONFIG_FILE
	if ! command -v $COMMAND &> /dev/null #Why this? In case offline configuration or apt didn't get the package, else procede with ethtool command.
	then
    	echo "ethtool software cannot be executed for some reason..."
		echo "adding mac address of local host by /sys/class/net/*/address on 00-default.link file..."
		echo -e "[Match]\n" > $CONFIG_FILE
		for i in $INTERFACES
		do
			MAC_ADDRESS=$(cat /sys/class/net/$i/address)
			echo "MACAddress=$MAC_ADDRESS" >> $CONFIG_FILE
			echo "$MAC_ADDRESS added."
		done
		echo "
[Link]
MACAddressPolicy=random
NamePolicy=kernel database onboard slot path" >> $CONFIG_FILE
	else
    	echo -e "[Match]\n" > $CONFIG_FILE
		for i in $INTERFACES
		do
			MAC_ADDRESS=$(ethtool -P $i)
			MAC_ADDRESS=${MAC_ADDRESS:19:17}
			echo "MACAddress=$MAC_ADDRESS" >> $CONFIG_FILE
		done
		echo "
[Link]
MACAddressPolicy=random
NamePolicy=kernel database onboard slot path" >> $CONFIG_FILE
	fi
	#systemctl enable systemd-networkd
}
mac_address_spoofing_

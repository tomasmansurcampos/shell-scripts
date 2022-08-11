#!/bin/sh

NETWORK_DEVICE_NAME_=$1
IPV4_ADDRESS_=$2
GATEWAY_=$3
DNS_=$4
FILE_CONFIG_=/etc/network/interfaces

#if [! -f "$FILE_CONFIG_" ];
#    cp $FILE_CONFIG_ $FILE_CONFIG_.original
#fi

echo -e "source /etc/network/interfaces.d/*\n
auto lo
iface lo inet loopback\n" > $FILE_CONFIG_

echo "allow-hotplug $NETWORK_DEVICE_NAME_
iface $NETWORK_DEVICE_NAME_ inet static" >> $FILE_CONFIG_

echo -e "\taddress $IPV4_ADDRESS_
\tnetmask 255.255.255.0
\tgateway $GATEWAY_
\tdns-nameservers $DNS_" >> $FILE_CONFIG_

systemctl restart networking.service

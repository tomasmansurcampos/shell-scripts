#!/bin/bash
microcode_installation_()## it bugs Debian with GNOME with arp or network or something, i do not know exactly.
{
	##  https://wiki.debian.org/Microcode
	vendor_processor=$(cat /proc/cpuinfo | grep vendor | uniq)
	if [[ $vendor_processor = *"Intel"* ]]; then
		apt remove amd64-microcode -y
		apt purge amd64-microcode -y
		apt autoremove -y
		apt update
		apt install intel-microcode -y
	elif [[ $vendor_processor = *"AMD"* ]]; then
		apt remove intel-microcode -y
		apt purge intel-microcode -y
		apt autoremove -y
		apt update
		apt install amd64-microcode -y
	else
		echo "pc has no intel nor amd cpu."
	fi
}


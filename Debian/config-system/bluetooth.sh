bluetooth_()
{
	apt update
	apt install -y bluetooth blueman
    CONFIG_FILE=/etc/bluetooth/main.conf
    sed -i '/#Name =/!b;cName = BlueServ' $CONFIG_FILE
    sed -i '/AutoEnable=true/!b;cAutoEnable=false' $CONFIG_FILE
	systemctl restart bluetooth.service
	pulseaudio -k
	pulseaudio -D
	pulseaudio --start
	## pulseaudio -k && pulseaudio -D && pulseaudio --start
}
}
bluetooth_

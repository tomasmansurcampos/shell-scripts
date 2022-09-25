#!/bin/bash
driver_()
{
	apt update
	apt install -y dkms ethtool
	git clone https://github.com/aircrack-ng/rtl8812au /usr/local/src/rtl8812au
	cd /usr/local/src/rtl8812au
	make dkms_install
	#options 88XXau rtw_led_ctrl=1
	#rmmod 88XXau
	#modprobe 88XXau rtw_switch_usb_mode=1 ##0 no switch, 1 usb2 to usb3.0, 2 is 1 but reverse
	cd $HOME
}
driver_

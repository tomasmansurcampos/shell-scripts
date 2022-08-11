#!/bin/bash
rpi_imager_()
{
    wget --https-only --inet4-only https://downloads.raspberrypi.org/imager/imager_latest_amd64.deb -O imager_latest_amd64.deb
    apt install -y ./imager_latest_amd64.deb
    apt update
	apt --fix-broken install -y
    rm -rf imager_latest_amd64.deb
}

#!/bin/bash
flatpak_()
{
	apt update
	apt install -y flatpak
	apt install -y gnome-software-plugin-flatpak
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	systemctl reboot
}
flatpak_

#!/bin/bash
flatpak_apps_()
{
	flatpak install flathub org.libreoffice.LibreOffice
	flatpak install flathub org.audacityteam.Audacity
	flatpak install flathub org.mixxx.Mixxx
	flatpak install flathub org.freac.freac
	flatpak install flathub com.makemkv.MakeMKV
	flatpak install flathub com.discordapp.Discord
	flatpak install flathub org.kde.kdenlive
	flatpak install flathub org.videolan.VLC
	flatpak install flathub us.zoom.Zoom
	flatpak install flathub org.qbittorrent.qBittorrent
	flatpak install flathub org.wireshark.Wireshark
	flatpak install flathub org.keepassxc.KeePassXC
	flatpak install flathub net.pcsx2.PCSX2
	flatpak install flathub com.dosbox.DOSBox
}
flatpak_apps_

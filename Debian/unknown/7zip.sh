#!/bin/bash
7zip_()
{
	VERSION_=2201
	mkdir /opt/software/
	mkdir --parents /opt/software/7zip
	wget https://www.7-zip.org/a/7z$VERSION-linux-$(dpkg --print-architecture).tar.xz
	tar -cf 7z$VERSION-linux-$(dpkg --print-architecture).tar.xz -C /opt/software/7zip
	ln -sf /opt/software/7zip/7zz /usr/bin/7zip
}
7zip_

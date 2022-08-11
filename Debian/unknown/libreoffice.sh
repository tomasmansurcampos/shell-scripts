#!/bin/sh
cp /usr/bin/libreoffice /usr/bin/libreoffice.bu
rm -rf /usr/bin/libreoffice
ln -s /opt/libreoffice7.2/program/soffice /usr/bin/libreoffice

#VERSION_=
## https://wiki.debian.org/LibreOffice#Using_the_project.27s_own_deb_packages
wget https://download.documentfoundation.org/libreoffice/stable/7.2.2/deb/x86_64/LibreOffice_7.2.2_Linux_x86-64_deb.tar.gz
tar -xvf LibreOffice_7.2.2_Linux_x86-64_deb.tar.gz
cd LibreOffice_7.2.2.2_Linux_x86-64_deb/DEBS/
apt install -y ./*.deb

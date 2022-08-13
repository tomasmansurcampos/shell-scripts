#!/bin/bash

## https://linuxhint.com/install-tftp-server-debian-11/
## https://openwrt.org/toh/tp-link/archer_c7#installation_or_restore_with_tftp_-_linux

CONFIG_FILE_=/etc/default/tftpd-hpa
apt install -y tftpd-hpa
cp $CONFIG_FILE_ $CONFIG_FILE_.original

echo '# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS="192.168.0.66:69"
TFTP_OPTIONS="-4 --secure -vvv"' > $CONFIG_FILE_

mkdir --parents /srv/tftp

mv $1 /srv/tftp/ArcherC7v5_tp_recovery.bin
chown -R tftp:tftp /srv/tftp

systemctl enable tftpd-hpa
systemctl restart tftpd-hpa
systemctl enable atftpd.service
systemctl restart atftpd.service

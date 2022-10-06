#!/bin/bash
desktop_hostname_changer_()
{
	## bash script:
	echo "#!/bin/sh
STRING='DESKTOP'
head /dev/urandom > /tmp/r
R_STRING=\$(cat /tmp/r | tr -dc 'A-Z0-9' | fold -w \${1:-7} | head -n 1)
NEW_HOSTNAME=\$STRING-\$R_STRING #example: DESKTOP-A8FLM4C
OLD_HOSTNAME=\$(hostname)
hostnamectl set-hostname \$NEW_HOSTNAME
sed -i s/\$OLD_HOSTNAME/\$NEW_HOSTNAME/g /etc/hosts
rm -rf /tmp/r" > /sbin/hostname-changer.sh
	chmod u+x /sbin/hostname-changer.sh
	## systemd servcie configuration:
	echo "[Unit]
Description=Change the hostname at startup.

[Service]
ExecStart=bash /sbin/hostname-changer.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/hostname-changer.service
	systemctl daemon-reload
	systemctl enable hostname-changer
}
desktop_hostname_changer_

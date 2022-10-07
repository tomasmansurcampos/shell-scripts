#!/bin/bash
home_server_hostname_changer_()
{
	## bash script:
	echo "#!/bin/sh
STRING_='SERVER'
head /dev/urandom > /tmp/r
R_STRING_=\$(cat /tmp/r | tr -dc '0-9' | fold -w \${1:-13} | head -n 1)
NEW_HOSTNAME_=\$STRING_-\$R_STRING_ #example: SERVER-2457824658356
OLD_HOSTNAME_=\$(hostname)
hostnamectl set-hostname \$NEW_HOSTNAME_
sed -i s/\$OLD_HOSTNAME_/\$NEW_HOSTNAME_/g /etc/hosts
rm -rf /tmp/r
	" > /sbin/hostname-changer
	chmod 755 /sbin/hostname-changer
	## systemd servcie configuration:
	echo "[Unit]
Description=Change the hostname at startup.

[Service]
ExecStart=bash /sbin/hostname-changer

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/hostname-changer.service
	systemctl daemon-reload
	systemctl enable hostname-changer
}
home_server_hostname_changer_

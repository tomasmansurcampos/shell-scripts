#!/bin/bash
static_resolv_conf_()
{
	BASH_SCRIPT_FILE_=/sbin/static-resolv-conf.sh
	SYSTEMD_SERVICE_FILE_=/etc/systemd/system/static-resolv-conf.service
	## bash script:
	echo "#!/bin/sh
chattr -i /etc/resolv.conf
echo 'nameserver 127.0.0.1' > /etc/resolv.conf
chattr +i /etc/resolv.conf" > $BASH_SCRIPT_FILE_
	chmod +x $BASH_SCRIPT_FILE_
	## systemd service:
	echo "[Unit]
Description=Set file /etc/resolv.conf static with particular configuration
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=bash /sbin/static-resolv-conf.sh

[Install]
WantedBy=multi-user.target" > $SYSTEMD_SERVICE_FILE_
	systemctl daemon-reload
	#systemctl enable static-resolv-conf
	#systemctl restart static-resolv-conf
}
static_resolv_conf_

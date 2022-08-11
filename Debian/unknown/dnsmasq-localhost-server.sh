dnsmasq_config_()
{
	FILE_=/etc/dnsmasq.conf
	#cp $FILE_ $FILE_.original
	echo "port=53
listen-address=127.0.0.1
domain-needed
bogus-priv
strict-order
server=127.0.0.3 #Tor" > $FILE_
}
systemctl disable --now systemd-resolved
dnsmasq_config_

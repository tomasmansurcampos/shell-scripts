#!/bin/ash

/etc/init.d/sysntpd stop

#uci set system.ntp=timeserver
uci set system.ntp.enabled="1"
uci set system.ntp.enable_server="1"
uci -q delete system.ntp.server
uci add_list system.ntp.server="pool.ntp.org"

uci commit system
/etc/init.d/sysntpd restart

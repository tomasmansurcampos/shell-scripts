#!/bin/ash
/etc/init.d/dnsmasq stop
uci -q delete dhcp.@dnsmasq[0].server
uci -q delete dhcp.@dnsmasq[0].doh_backup_server
uci add_list dhcp.@dnsmasq[0].server="0"
uci commit dhcp
/etc/init.d/dnsmasq start

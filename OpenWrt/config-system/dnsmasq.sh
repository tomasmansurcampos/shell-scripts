#!/bin/ash

/etc/init.d/dnsmasq stop

uci set dhcp.@dnsmasq[0].noresolv="1"
uci set dhcp.@dnsmasq[0].localuse="1"
uci set dhcp.@dnsmasq[0].cachesize="3000"
uci -q delete dhcp.@dnsmasq[0].server
uci -q delete dhcp.@dnsmasq[0].doh_backup_server
uci add_list dhcp.@dnsmasq[0].server="127.0.0.1#5453"
uci add_list dhcp.@dnsmasq[0].server="::1#5453"

uci commit dhcp
/etc/init.d/dnsmasq start

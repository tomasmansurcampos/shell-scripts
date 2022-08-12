#!/bin/ash

## https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby
## https://github.com/openwrt/packages/blob/master/net/stubby/files/README.md

/etc/init.d/stubby stop

uci set stubby.global.round_robin_upstreams="0"
uci set stubby.global.tls_connection_retries="1"
uci set stubby.global.tls_min_version="1.3"
uci set stubby.global.tls_max_version="1.3"

while uci -q delete stubby.@resolver[0]; do :; done
uci add stubby resolver
uci set stubby.@resolver[-1].address="8.8.8.8"
uci set stubby.@resolver[-1].tls_auth_name="dns.google"
uci add stubby resolver
uci set stubby.@resolver[-1].address="8.8.4.4"
uci set stubby.@resolver[-1].tls_auth_name="dns.google"

uci commit stubby
/etc/init.d/stubby start
/etc/init.d/stubby enable

#!/bin/ash

stubby_()
{
  ## https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby
  ## https://github.com/openwrt/packages/blob/master/net/stubby/files/README.md

  /etc/init.d/stubby stop

  uci set stubby.global.round_robin_upstreams="0"
  uci set stubby.global.tls_connection_retries="1"
  uci set stubby.global.tls_min_version="1.3"
  uci set stubby.global.tls_max_version="1.3"

  while uci -q delete stubby.@resolver[0]; do :; done
  ## https://dns.sb/dot/
  uci add stubby resolver
  uci set stubby.@resolver[-1].address="45.11.45.11"
  uci set stubby.@resolver[-1].tls_auth_name="dot.sb"
  uci set stubby.@resolver[-1].tls_port="853"
  uci add_list stubby.@resolver[-1].spki="sha256/0Ot+uUBCfWZkE2GFQQcIpR9GmuhWioGEl+K11FhNmHk="
  ## https://dns.sb/dot/
  uci add stubby resolver
  uci set stubby.@resolver[-1].address="185.222.222.222"
  uci set stubby.@resolver[-1].tls_auth_name="dot.sb"
  uci set stubby.@resolver[-1].tls_port="853"
  uci add_list stubby.@resolver[-1].spki="sha256/0Ot+uUBCfWZkE2GFQQcIpR9GmuhWioGEl+K11FhNmHk="

  uci commit stubby
  /etc/init.d/stubby start
  /etc/init.d/stubby enable
}

stubby_

#!/bin/ash

stubby_()
{
  ## https://openwrt.org/docs/guide-user/services/dns/dot_dnsmasq_stubby
  ## https://github.com/openwrt/packages/blob/master/net/stubby/files/README.md

  /etc/init.d/stubby stop

  uci set stubby.global.dns_transport='GETDNS_TRANSPORT_TLS'
  uci set stubby.global.tls_authentication='1'
  uci set stubby.global.round_robin_upstreams='1'
  uci set stubby.global.tls_connection_retries='6'
  uci set stubby.global.tls_min_version="1.3"
  uci set stubby.global.tls_max_version="1.3"
  uci set stubby.global.idle_timeout='10000'
  uci set stubby.global.appdata_dir="/tmp/stubby"
  uci set stubby.global.dnssec_return_status="1"

  while uci -q delete stubby.@resolver[0]; do :; done
  ## DNS.SB
  ## https://dns.sb/dot/
  uci add stubby resolver
  uci set stubby.@resolver[-1].address="45.11.45.11"
  uci set stubby.@resolver[-1].tls_auth_name="dot.sb"
  uci set stubby.@resolver[-1].tls_port="853"
  uci add_list stubby.@resolver[-1].spki="sha256/0Ot+uUBCfWZkE2GFQQcIpR9GmuhWioGEl+K11FhNmHk="
  ## DNS.SB
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

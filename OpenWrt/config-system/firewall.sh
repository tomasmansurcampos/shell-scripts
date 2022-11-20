#!/bin/ash
firewall_()
{
  uci set firewall.defaults.flow_offloading='1'
  uci commit firewall
  service firewall restart
}

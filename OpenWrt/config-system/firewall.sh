#!/bin/ash

offloading_()
{
	uci set firewall.defaults.flow_offloading='1'
	uci commit firewall
}

ssh_router_wan_access_()
{
	uci add firewall rule
	uci set firewall.@rule[-1].name='SSH Router WAN Access'
	uci set firewall.@rule[-1].src='wan'
	uci set firewall.@rule[-1].dest_port='22'
	uci set firewall.@rule[-1].target='ACCEPT'
	uci set firewall.@rule[-1].proto='tcp'
	uci commit firewall
}

ssh_server_wan_access_()
{
	uci add firewall rule
	uci set firewall.@rule[-1].name='SSH Internal Server WAN Access'
	uci set firewall.@rule[-1].src='wan'
	uci set firewall.@rule[-1].dest='lan'
	uci set firewall.@rule[-1].dest_port='1022'
	uci set firewall.@rule[-1].dest_ip='x.x.x.x'
	uci set firewall.@rule[-1].target='ACCEPT'
	uci set firewall.@rule[-1].proto='tcp'
	uci commit firewall
}

firewall_()
{
  offloading_
  ssh_router_wan_access_
  ssh_server_wan_access_
  
	service firewall restart
}

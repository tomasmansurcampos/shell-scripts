#!/bin/ash
fw_()
{
	uci add firewall rule
	uci set firewall.@rule[-1].name='Force outgoing plain DNS queries to internal DoT Stubby resolver'
}

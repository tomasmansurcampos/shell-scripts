#!/bin/bash

dns_brute_()
{
  ## https://nmap.org/nsedoc/scripts/dns-brute.html
  SCRIPT_ARGS_="dns-brute.domain=$1,dns-brute.threads=$2" ## ,newtargets -sS -p 80 ????
  nmap --script dns-brute --script-args $SCRIPT_ARGS_
}

dns_brute_ $1 $2

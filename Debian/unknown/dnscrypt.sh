## https://github.com/DNSCrypt/dnscrypt-proxy
dnscrypt_proxy_from_github_()
{
	VERSION_=2.1.1
	## architecture checker
	if [ "$(uname -m)" = "x86_64" ]; then
		ARCH_=x86_64
	elif [ "$(uname -m)" = "i386" ]; then
		ARCH_=i386
	elif [ "$(uname -m)" = "mips" ]; then
		ARCH_=mips
	elif [ "$(uname -m)" = "aarch64" ]; then
		ARCH_=arm64
	fi
	## os checker
	fi [ "$(uname -s)" = "Linux" ]; then
		OS_=linux
	elif [ "$(uname -s)" = "OpenBSD" ]; then
		OS_=openbsd
	elif [ "$(uname -s)" = "FreeBSD" ]; then
		OS_=freebsd
	elif [ "$(uname -s)" = "NetBSD" ]; then
		OS_=netbsd
	fi
	LINK=https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${VERSION_}/dnscrypt-proxy-linux_$ARCH_-${VERSION_}.tar.gz
	BASE_FOLDER_=/opt/software
	LOGS_FOLDER_=/var/log/dnscrypt-proxy

	## removing other dns servers
	apt --purge autoremove -y dnsmasq unbound bind9 dnscrypt-proxy
	systemctl stop systemd-resolved && systemctl disable systemd-resolved

	wget -q --https-only $LINK
	tar -xf dnscrypt-proxy-linux_$ARCH_-${VERSION_}.tar.gz --directory .
	mv linux-$ARCH_ $BASE_FOLDER_/dnscrypt-proxy
	echo "listen_addresses = ['0.0.0.0:53']
max_clients = 1000000 ## up to 1M request per second.
ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = false
odoh_servers = false
require_dnssec = true
require_nolog = true
require_nofilter = true
force_tcp = false
#proxy = 'socks5://127.0.0.1:9040' ## adjust the port!
timeout = 5000
keepalive = 30
cert_refresh_delay = 240
tls_disable_session_tickets = false
bootstrap_resolvers = ['127.0.0.1:1053']##['8.8.8.8:53','8.8.4.4:53']
ignore_system_dns = true
#netprobe_timeout = 60
#netprobe_address = '9.9.9.9:53'
block_ipv6 = true
block_unqualified = true
block_undelegated = true
reject_ttl = 10
forwarding_rules = 'forwarding-rules.txt'
cache = false

[captive_portals]

[local_doh]

[query_log]
	file = '/var/log/dnscrypt-proxy/query.log'
	format = 'tsv'

[nx_log]
	file = '/var/log/dnscrypt-proxy/nx.log'
	format = 'tsv'

[blocked_names]
	blocked_names_file = '/opt/software/dnscrypt-proxy/blocked-names.txt'
	log_file = '/var/log/dnscrypt-proxy/blocked-names.log'
	log_format = 'tsv'

[blocked_ips]

[allowed_names]

[allowed_ips]

[schedules]

[sources]
  ## An example of a remote source from https://github.com/DNSCrypt/dnscrypt-resolvers
  [sources.'public-resolvers']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/public-resolvers.md', 'https://download.dnscrypt.net/resolvers-list/v3/public-resolvers.md']
    cache_file = 'public-resolvers.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''

  ## Anonymized DNS relays

  [sources.'relays']
    urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md', 'https://download.dnscrypt.info/resolvers-list/v3/relays.md', 'https://ipv6.download.dnscrypt.info/resolvers-list/v3/relays.md', 'https://download.dnscrypt.net/resolvers-list/v3/relays.md']
    cache_file = 'relays.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''

[broken_implementations]
fragments_blocked = ['cisco', 'cisco-ipv6', 'cisco-familyshield', 'cisco-familyshield-ipv6', 'cleanbrowsing-adult', 'cleanbrowsing-adult-ipv6', 'cleanbrowsing-family', 'cleanbrowsing-family-ipv6', 'cleanbrowsing-security', 'cleanbrowsing-security-ipv6']

[doh_client_x509_auth]

[anonymized_dns]

skip_incompatible = false

[dns64]

[static]

  # [static.'myserver']
  # stamp = 'sdns://AQcAAAAAAAAAAAAQMi5kbnNjcnlwdC1jZXJ0Lg'" > $BASE_FOLDER_/dnscrypt-proxy/dnscrypt-proxy.toml
	echo "*.local
*.lan
eth0.me
*.workgroup
fibertel.com.ar
*fibertel.com.ar" > $BASE_FOLDER_/dnscrypt-proxy/blocked-names.txt
	echo "localhost	127.0.0.1
localhost ip6-localhost ip6-loopback	::1
ip6-allnodes	ff02::1
ip6-allrouters	ff02::2" > $BASE_FOLDER_/dnscrypt-proxy/forwarding-rules.txt
	mkdir --parents $LOGS_FOLDER_
	chown -R user:user $BASE_FOLDER_/dnscrypt-proxy/
	cd $BASE_FOLDER_/dnscrypt-proxy/
	$BASE_FOLDER_/dnscrypt-proxy/dnscrypt-proxy -service install
	echo "#!/bin/bash
systemctl restart dnscrypt-proxy.service" > /sbin/start-dns
	chmod +x /sbin/start-dns
	echo "#!/bin/bash
systemctl stop dnscrypt-proxy.service" > /sbin/stop-dns
	chmod +x /sbin/stop-dns
	/sbin/start-dns
	cd /tmp
}
dnscrypt_proxy_from_github_

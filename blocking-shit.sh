### BLOCKING ADS TRACKERS MALWARE SPYWARE TELEMETRY CRYPTOMINING BY HOSTS FILE DIRECTLY
cp /etc/hosts /etc/hosts.original
echo "#!/bin/bash

chattr -i /etc/hosts

wget --inet4-only --https-only https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts -O /etc/hosts-steven-black
wget --inet4-only --https-only https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/porn-only/hosts -O /etc/hosts-porn
wget --inet4-only --https-only https://someonewhocares.org/hosts/zero/hosts -O /etc/hosts-dan-pollock
wget --inet4-only --https-only https://raw.githubusercontent.com/badmojr/1Hosts/refs/heads/master/Lite/hosts.txt -O /etc/hosts-1hosts-lite
wget --inet4-only --https-only https://raw.githubusercontent.com/badmojr/1Hosts/refs/heads/master/Pro/hosts.txt -O /etc/hosts-1hosts-pro
wget --inet4-only --https-only https://raw.githubusercontent.com/badmojr/1Hosts/refs/heads/master/Xtra/hosts.txt -O /etc/hosts-1hosts-xtra
wget --inet4-only --https-only https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/multi.txt -O /etc/hosts-hagezi-multi
wget --inet4-only --https-only https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/ultimate.txt -O /etc/hosts-hagezi-ultimate
wget --inet4-only --https-only https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/tif.txt -O /etc/hosts-hagezi-tif
wget --inet4-only --https-only https://big.oisd.nl/domainswild2 -O /etc/hosts-oisd
wget --inet4-only --https-only https://www.github.developerdan.com/hosts/lists/ads-and-tracking-extended.txt -O /etc/hosts-ads-and-tracking-extended
wget --inet4-only --https-only https://www.github.developerdan.com/hosts/lists/tracking-aggressive-extended.txt -O /etc/hosts-tracking-aggressive-extended

tr -s '\n' < /etc/hosts-oisd > /etc/hosts-oisd-big
grep -Ev "^#|^$" /etc/hosts-oisd-big > /etc/hosts-oisd
sed 's/^/0.0.0.0 /g' /etc/hosts-oisd > /etc/hosts-oisd-big
rm -rf /etc/hosts-oisd

cat /etc/hosts.original > /etc/hosts-ad-blocker

cat /etc/hosts-steven-black >> /etc/hosts-ad-blocker
cat /etc/hosts-porn >> /etc/hosts-ad-blocker
cat /etc/hosts-dan-pollock >> /etc/hosts-ad-blocker
cat /etc/hosts-1hosts-lite >> /etc/hosts-ad-blocker
cat /etc/hosts-1hosts-pro >> /etc/hosts-ad-blocker
cat /etc/hosts-1hosts-xtra >> /etc/hosts-ad-blocker
cat /etc/hosts-hagezi-multi >> /etc/hosts-ad-blocker
cat /etc/hosts-hagezi-ultimate >> /etc/hosts-ad-blocker
cat /etc/hosts-hagezi-tif >> /etc/hosts-ad-blocker
cat /etc/hosts-oisd-big >> /etc/hosts-ad-blocker
cat /etc/hosts-ads-and-tracking-extended >> /etc/hosts-ad-blocker
cat /etc/hosts-tracking-aggressive-extended >> /etc/hosts-ad-blocker

sed -i -e 's/crash.steampowered.com/0.0.0.0/g' /etc/hosts-ad-blocker
sed -i -e 's/web.facebook.com/0.0.0.0/g' /etc/hosts-ad-blocker
sed -i -e 's/click.discord.com/0.0.0.0/g' /etc/hosts-ad-blocker

echo "0.0.0.0 www.something.com" >> /etc/hosts-ad-blocker

awk '!seen[$0]++' /etc/hosts-ad-blocker > /etc/hosts

chattr +i /etc/hosts" > /usr/bin/make-hosts-block-ads
chmod +x /usr/bin/make-hosts-block-ads
bash /usr/bin/make-hosts-block-ads

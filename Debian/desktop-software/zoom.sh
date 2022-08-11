zoom_()
{
	## https://zoom.us/download?os=linux
	FILE_=/sbin/upgrade-zoom
	cat > $FILE_ << ENDOFFILE
#!/bin/bash
rm -rf /tmp/zoom_amd64.deb
wget -q --https-only -O /tmp/zoom_amd64.deb https://zoom.us/client/latest/zoom_amd64.deb
apt update
apt install -y /tmp/zoom_amd64.deb
rm -rf /tmp/zoom_amd64.deb
apt --fix-broken install -y
ENDOFFILE
	chmod +x $FILE_
	$FILE_
}
zoom_

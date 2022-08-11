spotify_()
{
	## see https://www.spotify.com/us/download/linux/
	SOURCE_LIST_FILE=/etc/apt/sources.list.d/spotify.list
	SIGNING_KEY_FILE=/etc/apt/trusted.gpg.d/spotify.gpg
	wget --https-only -qO- https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | gpg --dearmor | tee $SIGNING_KEY_FILE >/dev/null
	echo -e "deb\t[arch=amd64 signed-by=$SIGNING_KEY_FILE] http://repository.spotify.com stable non-free" > $SOURCE_LIST_FILE
	apt update && apt install -y spotify-client
	## next is a systemd service that deletes spotify cache at start up:
	echo "#!/bin/sh
rm -rf /home/*/.cache/spotify/Storage/" > /sbin/spotify-cache-remover
	echo "[Unit]
Description=This script removes the Spotify cache stored in /home/*/.cache/spotify/Storage

[Service]
ExecStart=/bin/sh /sbin/spotify-cache-remover

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/spotify-cache-remover.service
	systemctl daemon-reload
}
spotify_


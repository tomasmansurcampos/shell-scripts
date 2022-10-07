#!/bin/bash
stubby_from_github_()
{
    PWD_=$(pwd)
	DIR_="/usr/local"
    SYSTEMD_SERVICE_FILE_=/etc/systemd/system/stubby.service
    CONFIG_FILE=$DIR_/stubby/stubby.yml
	mkdir --parents $DIR_/stubby >/dev/null 2>&1
    apt install -y gcc git cmake make libssl-dev libyaml-dev libsystemd-dev libidn2-0-dev libidn2-dev libunbound-dev libgetdns-dev
    cd /tmp
    git clone https://github.com/getdnsapi/stubby.git
    cd stubby
    cmake .
    make
    mv stubby $DIR_/stubby
	mv systemd/ $DIR_/stubby
    cp $DIR_/stubby/systemd/stubby.service $SYSTEMD_SERVICE_FILE_
    adduser --disabled-password --quiet --gecos "" stubby
    ln -sf $DIR_/stubby/stubby /usr/bin/stubby
	cp stubby.yml $DIR_/stubby/stubby.yml
    #sed -i '/"/usr/bin/stubby"/!b;c"/usr/bin/stubby -C ${CONFIG_FILE}"' $SYSTEMD_SERVICE_FILE_
    setcap 'cap_net_bind_service=+ep' /usr/local/stubby/stubby
    systemctl daemon-reload
    cd $PWD_
}
stubby_from_github_


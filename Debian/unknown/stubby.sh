#!/bin/bash
stubby_from_github_()
{
    BASE_FOLDER=/opt/software
    SYSTEMD_SERVICE_FILE_=/etc/systemd/system/stubby.service
    CONFIG_FILE=$BASE_FOLDER/stubby/stubby.yml
    mkdir --parents $BASE_FOLDER >/dev/null 2>&1
	mkdir --parents $BASE_FOLDER/stubby >/dev/null 2>&1
    apt install -y gcc git cmake make libssl-dev libyaml-dev libsystemd-dev libidn2-0-dev libidn2-dev libunbound-dev libgetdns-dev
    cd /tmp
    git clone https://github.com/getdnsapi/stubby.git
    cd stubby
    cmake .
    make
    mv stubby $BASE_FOLDER/stubby
	mv systemd/ $BASE_FOLDER/stubby
    cp $BASE_FOLDER/stubby/systemd/stubby.service $SYSTEMD_SERVICE_FILE_
    adduser --disabled-password --quiet --gecos "" stubby
    ln -s $BASE_FOLDER/stubby/stubby /usr/bin/stubby
	cp stubby.yml $BASE_FOLDER/stubby/stubby.yml
    sed -i '/"/usr/bin/stubby"/!b;c"/usr/bin/stubby -C ${CONFIG_FILE}"' $SYSTEMD_SERVICE_FILE_
    systemctl daemon-reload
}
stubby_from_github_

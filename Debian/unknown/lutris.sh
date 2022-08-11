#!/bin/bash
lutris_()
{
    SOURCES_LIST_FILE_=/etc/apt/sources.list.d/lutris.list
    SIGNING_KEY_FILE_=/etc/apt/trusted.gpg.d/lutris.gpg
    echo -e "deb\t[signed-by=${SIGNING_KEY_FILE_}] https://download.opensuse.org/repositories/home:/strycore/Debian_$(lsb_release -sr)/ ./" > /etc/apt/sources.list.d/lutris.list
    wget --https-only -qO - https://download.opensuse.org/repositories/home:/strycore/Debian_$(lsb_release -sr)/Release.key | gpg --dearmor | tee $SIGNING_KEY_FILE_ >/dev/null
    apt update
    apt install -y lutris
}
lutris_

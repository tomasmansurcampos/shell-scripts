#!/bin/bash

musl_compiler_()
{
	## https://musl.libc.org/

    BASE_FOLDER_=/opt/software
    MUSL_FOLDER_=$BASE_FOLDER_/musl

    mkdir --parents $BASE_FOLDER_ >/dev/null 2>&1
    rm -rf $MUSL_FOLDER_
    rm -rf /lib/ld-musl*
    cd /usr/local/src/musl
    make uninstall
    mkdir --parents $MUSL_FOLDER_ >/dev/null 2>&1

	apt update
    apt install -y gcc make git
    git clone git://git.musl-libc.org/musl /usr/local/src/musl
    cd /usr/local/src/musl
    ./configure --bindir=$MUSL_FOLDER_/bin --libdir=$MUSL_FOLDER_/lib --includedir=$MUSL_FOLDER_/include --syslibdir=/lib
    make -j $(expr $(nproc) - 1)
    make install
    make clean
    ln -sf /opt/software/musl/bin/musl-gcc /usr/bin/musl-gcc
    cd $HOME
}

musl_compiler_

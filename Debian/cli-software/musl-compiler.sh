#!/bin/bash

musl_compiler_()
{
	## https://musl.libc.org/

   	BASE_FOLDER_=/usr/local/share
   	MUSL_FOLDER_=$BASE_FOLDER_/musl

	if [[ -d "$MUSL_FOLDER_" ]]
	then
   		cd $MUSL_FOLDER_
   		make uninstall
   		rm -rf $MUSL_FOLDER_
   		rm -rf /lib/ld-musl*
	fi
	
	apt update
	apt install -y gcc make git
   	git clone git://git.musl-libc.org/musl /usr/local/src/musl
	mkdir --parents $MUSL_FOLDER_ >/dev/null 2>&1
   	cd /usr/local/src/musl
   	./configure --bindir=$MUSL_FOLDER_/bin --libdir=$MUSL_FOLDER_/lib --includedir=$MUSL_FOLDER_/include --syslibdir=/lib
   	make -j $(expr $(nproc) - 1)
   	make install
   	make clean
   	ln -sf $MUSL_FOLDER_/bin/musl-gcc /usr/local/bin/musl-gcc
   	cd $HOME
}

musl_compiler_

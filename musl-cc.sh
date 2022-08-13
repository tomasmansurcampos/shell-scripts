#!/bin/sh

musl_cc_()
{
	BASE_FOLDER_="~/musl-cc"
	mkdir --parents $BASE_FOLDER_
	curl -s musl.cc | grep cross | tee links
	cd $BASE_FOLDER_
	for $l_ in links:
	do
		if [[ $(wget -q --spider $l_) -eq "0" ]]; then
			wget --https-only $l_
	done
	rm -rf links
	cd ~
}

musl_cc_

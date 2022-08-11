#!/bin/bash
linux_zen_()
{
	curl 'https://liquorix.net/add-liquorix-repo.sh' | bash
	apt-get install -y linux-image-liquorix-amd64 linux-headers-liquorix-amd64
}
linux_zen_

#!/bin/bash
## https://docs.microsoft.com/en-us/powershell/scripting/install/install-debian?view=powershell-7.2
powershell_()
{
	wget --https-only https://packages.microsoft.com/config/debian/$(lsb_release -sr)/packages-microsoft-prod.deb
	apt install -y ./packages-microsoft-prod.deb
	rm -rf packages-microsoft-prod.deb
	apt update
	apt install -y powershell
}
powershell_

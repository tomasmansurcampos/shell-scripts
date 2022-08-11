steam_()
{
	## https://repo.steampowered.com/steam/

	installation_()
	{
		D_=steam.deb
		dpkg --add-architecture i386
		apt update
		wget --https-only $1 -O $D_
		apt install -y ./$D_
		rm $D_
		## steam.deb adds some third part packages like steam-libs-*
		## that because the next apt update comes.
		apt update
		## From repo.steampowered.com/steam/ this must be installed:
		apt install -y libgl1-mesa-dri:amd64 libgl1-mesa-dri:i386 libgl1-mesa-glx:amd64 libgl1-mesa-glx:i386 steam-launcher
		## from debian wiki
		apt install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386
		## from steam first time startup
		#Steam needs to install these additional packages:
		apt install -y libc6:amd64 libc6:i386 libegl1:amd64 libegl1:i386 libgbm1:amd64 libgbm1:i386 libgl1-mesa-dri:amd64 libgl1-mesa-dri:i386 libgl1:amd64 libgl1:i386 steam-libs-amd64:amd64 steam-libs-i386:i386 xterm
		## Game Fails to Launch: (Steam Works)
		## Case #1: In some cases, games may depend on system libraries outside the Steam runtime that you might not have installed, such as GTK2
		## Install the proper package:
		apt install -y libgtk2.0-0:i386
		###
		apt install -y libc6:amd64 libgl1:amd64 xdg-desktop-portal xdg-desktop-portal-gtk xterm
	}

	LINK1_=https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
	LINK2_=https://repo.steampowered.com/steam/archive/stable/steam_latest.deb

	if [[ $(wget -q --spider $LINK1_) -eq "0" ]]; then
		installation_ $LINK1_
	elif [[ $(wget -q --spider $LINK2_) -eq "0" ]]; then
		installation_ $LINK2_
	else
		echo "steam.deb not found."
	fi
}

steam_

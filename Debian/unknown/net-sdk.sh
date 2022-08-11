## https://docs.microsoft.com/en-us/dotnet/core/install/linux-debian#debian-11-
net_sdk_()
{
	## net sdk 6.0
	wget https://packages.microsoft.com/config/debian/$(lsb_release -sr)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	apt install -y ./packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb
	apt update
	apt install -y dotnet-sdk-6.0
	## https://aka.ms/dotnet-cli-telemetry
	GLOBAL_ENVIRONMENT_VARIABLES_FILE=/etc/profile.d/global-environment-variables.sh
	echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1" >> $GLOBAL_ENVIRONMENT_VARIABLES_FILE
	source /etc/profile
	source $GLOBAL_ENVIRONMENT_VARIABLES_FILE
}

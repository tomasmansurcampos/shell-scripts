speedtest_()
{
	curl -s https://install.speedtest.net/app/cli/install.deb.sh | bash
	apt update
	apt install -y speedtest
}
#speedtest_

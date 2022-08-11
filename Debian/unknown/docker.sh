## https://docs.docker.com/engine/install/debian/
docker_()
{
	SIGNING_KEY_FILE=/etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
	apt install -y ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o $SIGNING_KEY_FILE
	echo "deb [arch=$(dpkg --print-architecture) signed-by=$SIGNING_KEY_FILE] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
	apt update
#	apt install -y docker-ce docker-ce-cli containerd.io
}
docker_

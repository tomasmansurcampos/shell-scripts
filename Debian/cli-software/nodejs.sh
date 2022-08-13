#!/bin/bash

nodejs_()
{
	## https://nodejs.org/en/about/releases/
	## https://github.com/nodesource/distributions/blob/master/README.md
	VERSION_=18
	curl -fsSL https://deb.nodesource.com/setup_$VERSION_.x | bash -
	apt update
	apt install -y nodejs
}

nodejs_

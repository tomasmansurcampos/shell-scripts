#!/bin/bash

nodejs_18_dot_x_()
{
	## https://nodejs.org/en/about/releases/
	## https://github.com/nodesource/distributions/blob/master/README.md
	curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
	apt update
	apt install -y nodejs
}

nodejs_18_dot_x_

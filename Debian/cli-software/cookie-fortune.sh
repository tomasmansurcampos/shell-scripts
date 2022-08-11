cookie_fortune_()
{
	## https://stackoverflow.com/questions/414164/how-can-i-select-random-files-from-a-directory-in-bash
	SCRIPT_FILE_=/usr/bin/cookie-fortune
	apt install -y cowsay fortunes
	cat << EOF > $SCRIPT_FILE_
#!/bin/bash
main_()
{
    CHARACTER_=$(ls /usr/share/cowsay/cows/ | shuf -n 1)
    fortune -s | cowsay -f \$CHARACTER_
}
main_
exit 0
EOF
	chmod 755 $SCRIPT_FILE_
}
cookie_fortune_
/usr/bin/cookie-fortune

emacs_()
{
	USER_="user"
	## https://www.emacswiki.org/emacs/IndentingC
	apt update
	apt install --no-install-recommends -y emacs-nox emacs-el ## this way avoids exim4 installation.
	if id $USER_ &>/dev/null; then
		CONFIG_FOLDER_=/home/$USER_/.emacs.d
	elif id "root" &>/dev/null; then
		CONFIG_FOLDER_=/root/.emacs.d
	fi
	rm -rf $CONFIG_FOLDER_
	mkdir --parents $CONFIG_FOLDER_
	FILE_CONFIG_=$CONFIG_FOLDER_/init.el
	rm -rf $FILE_CONFIG_
	touch $FILE_CONFIG_
	echo "(global-linum-mode)" > $FILE_CONFIG_
	echo '(setq c-default-style "linux"
          c-basic-offset 4)' >> $FILE_CONFIG_
	if id "user" &>/dev/null; then
		chown -R $USER_:$USER_ /home/$USER_
	fi
}
emacs_

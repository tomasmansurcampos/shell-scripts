## https://github.com/rapid7/metasploit-framework/wiki/Nightly-Installers
metasploit_framework_()
{
	curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
	chmod 755 msfinstall
	./msfinstall
}
metasploit_framework_

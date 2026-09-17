sudo systemctl restart fwupd
fwupdmgr get-devices
sudo fwupdmgr refresh --force
fwupdmgr get-updates
sudo fwupdmgr update


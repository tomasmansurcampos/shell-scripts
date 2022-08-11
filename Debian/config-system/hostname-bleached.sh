#!/bin
HN_=$(hostname)
sed -i s/$HN_/''/g /etc/hosts
hostnamectl set-hostname ''
rm -rf /etc/hostname
echo "" > /proc/sys/kernel/hostname

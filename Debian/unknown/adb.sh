#!/bin/bash

android_udev_rules_()
{
  BASE_FOLDER_=/opt/software
  mkdir --parents $BASE_FOLDER_
  git clone https://github.com/M0Rf30/android-udev-rules.git
  mv android-udev-rules $BASE_FOLDER_
  cd $BASE_FOLDER_/android-udev-rules
  rm -rf /etc/udev/rules.d/51-android.rules
  cp -v $BASE_FOLDER_/android-udev-rules/51-android.rules /etc/udev/rules.d/51-android.rules
  ln -sf "$PWD"/51-android.rules /etc/udev/rules.d/51-android.rules
  chmod a+r /etc/udev/rules.d/51-android.rules
  cp android-udev.conf /usr/lib/sysusers.d/
  systemd-sysusers
  gpasswd -a $(whoami) adbusers
  if id "user" &>/dev/null; then
    gpasswd -a user adbusers
    chown -R user:user $BASE_FOLDER_
  fi
  udevadm control --reload-rules
  systemctl restart systemd-udevd.service
  #adb kill-server
  #adb devices
}

adb_()
{
  LINK_="https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
  BASE_FOLDER_=/opt/software
  mkdir --parents $BASE_FOLDER_
  rm -rf $BASE_FOLDER_/platform-tools
  rm -rf $BASE_FOLDER_/android-udev-rules
  wget -q --https-only $LINK_
  unzip -qq platform-tools-latest-linux.zip
  mv platform-tools $BASE_FOLDER_
  echo 'export PATH="/opt/software/platform-tools:$PATH"' >> /etc/profile.d/path.sh
  android_udev_rules_
  if id "user" &>/dev/null; then
    chown -R user:user $BASE_FOLDER_
  fi
}

adb_

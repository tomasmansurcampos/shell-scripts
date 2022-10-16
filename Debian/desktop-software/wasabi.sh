#!/bin/bash
wasabi_()
{
  VERSION_=$(curl --silent "https://api.github.com/repos/zkSNACKs/WalletWasabi/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  wget --https-only https://github.com/zkSNACKs/WalletWasabi/releases/download/$VERSION_/Wasabi-"${VERSION_:1}".deb
  /usr/bin/apt install -y Wasabi-"${VERSION_:1}".deb
  rm -rf Wasabi-"${VERSION_:1}".deb
}
wasabi_
## https://github.com/zkSNACKs/WalletWasabi/releases/latest
## http://wasabiukrxmkdgve5kynjztuovbg43uxcbcxn6y2okcrsg7gb6jdmbad.onion/
wasabi_bitcoin_wallet_()
{
	WASABI_VERSION=1.1.13
	get -q --https-only -O wasabi.deb "https://github.com/zkSNACKs/WalletWasabi/releases/download/v${WASABI_VERSION}/Wasabi-${WASABI_VERSION}.deb"
	apt install ./wasabi.deb
	rm -rf wasabi.deb
}

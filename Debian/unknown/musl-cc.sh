musl_cc_()
{
	BASE_FOLDER_=/opt/musl-cc
	mkdir --parents $BASE_FOLDER_
	curl -s musl.cc | grep mips | tee links
	wget --https-only --input-file=links
	rm -rf links
}
#musl_cc_

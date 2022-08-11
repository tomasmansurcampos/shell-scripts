## https://ffmpeg.org/download.html
## https://johnvansickle.com/ffmpeg/
ffmpeg_()
{
	BASE_FOLDER_=/opt/software
	ARCH_=$(dpkg --print-architecture)
    mkdir --parents $BASE_FOLDER_
	wget --https-only https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-$ARCH_-static.tar.xz
	tar -xf ffmpeg-git-$ARCH_-static.tar.xz
	rm -rf ffmpeg-git-$ARCH_-static.tar.xz
	rm -rf $BASE_FOLDER_/ffmpeg*
	mv ffmpeg-git-*-$ARCH_-static $BASE_FOLDER_
	rm -rf /usr/bin/ffmpeg /usr/bin/ffprobe /usr/bin/qt-faststart
	ln -s $BASE_FOLDER_/ffmpeg-git-*-$ARCH_-static/ffmpeg /usr/bin/ffmpeg
	ln -s $BASE_FOLDER_/ffmpeg-git-*-$ARCH_-static/ffprobe /usr/bin/ffprobe
	ln -s $BASE_FOLDER_/ffmpeg-git-*-$ARCH_-static/qt-faststart /usr/bin/qt-faststart
	apt install -y ./ffmpeg
}
ffmpeg_

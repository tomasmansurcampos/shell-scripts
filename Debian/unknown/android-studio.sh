#!/bin/sh
android_studio_()
{
    BASE_FOLDER_=/opt/software
    echo "[Desktop Entry]
Name=Android Studio
Version=1.0
Comment=Build apps on every type of Android device.
GenericName=Android Studio
Exec=$BASE_FOLDER_/android-studio/bin/studio.sh
Icon=androidstudio
Type=Application
Terminal=false
StartupNotify=false
StartupWMClass=AndroidStudio
Categories=Development;IDE;
MimeType=text/plain;inode/directory;application;" >> /usr/share/applications/android-studio.desktop
    cp androidstudio32.png $BASE_FOLDER_/android-studio/icon.png
    ln -sf $BASE_FOLDER_/android-studio/icon.png /usr/share/icons/hicolor/32x32/apps/androidstudio.png
    gtk-update-icon-cache -f /usr/share/icons/hicolor
}
android_studio_

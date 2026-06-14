#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm glu

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

# If the application needs to be manually built that has to be done down here
echo "Getting binary..."
echo "---------------------------------------------------------------"

link=https://github.com/defold/defold/releases/latest/download/Defold-x86_64-linux.tar.gz
if ! wget --retry-connrefused --tries=30 "$link" -O /tmp/tarball.tar.gz 2>/tmp/download.log; then
	cat /tmp/download.log
	exit 1
fi

mkdir -p ./AppDir/bin
tar xfv /tmp/tarball.tar.gz
mv -v ./Defold/* ./AppDir/bin
cp -v ./AppDir/bin/logo_blue.png ./AppDir/Defold.png
cp -v ./AppDir/bin/logo_blue.png ./AppDir/.DirIcon
rm -rf /tmp/tarball.tar.gz ./Defold

awk -F'/' '/Location:/{print $(NF-1); exit}' /tmp/download.log > ~/version


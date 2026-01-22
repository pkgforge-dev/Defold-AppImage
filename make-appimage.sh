#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q defold-bin | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/128x128/apps/defold.png
export DESKTOP=/usr/share/applications/Defold.desktop
export DEPLOY_OPENGL=1

# Deploy dependencies
mkdir -p ./AppDir/bin
cp -r /opt/Defold/* ./AppDir/bin

# this nonsense is needed, otherwise ldd cannot find libraries
# how does this application work at all??? running ldd on the /opt also shows missing libs
( 
	cd ./AppDir/bin/packages/jdk*/lib
	find ./*/* -type f -name '*.so' -exec ln -s {} ./ \; || :
)
quick-sharun ./AppDir/bin/* ./AppDir/bin/packages/jdk*/bin/* ./AppDir/bin/packages/jdk*/lib/*

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

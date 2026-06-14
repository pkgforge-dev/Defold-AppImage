#!/bin/sh

set -eu

ARCH=$(uname -m)
# example command to get version of application here
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DEPLOY_OPENGL=1

# this nonsense is needed, otherwise ldd cannot find libraries
# how does this application work at all??? running ldd on the /opt also shows missing libs
(
	cd ./AppDir/bin/packages/jdk*/lib
	find ./*/* -type f -name '*.so' -exec ln -s {} ./ \; || :
)
quick-sharun ./AppDir/bin/* ./AppDir/bin/packages/jdk*/bin/* ./AppDir/bin/packages/jdk*/lib/*

# we also have to do this again after deployment
(
	cd ./AppDir/shared/lib
	find ../../bin/packages/ -type f -name '*.so*' -exec ln -s {} ./ \; || :
)

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage

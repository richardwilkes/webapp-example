#!/usr/bin/env bash
set -eo pipefail

APP_NAME=example
APP_BUNDLE_NAME=Example
APP_VERSION=0.3.0
APP_VERSION_SHORT=0.3
BUNDLE_ID=com.trollworks.example
COPYRIGHT_YEARS=2018-2019
COPYRIGHT_OWNER="Richard A. Wilkes"

# Setup OS_TYPE
case $(uname -s) in
	Darwin*)  OS_TYPE=darwin ;;
	#Linux*)   OS_TYPE=linux ;;
	MINGW64*) OS_TYPE=windows ;;
	*)        echo "Unsupported OS"; false ;;
esac

# Setup GIT_VERSION
if which git 2>&1 > /dev/null; then
	if [ -z "$(git status --porcelain)" ]; then
		STATE=clean
	else
		STATE=dirty
	fi
	GIT_VERSION=$(git rev-parse HEAD)-$STATE
else
	GIT_VERSION=Unknown
fi

# Ensure the build number is set to something
if [ -z $BUILD_NUMBER ]; then
	BUILD_NUMBER=Unknown
fi

# Setup tools we need
TOOLS_DIR=$PWD/tools
mkdir -p $TOOLS_DIR
export PATH=$TOOLS_DIR:$PATH
go build -o $TOOLS_DIR/cef github.com/richardwilkes/cef
cef install

# Prepare platform-specific distribution bundle
cef dist \
	--bundle "$APP_BUNDLE_NAME" \
	--executable "$APP_NAME" \
	--icon AppIcon.icns \
	--release "$APP_VERSION" \
	--short-release "$APP_VERSION_SHORT" \
	--year "$COPYRIGHT_YEARS" \
	--owner "$COPYRIGHT_OWNER" \
	--id $BUNDLE_ID
case $OS_TYPE in
	darwin)
		touch "dist/macos/$APP_BUNDLE_NAME.app" # Causes Finder to refresh its state
		TARGET_EXE="dist/macos/$APP_BUNDLE_NAME.app/Contents/MacOS/$APP_NAME"
		;;
	windows)
		TARGET_EXE="dist/windows/$APP_NAME.exe"
		;;
	*)
		echo "Unsupported OS"
		false
		;;
esac

go build -o "$TARGET_EXE" -v \
	-ldflags=all="-X github.com/richardwilkes/toolbox/cmdline.AppVersion=$APP_VERSION_SHORT -X github.com/richardwilkes/toolbox/cmdline.GitVersion=$GIT_VERSION -X github.com/richardwilkes/toolbox/cmdline.BuildNumber=$BUILD_NUMBER" \
	./main.go

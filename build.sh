#!/usr/bin/env bash
set -eo pipefail

APP_NAME=example
APP_BUNDLE_DISPLAY_NAME=Example
APP_BUNDLE_NAME=Example
APP_VERSION=0.1.0
APP_VERSION_SHORT=0.1
BUNDLE_ID=com.trollworks.example
COPYRIGHT_YEARS=2018
COPYRIGHT_OWNER="Richard A. Wilkes"

# Setup OS_TYPE
case `uname -s` in
    Darwin*)  OS_TYPE=darwin ;;
    Linux*)   OS_TYPE=linux ;;
    Win*)     OS_TYPE=windows ;;
    *)        echo "Unsupported OS"; false ;;
esac

# Setup GIT_VERSION
if which git 2>&1 > /dev/null; then
    if [ -z "`git status --porcelain`" ]; then
        STATE=clean
    else
        STATE=dirty
    fi
    GIT_VERSION=`git rev-parse HEAD`-$STATE
else
    GIT_VERSION=Unknown
fi

# Ensure the build number is set to something
if [ -z $BUILD_NUMBER ]; then
    BUILD_NUMBER=Unknown
fi

# Link to the webapp cef tree so builds can work
if [ ! -e $GOPATH/src/github.com/richardwilkes/webapp ]; then
    echo "The github.com/richardwilkes/webapp repo must be checked out"
    false
fi
pushd $GOPATH/src/github.com/richardwilkes/webapp
./setup.sh
popd
/bin/rm -f cef
ln -s $GOPATH/src/github.com/richardwilkes/webapp/cef

# Prepare platform-specific distribution bundle
/bin/rm -rf dist/$OS_TYPE
mkdir -p dist/$OS_TYPE
case $OS_TYPE in
    darwin)
        TARGET_EXE="dist/$OS_TYPE/$APP_NAME.app/Contents/MacOS/$APP_NAME"
        mkdir -p "dist/$OS_TYPE/$APP_NAME.app/Contents/Frameworks/$APP_NAME Helper.app/Contents/MacOS"
        mkdir -p "dist/$OS_TYPE/$APP_NAME.app/Contents/MacOS"
        mkdir -p "dist/$OS_TYPE/$APP_NAME.app/Contents/Resources"
        cp -R "cef/Release/Chromium Embedded Framework.framework" "dist/$OS_TYPE/$APP_NAME.app/Contents/Frameworks/"
        cp AppIcon.icns "dist/$OS_TYPE/$APP_NAME.app/Contents/Resources/AppIcon.icns"
        cat > dist/$OS_TYPE/$APP_NAME.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleDisplayName</key>
	<string>$APP_BUNDLE_DISPLAY_NAME</string>
	<key>CFBundleName</key>
	<string>$APP_BUNDLE_NAME</string>
	<key>CFBundleExecutable</key>
	<string>$APP_NAME</string>
	<key>CFBundleIconFile</key>
	<string>AppIcon.icns</string>
	<key>CFBundleIdentifier</key>
	<string>$BUNDLE_ID</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>$APP_VERSION</string>
	<key>CFBundleShortVersionString</key>
	<string>$APP_VERSION_SHORT</string>
	<key>NSHumanReadableCopyright</key>
	<string>© $COPYRIGHT_YEARS by $COPYRIGHT_OWNER. All rights reserved.</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSSupportsAutomaticGraphicsSwitching</key>
	<true/>
</dict>
</plist>
EOF
        cat > "dist/$OS_TYPE/$APP_NAME.app/Contents/Frameworks/$APP_NAME Helper.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleDisplayName</key>
	<string>$APP_BUNDLE_DISPLAY_NAME Helper</string>
	<key>CFBundleName</key>
	<string>$APP_BUNDLE_NAME Helper</string>
	<key>CFBundleExecutable</key>
	<string>$APP_NAME Helper</string>
	<key>CFBundleIdentifier</key>
	<string>$BUNDLE_ID.helper</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleVersion</key>
	<string>$APP_VERSION</string>
	<key>CFBundleShortVersionString</key>
	<string>$APP_VERSION_SHORT</string>
	<key>NSHumanReadableCopyright</key>
	<string>© $COPYRIGHT_YEARS by $COPYRIGHT_OWNER. All rights reserved.</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSSupportsAutomaticGraphicsSwitching</key>
	<true/>
</dict>
</plist>
EOF
        ;;
    linux)    echo "Not implemented yet"; false ;;
    windows)  echo "Not implemented yet"; false ;;
    *)        echo "Unsupported OS"; false ;;
esac

go build -o "$TARGET_EXE" -v \
    -ldflags=all="-X github.com/richardwilkes/toolbox/cmdline.AppVersion=$VERSION -X github.com/richardwilkes/toolbox/cmdline.GitVersion=$GIT_VERSION -X github.com/richardwilkes/toolbox/cmdline.BuildNumber=$BUILD_NUMBER" \
    ./main.go

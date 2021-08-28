#!/bin/sh

# Run from SRCROOT

cp libCwtch.dylib build/macos/Build/Products/Release/ui.app/Contents/Frameworks/
cp -r /Applications/Tor\ Browser.app/Contents/MacOS/Tor build/macos/Build/Products/Release/ui.app/Contents/MacOS/

rm cwtch.dmg
rm -r macos_dmg
mkdir macos_dmg
cp -r "build/macos/Build/Products/Release/ui.app" macos_dmg/

create-dmg \
	--volname "cwtch" \
	--volicon "macos/cwtch.icns" \
	--window-pos 200 120 \
	--window-size 800 400 \
	--icon-size 100 \
	--icon "ui.app" 200 190 \
	--hide-extension "ui.app" \
	--app-drop-link 600 185 \
	"cwtch.dmg" \
	macos_dmg

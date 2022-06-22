#!/bin/sh

# Run from SRCROOT

cp libCwtch.x64.dylib build/macos/Build/Products/Release/Cwtch.app/Contents/Frameworks/
cp libCwtch.arm.dylib build/macos/Build/Products/Release/Cwtch.app/Contents/Frameworks/
cp -r macos/Tor build/macos/Build/Products/Release/Cwtch.app/Contents/MacOS/

rm Cwtch.dmg
rm -r macos_dmg
mkdir macos_dmg
cp -r "build/macos/Build/Products/Release/Cwtch.app" macos_dmg/

# https://github.com/create-dmg/create-dmg
create-dmg \
	--volname "Cwtch" \
	--volicon "macos/cwtch.icns" \
	--window-pos 200 120 \
	--window-size 800 400 \
	--icon-size 100 \
	--icon "Cwtch.app" 200 190 \
	--hide-extension "Cwtch.app" \
	--app-drop-link 600 185 \
	"Cwtch.dmg" \
	macos_dmg

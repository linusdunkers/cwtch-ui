#!/bin/sh

orig=assets/core/knott-white.svg

# app icon used in profile manager bar
inkscape -w 512 -h 512 -e assets/core/knott-white.png $orig

# linux deploy icon
inkscape -w 512 -h 512 -e linux/cwtch.png $orig
inkscape -w 512 -h 512 -e cwtch.png $orig

# windows icons
inkscape -w 256 -h 256 -e windows/runner/resources/knot_256.png $orig
convert windows/runner/resources/knot_256.png windows/runner/resources/knot_256.ico
inkscape -w 128 -h 128 -e windows/runner/resources/knot_128.png $orig
convert windows/runner/resources/knot_128.png windows/runner/resources/knot_128.ico
inkscape -w 64 -h 64 -e windows/runner/resources/knot_64.png $orig
convert windows/runner/resources/knot_64.png windows/runner/resources/knot_64.ico
inkscape -w 48 -h 48 -e windows/runner/resources/knot_48.png $orig
convert windows/runner/resources/knot_48.png windows/runner/resources/knot_48.ico
inkscape -w 32 -h 32 -e windows/runner/resources/knot_32.png $orig
convert windows/runner/resources/knot_32.png windows/runner/resources/knot_32.ico
inkscape -w 16 -h 16 -e windows/runner/resources/knot_16.png $orig
convert windows/runner/resources/knot_16.png windows/runner/resources/knot_16.ico

# android icons
inkscape -w 48 -h 48 -e android/app/src/main/res/mipmap-mdpi/knott.png $orig
inkscape -w 72 -h 72 -e android/app/src/main/res/mipmap-hdpi/knott.png $orig
inkscape -w 96 -h 96 -e android/app/src/main/res/mipmap-xhdpi/knott.png $orig
inkscape -w 144 -h 144 -e android/app/src/main/res/mipmap-xxhdpi/knott.png $orig
inkscape -w 192 -h 192 -e android/app/src/main/res/mipmap-xxxhdpi/knott.png $orig

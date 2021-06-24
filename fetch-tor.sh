#!/bin/sh

wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-0.4.5.9-linux-x86_64 -O linux/tor
chmod a+x linux/tor

mkdir -p android/app/src/main/jniLibs/arm64-v8a
wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-0.4.4.9-arm64_pie -O android/app/src/main/jniLibs/arm64-v8a/libtor.so
chmod a+x android/app/src/main/jniLibs/arm64-v8a/libtor.so

mkdir -p android/app/src/main/jniLibs/armeabi-v7a
wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-0.4.4.9-arm_pie -O android/app/src/main/jniLibs/armeabi-v7a/libtor.so
chmod a+x android/app/src/main/jniLibs/armeabi-v7a/libtor.so

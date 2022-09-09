#!/bin/sh

cd linux
wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-0.4.7.8-linux-x86_64.tar.gz -O tor.tar.gz
tar -xzf tor.tar.gz
cd ..

mkdir -p android/app/src/main/jniLibs/arm64-v8a
wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-0.4.7.10-arm64 -O android/app/src/main/jniLibs/arm64-v8a/libtor.so
chmod a+x android/app/src/main/jniLibs/arm64-v8a/libtor.so

mkdir -p android/app/src/main/jniLibs/armeabi-v7a
wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-0.4.7.10-arm7 -O android/app/src/main/jniLibs/armeabi-v7a/libtor.so
chmod a+x android/app/src/main/jniLibs/armeabi-v7a/libtor.so

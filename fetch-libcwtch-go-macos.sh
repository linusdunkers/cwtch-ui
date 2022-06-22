#!/bin/sh

VERSION=`cat LIBCWTCH-GO-MACOS.version`
echo $VERSION

curl https://build.openprivacy.ca/files/libCwtch-go-macos-$VERSION/libCwtch.x64.dylib --output libCwtch.x64.dylib
curl https://build.openprivacy.ca/files/libCwtch-go-macos-$VERSION/libCwtch.arm.dylib --output libCwtch.arm.dylib


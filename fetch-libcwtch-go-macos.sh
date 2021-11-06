#!/bin/sh

VERSION=`cat LIBCWTCH-GO-MACOS.version`
echo $VERSION

curl https://build.openprivacy.ca/files/libCwtch-go-macos-$VERSION/libCwtch.dylib --output libCwtch.dylib

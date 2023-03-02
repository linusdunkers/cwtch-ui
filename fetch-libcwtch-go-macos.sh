#!/bin/sh

VERSION=`cat LIBCWTCH-GO-MACOS.version`
echo $VERSION

curl --fail https://build.openprivacy.ca/files/libCwtch-autobindings-$VERSION/libCwtch.x64.dylib --output libCwtch.x64.dylib
curl --fail https://build.openprivacy.ca/files/libCwtch-autobindings-$VERSION/libCwtch.arm64.dylib --output libCwtch.arm64.dylib


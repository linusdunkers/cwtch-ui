#!/bin/sh

VERSION=`cat LIBCWTCH-GO.version`
echo $VERSION

curl --fail  https://build.openprivacy.ca/files/libCwtch-go-$VERSION/cwtch.aar --output android/cwtch/cwtch.aar
curl --fail  https://build.openprivacy.ca/files/libCwtch-go-$VERSION/libCwtch.so --output linux/libCwtch.so
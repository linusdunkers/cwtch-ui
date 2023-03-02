#!/bin/sh

VERSION=`cat LIBCWTCH-GO.version`
echo $VERSION

curl --fail  https://build.openprivacy.ca/files/libCwtch-autobindings-$VERSION/cwtch.aar --output android/cwtch/cwtch.aar
curl --fail  https://build.openprivacy.ca/files/libCwtch-autobindings-$VERSION/libCwtch.so --output linux/libCwtch.so
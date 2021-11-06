#!/bin/sh

VERSION=`cat LIBCWTCH-GO.version`
echo $VERSION

wget https://build.openprivacy.ca/files/libCwtch-go-$VERSION/cwtch.aar -O android/cwtch/cwtch.aar
wget https://build.openprivacy.ca/files/libCwtch-go-$VERSION/libCwtch.so -O linux/libCwtch.so

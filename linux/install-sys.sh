#!/bin/sh

cp cwtch /usr/bin/

cp cwtch.png /usr/share/icons

mkdir -p /usr/share/cwtch
cp -r data /usr/share/cwtch

mkdir -p /usr/lib/cwtch
cp -r lib/* /usr/lib/cwtch

cp cwtch.sys.desktop /usr/share/applications/cwtch.desktop

#!/bin/sh

mv build/linux/x64/release/bundle/cwtch build/linux/x64/release/bundle/lib/cwtch
cp linux/*.desktop build/linux/x64/release/bundle/
cp linux/cwtch.*.sh build/linux/x64/release/bundle/
cp linux/install-*.sh build/linux/x64/release/bundle/
cp linux/cwtch-*.yml build/linux/x64/release/bundle/
cp linux/cwtch build/linux/x64/release/bundle/
cp README.md build/linux/x64/release/bundle/
cp linux/cwtch.png build/linux/x64/release/bundle/
cp linux/libCwtch.so build/linux/x64/release/bundle/lib/
cp -r linux/Tor build/linux/x64/release/bundle/lib

#!/bin/sh

cd macos
curl https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-macos-0.4.7.8.tar.gz --output tor.tar.gz
tar -xzf tor.tar.gz
chmod a+x Tor/tor.real
cd ..

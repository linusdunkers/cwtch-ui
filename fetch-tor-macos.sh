#!/bin/sh

cd macos
curl https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-macos-0.4.6.7.tar.gz --output tor.tar.gz
tar -xzf tor.tar.gz
chmod a+x Tor/tor.real
cd ..

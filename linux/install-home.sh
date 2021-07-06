#!/bin/sh

mkdir -p ~/.local/bin
sed "s|~|$HOME|g" cwtch.home.sh > ~/.local/bin/cwtch

mkdir -p ~/.local/share/icons
cp cwtch.png ~/.local/share/icons

mkdir -p ~/.local/share/cwtch
cp -r data ~/.local/share/cwtch

mkdir -p ~/.local/lib/cwtch
cp -r lib/* ~/.local/lib/cwtch

mkdir -p ~/.local/share/applications
sed "s|~|$HOME|g" cwtch.home.desktop > $HOME/.local/share/applications/cwtch.desktop
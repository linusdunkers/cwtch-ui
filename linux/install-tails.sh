#!/bin/sh

mkdir -p ~/.local/bin
sed "s|~|$HOME|g" cwtch.home.sh > ~/.local/bin/cwtch
chmod a+x ~/.local/bin/cwtch

mkdir -p ~/.local/share/icons
cp cwtch.png ~/.local/share/icons

mkdir -p ~/.local/share/cwtch
cp -r data ~/.local/share/cwtch

mkdir -p ~/.local/lib/cwtch
cp -r lib/* ~/.local/lib/cwtch

mkdir -p ~/.local/share/applications
sed "s|~|$HOME|g" cwtch.home.desktop > $HOME/.local/share/applications/cwtch.desktop
chmod a+x $HOME/.local/share/applications/cwtch.desktop

# Tails needs to be have been setup up with an Administration account
# https://tails.boum.org/doc/first_steps/welcome_screen/administration_password/
# Make Auth Cookie Readable
sudo chmod o+r /var/run/tor/control.authcookie
# Copy Onion Grater Config
sudo cp cwtch-tails.yml /etc/onion-grater.d/cwtch.yml
# Restart Onion Grater so the Config Takes effect
sudo systemctl restart onion-grater.service
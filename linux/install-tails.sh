#!/bin/sh

INSTALL_PREFIX=$HOME/.local DESKTOP_PREFIX=$INSTALL_PREFIX ./install.sh

# Add CWTCH_TAILS=true to run script
sed -i "s|env LD|env CWTCH_TAILS=true LD|g" $INSTALL_PREFIX/bin/cwtch

# Tails needs to be have been setup up with an Administration account
# https://tails.boum.org/doc/first_steps/welcome_screen/administration_password/
# Make Auth Cookie Readable
sudo chmod o+r /var/run/tor/control.authcookie
# Copy Onion Grater Config
sudo cp cwtch-tails.yml /etc/onion-grater.d/cwtch.yml
# Restart Onion Grater so the Config Takes effect
sudo systemctl restart onion-grater.service
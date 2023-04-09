#!/bin/sh

# Script to install Cwtch to assigned location, taking the cwtch.template.* files and customizing them appropriately
# Requires args
#   INSTALL_PREFIX: the directory to install everything under
#   DESKTOP_PREFIX: the directoy to tell the .destkop file things are installed in (usually the same, but could
#                   differ in cases of chroots or installing to a directory to be packaged and installed later (.deb prep)

if [ -z ${INSTALL_PREFIX} ]; then
	echo "\$INSTALL_PREFIX unset, required"
	exit
fi

if [ -z ${DESKTOP_PREFIX} ]; then
	echo "\$DESKTOP_PREFIX unset, required"
	exit
fi

echo "Installing Cwtch to INSTALL_PREFIX: $INSTALL_PREFIX with DESKTOP_PREFIX: $DESKTOP_PREFIX"

mkdir -p $INSTALL_PREFIX/bin
sed "s|PREFIX|$DESKTOP_PREFIX|g" cwtch.template.sh > $INSTALL_PREFIX/bin/cwtch
chmod a+x $INSTALL_PREFIX/bin/cwtch

mkdir -p $INSTALL_PREFIX/share/icons
cp cwtch.png $INSTALL_PREFIX/share/icons

mkdir -p $INSTALL_PREFIX/share/cwtch
cp -r data $INSTALL_PREFIX/share/cwtch

mkdir -p $INSTALL_PREFIX/lib/cwtch
cp -r lib/* $INSTALL_PREFIX/lib/cwtch

mkdir -p $INSTALL_PREFIX/share/applications
sed "s|PREFIX|$DESKTOP_PREFIX|g" cwtch.template.desktop > $INSTALL_PREFIX/share/applications/cwtch.desktop
chmod a+x $INSTALL_PREFIX/share/applications/cwtch.desktop

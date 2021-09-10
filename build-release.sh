#!/bin/sh

if [ -z "$1" ]; then
  echo "build-release.sh [android|linux|macos|windows]"
  exit 1
fi

if [ -f "VERSION" ]; then
  VERSION=`cat VERSION`
else
  VERSION=`git describe --tags --abbrev=1`
fi

if [ -f "BUILDDATE" ]; then
  BUILDDATE=`cat BUILDDATE`
else
  BUILDDATE=`date +%G-%m-%d-%H-%M`
fi

flutter build $1 --dart-define BUILD_VER=$VERSION --dart-define BUILD_DATE=$BUILDDATE
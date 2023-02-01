#!/bin/bash
flutter --version
flutter pub get
export DISPLAY=:99
Xvfb -ac :99 -screen 0 1280x1024x24 > /dev/null 2>&1 &
./run-tests.sh 01_general

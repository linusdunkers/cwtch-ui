#!/bin/bash

paths=$(find . -regextype posix-extended -regex "./integration_test/features/($1).*feature" | sort | sed -z "s/\\n/','/g;s/,'$//;s/^/'/")
sed "s|featurePaths: REPLACED_BY_SCRIPT|featurePaths: <String>[$paths]|" integration_test/gherkin_suite_test.editable.dart > integration_test/gherkin_suite_test.dart
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

PATH=$PATH:$PWD/linux/Tor
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"$PWD/linux/":"$PWD/linux/Tor/"
LOG_LEVEL=debug PATH=$PATH LD_LIBRARY_PATH=$LD_LIBRARY_PATH LOG_FILE=/home/sarah/PARA/projects/cwtch/cwtch.log CWTCH_HOME=$PWD/integration_test/env/temp/ flutter test -d linux --dart-define TEST_MODE=true integration_test/gherkin_suite_test.dart
#node index2.js
#if [ "$HEADLESS" = "false" ]; then
#  xdg-open integration_test/gherkin/reports/cucumber_report.html
#fi


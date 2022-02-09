#!/bin/bash

OS=$(uname)

DEVICE=linux
if [ "$OS" == "Darwin" ]; then
  DEVICE=macos
fi

if [ ! -e run-tests.env ]; then
  echo "#!/bin/bash" > run-tests.env
  if [ "$OS" == "Linux" ]; then
    echo "LDPATH=./linux/" >> run-tests.env
  else
    echo "LDPATH=./" >> run-tests.env
  fi
  if [ -z $DRONE ]; then
    echo "HEADLESS=false" >> run-tests.env
  else
    echo "HEADLESS=true" >> run-tests.env
  fi
fi

source run-tests.env
#paths=$(find . -wholename "./integration_test/features/*/$1*.feature" | sort | sed -z "s/\\n/','/g;s/,'$//;s/^/'/")
# macos sed doesn't have -z
paths=$(find . -wholename "./integration_test/features/*/$1*.feature" | sort | awk '!/0$/{printf $0}/0$/' | sed "s/\.\//','\.\//g;s/^','/'/g;s/$/'/g")
sed "s|featurePaths: REPLACED_BY_SCRIPT|featurePaths: <String>[$paths]|" integration_test/gherkin_suite_test.editable.dart > integration_test/gherkin_suite_test.dart
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
LD_LIBRARY_PATH=$LDPATH DYLD_LIBRARY_PATH=$LDPATH CWTCH_HOME=./integration_test/env/temp/ flutter drive --headless --dart-define TEST_MODE=true --driver=test_driver/integration_test_driver.dart --target=integration_test/gherkin_suite_test.dart -d $DEVICE
node index2.js
if [ "$HEADLESS" = "false" ]; then
  xdg-open integration_test/gherkin/reports/cucumber_report.html
fi


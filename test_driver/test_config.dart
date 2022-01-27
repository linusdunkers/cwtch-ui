import 'dart:async';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:glob/glob.dart';
import 'steps/form_elements.dart';

Future<void> main() {
  final config = FlutterTestConfiguration()
  ..features = [Glob(r"test_driver/features/**.feature")]
  //..features = [Glob(r"test_driver/features/Settings_test.feature")]
  ..reporters = [ProgressReporter()]
  ..stepDefinitions = [CheckSwitchChecked(), CheckSwitchUnchecked(),]
  ..restartAppBetweenScenarios = true
  ..targetAppPath = "test_driver/app.dart";
  //..exitAfterTestRun = true;
  return GherkinRunner().execute(config);
}
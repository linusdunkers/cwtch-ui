//import 'package:flutter_gherkin/flutter_gherkin_integration_test.dart'; // notice new import name
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';

import 'dart:io';

// The application under test.
import 'package:cwtch/main.dart' as app;
import 'package:glob/glob.dart';

import 'hooks/env.dart';
import 'steps/chat.dart';
import 'steps/files.dart';
import 'steps/form_elements.dart';
import 'steps/overrides.dart';
import 'steps/text.dart';
import 'steps/utils.dart';

part 'gherkin_suite_test.g.dart';
const REPLACED_BY_SCRIPT = <String>['integration_test/features/**.feature'];

@GherkinTestSuite(executionOrder: ExecutionOrder.alphabetical, featurePaths: REPLACED_BY_SCRIPT)
void main() {
  final params = [
    SwitchStateParameter(),
  ];

  final steps = [
    // chat elements
    ExpectReply(),
    // form elements
    CheckSwitchState(),
    CheckSwitchStateWithText(),
    DropdownChoose(),
    // utils
    TakeScreenshot(),
    // overrides
    TapWidgetWithType(),
    TapWidgetWithLabel(),
    ExpectWidgetWithText(),
    WaitUntilTypeExists(),
    ExpectTextToBePresent(),
    ExpectWidgetWithTextWithin(),
    WaitUntilTextExists(),
    SwipeOnType(),
    // text
    TorVersionPresent(),
    TooltipTap(),
    // files
    FolderExists(),
    FileExists(),
  ];

  var sb = StringBuffer();
  sb..writeln("## Custom Parameters\n")
  ..writeln("| name | pattern |")
  ..writeln("| --- | --- |");
  for (var i in params) {
    sb..write("| ")..write(i.identifier)..write(" | ")..write(i.pattern.toString().replaceFirst("RegExp: pattern=","").replaceFirst(" flags=i","").replaceAll("|", "&#124;"))..writeln(" |");
  }
  sb..writeln("\n## Custom steps\n")
  ..writeln("| pattern |")
  ..writeln("| --- |");
  for (var i in steps) {
    sb.writeln(i.pattern.toString().replaceFirst("RegExp: pattern=", "| ").replaceFirst(" flags=", " |").replaceAll("|", "&#124;"));
  }
  var f = File("integration_test/CustomSteps.md");
  f.writeAsString(sb.toString());

  executeTestSuite(
    FlutterTestConfiguration.DEFAULT([])
      ..reporters = [
        StdoutReporter(MessageLevel.error)
          ..setWriteLineFn(print)
          ..setWriteFn(print),
        ProgressReporter()
          ..setWriteLineFn(print)
          ..setWriteFn(print),
        TestRunSummaryReporter()
          ..setWriteLineFn(print)
          ..setWriteFn(print),
        JsonReporter(
          writeReport: (_, __) => Future<void>.value(),
        ),
      ]
      ..customStepParameterDefinitions = [
        SwitchStateParameter(),
      ]
      ..stepDefinitions = steps
      ..hooks = [
        ResetCwtchEnvironment(),
        AttachScreenshotOnFailedStepHook(),
      ],
      (World world) => app.main(),
  );
}
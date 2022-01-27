//import 'package:flutter_gherkin/flutter_gherkin_integration_test.dart'; // notice new import name
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin/gherkin.dart';

// The application under test.
import 'package:cwtch/main.dart' as app;
import 'package:glob/glob.dart';

import 'hooks/env.dart';
import 'steps/files.dart';
import 'steps/form_elements.dart';
import 'steps/overrides.dart';
import 'steps/text.dart';
import 'steps/utils.dart';

part 'gherkin_suite_test.g.dart';
const REPLACED_BY_SCRIPT = <String>['integration_test/features/**.feature'];

@GherkinTestSuite(executionOrder: ExecutionOrder.alphabetical, featurePaths: <String>['./integration_test/features/05_p2p_chat/01_add_remove_block_archive.feature','./integration_test/features/05_p2p_chat/02_proto_invites.feature','./integration_test/features/05_p2p_chat/03_send_receive.feature','./integration_test/features/05_p2p_chat/04_special_messages.feature','./integration_test/features/05_p2p_chat/05_overlays_invite.feature','./integration_test/features/05_p2p_chat/06_overlays_file.feature','./integration_test/features/05_p2p_chat/07_overlays_image.feature'])
void main() {
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
      ..stepDefinitions = [
        // form elements
        CheckSwitchState(),
        CheckSwitchStateWithText(),
        DropdownChoose(),
        // utils
        TakeScreenshot(),
        // overrides
        TapWidgetWithType(),
        TapFirstWidget(),
        WaitUntilTypeExists(),
        ExpectTextToBePresent(),
        // text
        TorVersionPresent(),
        TooltipTap(),
        // files
        FolderExists(),
        FileExists(),
      ]
      ..hooks = [
        ResetCwtchEnvironment(),
        AttachScreenshotOnFailedStepHook(),
      ],
      (World world) => app.main(),
  );
}
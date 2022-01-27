// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gherkin_suite_test.dart';

// **************************************************************************
// GherkinSuiteTestGenerator
// **************************************************************************

class _CustomGherkinIntegrationTestRunner extends GherkinIntegrationTestRunner {
  _CustomGherkinIntegrationTestRunner(
    TestConfiguration configuration,
    Future<void> Function(World) appMainFunction,
  ) : super(configuration, appMainFunction);

  @override
  void onRun() {
    testFeature2();
  }

  void testFeature2() {
    runFeature(
      'Sending and receiving chat messages:',
      <String>['@env:aliceandbob1'],
      () {
        runScenario(
          'Bob receives the message from Alice',
          <String>['@env:aliceandbob1'],
          (TestDependencies dependencies) async {
            await runStep(
              'Given I tap the button containing the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button containing the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'When I fill the "ComposeTextField" with "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button with tooltip "Send"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect to see a "MessageBubble" widget with the text "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I press the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I press the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Given I tap the button containing the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button containing the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect to see a "MessageBubble" widget with the text "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );
          },
          onBefore: () async => onBeforeRunFeature(
            'Sending and receiving chat messages',
            <String>['@env:aliceandbob1'],
          ),
          onAfter: null,
        );

        runScenario(
          'Bob replies to a message from Alice',
          <String>['@env:aliceandbob1'],
          (TestDependencies dependencies) async {
            await runStep(
              'Given I tap the button containing the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button containing the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'When I fill the "ComposeTextField" with "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button with tooltip "Send"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect to see a "MessageBubble" widget with the text "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I press the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I press the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Given I tap the button containing the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button containing the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'When I tap the button with tooltip "Reply"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I fill the "ComposeTextField" with "yay the test worked"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button with tooltip "Send"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect to see the message "yay the test worked" replying to "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );
          },
          onBefore: null,
          onAfter: () async => onAfterRunFeature(
            'Sending and receiving chat messages',
          ),
        );
      },
    );
  }
}

void executeTestSuite(
  TestConfiguration configuration,
  Future<void> Function(World) appMainFunction,
) {
  _CustomGherkinIntegrationTestRunner(configuration, appMainFunction).run();
}

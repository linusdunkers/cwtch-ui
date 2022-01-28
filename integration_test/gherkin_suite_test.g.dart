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
              'Given I wait until the widget with type "ProfileRow" is present',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I wait for 4 seconds',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Given I tap the button that contains the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button that contains the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I wait until the text "Contact is offline, messages can\'t be delivered right now" is absent',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'When I fill the "txtCompose" field with "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the "btnSend" button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect a "MessageBubble" widget with text "hello! this is a test!\u202F" to be present within 5 seconds',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Given I tap the button that contains the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button that contains the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect a "MessageBubble" widget with text "hello! this is a test!\u202F" to be present within 5 seconds',
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
              'Given I wait until the widget with type "ProfileRow" is present',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I wait for 4 seconds',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Given I tap the button that contains the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button that contains the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I wait until the text "Contact is offline, messages can\'t be delivered right now" is absent',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'When I fill the "txtCompose" field with "hello! this is a test!"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the "btnSend" button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect a "MessageBubble" widget with text "hello! this is a test!\u202F" to be present within 5 seconds',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the back button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Given I tap the button that contains the text "Bob"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button that contains the text "Alice"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the button with tooltip "Reply to this message"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I fill the "txtCompose" field with "yay the test worked"',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I tap the "btnSend" button',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'Then I expect to see the message "yay the test worked\u202F" replying to "hello! this is a test!" within 5 seconds',
              <String>[],
              null,
              dependencies,
            );

            await runStep(
              'And I take a screenshot',
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

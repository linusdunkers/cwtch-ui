// This is a basic Flutter integration test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cwtch/main_test.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  _testMain();
}

void _testMain() {
  testWidgets('Blocked message rejection test', (WidgetTester tester) async {
    final String testerProfile = "mr roboto";
    final String blockedProfile = "rudey";

    // start the app and render a few frames
    app.main();
    await tester.pump(); await tester.pump(); await tester.pump();
    //await tester.pumpAndSettle();

    for (var i = 0; i < 30; i++) {
      print("$i pump");
      await tester.pump();
    }

    // log in to a profile with a blocked contact
    await tester.tap(find.text(testerProfile));
    await tester.pump(); await tester.pump(); await tester.pump();
    expect(find.byIcon(Icons.block), findsOneWidget);

    // use the debug control to inject a message from the contact
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pump(); await tester.pump(); await tester.pump();


    // screenshot test
    print(Directory.current);
    //Directory.current = "/home/erinn/AndroidStudioProjects/flwtch/integration_test";
    await expectLater(find.byKey(Key('app')), matchesGoldenFile('blockedcontact.png'));
    // any active message badges?
    expect(find.text('1'), findsNothing);
  });
}

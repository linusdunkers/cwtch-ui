import 'dart:convert';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric TakeScreenshot() {
  return then<FlutterWorld>(
    RegExp(r'I take a screenshot'),
    (context) async {
      try {
        final bytes = await context.world.appDriver.screenshot();
        final screenshotData = base64Encode(bytes);
        print("EMBEDDING SCREENSHOT....");
        context.world.attach(screenshotData, 'image/png', 'And I take a screenshot');
      } catch (e, st) {
        print("FAILED TO EMBED??? $e $st");
        context.world.attach('Failed to take screenshot\n$e\n$st', 'text/plain');
      }
    },
  );
}

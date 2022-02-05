import 'dart:convert';
import 'dart:io';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric TooltipTap() {
  return given1<String, FlutterWorld>(
    RegExp(r'I tap the button with tooltip {string}'),
      (input1, context) async {
        final finder = context.world.appDriver.findBy(input1, FindType.tooltip);
        await context.world.appDriver.tap(finder);
        await context.world.appDriver.waitForAppToSettle();
      }
  );
}

StepDefinitionGeneric TorVersionPresent() {
  return given<FlutterWorld>(
    RegExp(r'I expect the Tor version to be present$'),
        (context) async {
          String versionString = "";
          final file = File('fetch-tor.sh');
          Stream<String> lines = file.openRead()
              .transform(utf8.decoder)
              .transform(LineSplitter());
          try {
            await for (var line in lines) {
              if (line.startsWith("wget https://git.openprivacy.ca/openprivacy/buildfiles/raw/branch/master/tor/tor-")) {
                versionString = line.substring(81, 88);
                break;
              }
            }
            print('File is now closed.');
          } catch (e) {
            print('Error: $e');
          }
          if (versionString == "") {
            context.expect(versionString, "#.#.#", reason: "error reading version string from fetch-tor.sh");
            return;
          }
          context.world.attach(versionString, "text/plain", "Then I expect the Tor version to be present");
          context.reporter.message("test!!!", MessageLevel.info);
          print("looking for version string $versionString");
          final finder = context.world.appDriver.findBy(versionString, FindType.text,);
          final isP = await context.world.appDriver.isPresent(finder);
          context.expect(isP, true);
    },
  );
}
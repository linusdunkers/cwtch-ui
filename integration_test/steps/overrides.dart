// this file contains steps from flutter_gherkin with bugfixes/adaptations to our codebase

import 'package:cwtch/main.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:cwtch/views/profilemgrview.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_gherkin/src/flutter/parameters/existence_parameter.dart';
import 'package:gherkin/gherkin.dart';

import 'package:flutter/material.dart';

StepDefinitionGeneric TapWidgetWithType() {
  return given1<String, FlutterWorld>(
    RegExp(r'I tap the (?:button|element|label|icon|field|text|widget) with type {string}$'),
    (input1, context) async {
      await context.world.appDriver.tap(
        context.world.appDriver.findBy(
          widgetTypeByName(input1),
          FindType.type,
        ),
      );
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}

StepDefinitionGeneric TapFirstWidget() {
  return given1<String, FlutterWorld>(
    RegExp(r'I tap the first {string} (?:button|element|label|icon|field|text|widget)$'),
        (input1, context) async {
      final finder = context.world.appDriver.findByDescendant(
        context.world.appDriver.findBy(Flwtch, FindType.type),
        context.world.appDriver.findBy(input1, FindType.key),
        firstMatchOnly: true);
      //Text wdg = await context.world.appDriver.widget(finder, ExpectedWidgetResultType.first);
      //print(wdg.debugDescribeChildren().first.)
      await context.world.appDriver.tap(finder);
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}

StepDefinitionGeneric WaitUntilTypeExists() {
  return then2<String, Existence, FlutterWorld>(
    'I wait until the (?:button|element|label|icon|field|text|widget) with type {string} is {existence}',
        (ofType, existence, context) async {
      await context.world.appDriver.waitUntil(
            () async {
          await context.world.appDriver.waitForAppToSettle();

          return existence == Existence.absent
              ? context.world.appDriver.isAbsent(
            context.world.appDriver.findBy(widgetTypeByName(ofType), FindType.type),
          )
              : context.world.appDriver.isPresent(
            context.world.appDriver.findBy(widgetTypeByName(ofType), FindType.type),
          );
        },
      );
    },
  );
}

StepDefinitionGeneric ExpectTextToBePresent() {
  return given2<String, int, FlutterWorld>(
    RegExp(
        r'I expect the string {string} to be present within {int} second(s)$'),
        (key, seconds, context) async {
      await context.world.appDriver.waitUntil(
            () async {
          await context.world.appDriver.waitForAppToSettle();

          return context.world.appDriver.isPresent(
            context.world.appDriver.findBy(key, FindType.text),
          );
        },
        timeout: Duration(seconds: seconds),
      );
    },
    configuration: StepDefinitionConfiguration()
      ..timeout = const Duration(days: 1),
  );
}

Type widgetTypeByName(String input1) {
  switch (input1) {
    case "ProfileMgrView":
      return ProfileMgrView;
    case "TorIcon":
      return TorIcon;
    default:
      throw("Unknown type $input1. add to integration_test/features/overrides.dart");
  }
}
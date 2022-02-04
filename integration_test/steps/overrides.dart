// this file contains steps from flutter_gherkin with bugfixes/adaptations to our codebase

import 'package:cwtch/main.dart';
import 'package:cwtch/widgets/messagebubble.dart';
import 'package:cwtch/widgets/profilerow.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:cwtch/views/profilemgrview.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_gherkin/src/flutter/parameters/existence_parameter.dart';
import 'package:flutter_gherkin/src/flutter/parameters/swipe_direction_parameter.dart';
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

StepDefinitionGeneric TapWidgetWithLabel() {
  return given2<String, String, FlutterWorld>(
    RegExp(r'I tap the {string} widget with label {string}$'),
        (ofType, text, context) async {
      final finder = context.world.appDriver.findByDescendant(
        context.world.appDriver.findBy(widgetTypeByName(ofType), FindType.type),
        context.world.appDriver.findBy(text, FindType.text),
        firstMatchOnly: true);
      //Text wdg = await context.world.appDriver.widget(finder, ExpectedWidgetResultType.first);
      //print(wdg.debugDescribeChildren().first.)
      await context.world.appDriver.scrollIntoView(finder);
      await context.world.appDriver.tap(finder);
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}

StepDefinitionGeneric TapWidgetWithTooltip() {
  return given2<String, String, FlutterWorld>(
    RegExp(r'I tap the {string} widget with tooltip {string}$'),
        (ofType, text, context) async {
      final finder = context.world.appDriver.findByDescendant(
          context.world.appDriver.findBy(widgetTypeByName(ofType), FindType.type),
          context.world.appDriver.findBy(text, FindType.tooltip),
          firstMatchOnly: true);
      await context.world.appDriver.scrollIntoView(finder);
      await context.world.appDriver.tap(finder);
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}

StepDefinitionGeneric ExpectWidgetWithText() {
  return given2<String, String, FlutterWorld>(
    RegExp(r'I expect a {string} widget with text {string}$'),
        (ofType, text, context) async {
      final finder = context.world.appDriver.findByDescendant(
          context.world.appDriver.findBy(widgetTypeByName(ofType), FindType.type),
          context.world.appDriver.findBy(text, FindType.text),
          firstMatchOnly: true);
      //Text wdg = await context.world.appDriver.widget(finder, ExpectedWidgetResultType.first);
      //print(wdg.debugDescribeChildren().first.)
      await context.world.appDriver.isPresent(finder);
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}

StepDefinitionGeneric AbsentWidgetWithText() {
  return given2<String, String, FlutterWorld>(
    RegExp(r'I expect a {string} widget with text {string} to be absent$'),
        (ofType, text, context) async {
      final finder = context.world.appDriver.findByDescendant(
          context.world.appDriver.findBy(widgetTypeByName(ofType), FindType.type),
          context.world.appDriver.findBy(text, FindType.text),
          firstMatchOnly: true);
      //Text wdg = await context.world.appDriver.widget(finder, ExpectedWidgetResultType.first);
      //print(wdg.debugDescribeChildren().first.)
      await context.world.appDriver.isAbsent(finder);
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}


StepDefinitionGeneric TapButtonWithText() {
  return given1<String, FlutterWorld>(
    RegExp(r'I tap the {string} (?:button|element|label|icon|field|text|widget)$'),
        (input1, context) async {
      final finder = context.world.appDriver.findByDescendant(
          context.world.appDriver.findBy(Flwtch, FindType.type),
          context.world.appDriver.findBy(input1, FindType.key),
          firstMatchOnly: true);
      await context.world.appDriver.scrollIntoView(finder);
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

StepDefinitionGeneric ExpectWidgetWithTextWithin() {
  return given3<String, String, int, FlutterWorld>(
    RegExp(
        r'I expect a {string} widget with text {string} to be present within {int} second(s)$'),
        (widgetType, text, seconds, context) async {
      await context.world.appDriver.waitUntil(
            () async {
          await context.world.appDriver.waitForAppToSettle();

          return context.world.appDriver.isPresent(
            context.world.appDriver.findByDescendant(
              context.world.appDriver.findBy(widgetTypeByName(widgetType), FindType.type),
              context.world.appDriver.findBy(text, FindType.text)
            ),
          );
        },
        timeout: Duration(seconds: seconds),
      );
    },
    configuration: StepDefinitionConfiguration()
      ..timeout = const Duration(days: 1),
  );
}

StepDefinitionGeneric WaitUntilTextExists() {
  return then2<String, Existence, FlutterWorld>(
    'I wait until the text {string} is {existence}',
        (text, existence, context) async {
      await context.world.appDriver.waitUntil(
            () async {
          await context.world.appDriver.waitForAppToSettle();

          return existence == Existence.absent
              ? context.world.appDriver.isAbsent(
            context.world.appDriver.findBy(text, FindType.text),
          )
              : context.world.appDriver.isPresent(
            context.world.appDriver.findBy(text, FindType.text),
          );
        },
        timeout: Duration(seconds: 120),
      );
    },

    configuration: StepDefinitionConfiguration()
      ..timeout = const Duration(days: 1),
  );
}

StepDefinitionGeneric WaitUntilTooltipExists() {
  return then2<String, Existence, FlutterWorld>(
    'I wait until the tooltip {string} is {existence}',
        (ofType, existence, context) async {
      await context.world.appDriver.waitUntil(
            () async {
          await context.world.appDriver.waitForAppToSettle();

          return existence == Existence.absent
              ? context.world.appDriver.isAbsent(
            context.world.appDriver.findBy(ofType, FindType.tooltip),
          )
              : context.world.appDriver.isPresent(
            context.world.appDriver.findBy(ofType, FindType.tooltip),
          );
        },
        timeout: Duration(seconds: 120),
      );
    },
    configuration: StepDefinitionConfiguration()
      ..timeout = const Duration(days: 1),
  );
}

mixin _SwipeHelper
on When4WithWorld<SwipeDirection, int, String, String, FlutterWorld> {
  Future<void> swipeOnFinder(
      dynamic finder,
      SwipeDirection direction,
      int swipeAmount,
      ) async {
    if (direction == SwipeDirection.left || direction == SwipeDirection.right) {
      final offset =
      direction == SwipeDirection.right ? swipeAmount : (swipeAmount * -1);
      await world.appDriver.scroll(
        finder,
        dx: offset.toDouble(),
        duration: Duration(milliseconds: 500),
        timeout: timeout,
      );
    } else {
      final offset =
      direction == SwipeDirection.up ? swipeAmount : (swipeAmount * -1);

      await world.appDriver.scroll(
        finder,
        dy: offset.toDouble(),
        duration: Duration(milliseconds: 500),
        timeout: timeout,
      );
    }
  }
}
class SwipeOnType
    extends When4WithWorld<SwipeDirection, int, String, String, FlutterWorld>
    with _SwipeHelper {
  @override
  Future<void> executeStep(
      SwipeDirection direction,
      int swipeAmount,
      String typeOf,
      String text,
      ) async {
    final finder = this.world.appDriver.findByDescendant(
        this.world.appDriver.findBy(widgetTypeByName(typeOf), FindType.type),
        this.world.appDriver.findBy(text, FindType.text)
    );
    await swipeOnFinder(finder, direction, swipeAmount);
  }

  @override
  RegExp get pattern => RegExp(
      r'I swipe {swipe_direction} by {int} pixels on the widget of type {string} with text {string}');
}

Type widgetTypeByName(String input1) {
  switch (input1) {
    case "MessageBubble":
      return MessageBubble;
    case "ProfileMgrView":
      return ProfileMgrView;
    case "ProfileRow":
      return ProfileRow;
    case "TorIcon":
      return TorIcon;
    case "button":
        return ElevatedButton;
    case "IconButton":
      return IconButton;
    case "ProfileRow":
        return ProfileRow;
    default:
      throw("Unknown type $input1. add to integration_test/features/overrides.dart");
  }
}
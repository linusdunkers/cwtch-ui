import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum SwitchState { checked, unchecked }

class SwitchStateParameter extends CustomParameter<SwitchState> {
  SwitchStateParameter()
      : super("toggle", RegExp(r"(checked|unchecked)", caseSensitive: false), (s) {
          switch (s.toLowerCase()) {
            case "checked":
              return SwitchState.checked;
            case "unchecked":
              return SwitchState.unchecked;
          }
        });
}

class CheckSwitchState extends Given2WithWorld<String, SwitchState, FlutterWorld> {
  @override
  Future<void> executeStep(String input1, SwitchState state) async {
    final switch1 = world.appDriver.findBy(input1, FindType.key);
    bool switch1exists = await world.appDriver.isPresent(switch1);
    expect(switch1exists, true);
    if (switch1exists) {
      SwitchListTile wdgt = await world.appDriver.widget(switch1);
      expect(wdgt.value, state == SwitchState.checked);
    }
  }

  @override
  RegExp get pattern => RegExp(r"I expect the {string} widget to be {toggle}");
}

StepDefinitionGeneric CheckSwitchStateWithText() {
  return then2<String, SwitchState, FlutterWorld>(
    RegExp(r'I expect the switch that contains the text {string} to be {toggle}'),
    (input1, state, context) async {
      final textFinder = context.world.appDriver.findBy(input1, FindType.text);
      await context.world.appDriver.scrollIntoView(textFinder);
      final switchTypeFinder = context.world.appDriver.findBy(SwitchListTile, FindType.type);
      final switchFinder = context.world.appDriver.findByAncestor(textFinder, switchTypeFinder);
      SwitchListTile switchWidget = await context.world.appDriver.widget(switchFinder);
      context.expect(switchWidget.value, state == SwitchState.checked);
    },
  );
}

StepDefinitionGeneric DropdownChoose() {
  return then2<int, String, FlutterWorld>(
    RegExp(r'I choose option {int} from the {string} dropdown'),
    (idx, input1, context) async {
      await context.world.appDriver.waitForAppToSettle();
      final ddFinder = context.world.appDriver.findBy(input1, FindType.key);
      await context.world.appDriver.scrollIntoView(ddFinder);
      await context.world.appDriver.waitForAppToSettle();
      await context.world.appDriver.tap(ddFinder);
      await context.world.appDriver.waitForAppToSettle();

      // somewhat complicated due to widget structure... we need to:
      // find [ancestor of type DropdownMenuItem] of [[Text with value <text of element #idx>] contained within Dropdown]
      DropdownButton ddWidget = await context.world.appDriver.widget(ddFinder);
      DropdownMenuItem itemWidget = ddWidget.items!.elementAt(idx);
      final itemText = (itemWidget.child as Text).data.toString();
      final textFinder = context.world.appDriver.findBy(itemText, FindType.text);
      final textWithinFinder = context.world.appDriver.findByDescendant(ddFinder, textFinder);
      final ddiFinder = context.world.appDriver.findBy(DropdownMenuItem<String>, FindType.type);
      //final ddiFinder = context.world.appDriver.findBy(_MenuItem, FindType.type);
      final itemFinder = context.world.appDriver.findByAncestor(textWithinFinder, ddiFinder, firstMatchOnly: true);
      await context.world.appDriver.tap(itemFinder);
      await context.world.appDriver.waitForAppToSettle();
    },
  );
}

import 'package:cwtch/main.dart';
import 'package:cwtch/widgets/messagebubble.dart';
import 'package:cwtch/widgets/profilerow.dart';
import 'package:cwtch/widgets/quotedmessage.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:cwtch/views/profilemgrview.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:flutter_gherkin/src/flutter/parameters/existence_parameter.dart';
import 'package:flutter_gherkin/src/flutter/parameters/swipe_direction_parameter.dart';
import 'package:gherkin/gherkin.dart';

import 'package:flutter/material.dart';

import 'overrides.dart';

StepDefinitionGeneric ExpectReply() {
  return given3<String, String, int, FlutterWorld>(
    RegExp(
        r'I expect to see the message {string} replying to {string} within {int} second(s)$'),
        (originalMessage, responseMessage, seconds, context) async {
      await context.world.appDriver.waitUntil(
            () async {
          await context.world.appDriver.waitForAppToSettle();

          return await context.world.appDriver.isPresent(
              context.world.appDriver.findByDescendant(
                  context.world.appDriver.findBy(QuotedMessageBubble, FindType.type),
                  context.world.appDriver.findBy(originalMessage, FindType.text)
              )
          ) && await context.world.appDriver.isPresent(
              context.world.appDriver.findByDescendant(
                  context.world.appDriver.findBy(QuotedMessageBubble, FindType.type),
                  context.world.appDriver.findBy(responseMessage, FindType.text)
              ));
        },
        timeout: Duration(seconds: seconds),
      );
    },
    configuration: StepDefinitionConfiguration()
      ..timeout = const Duration(days: 1),
  );
}
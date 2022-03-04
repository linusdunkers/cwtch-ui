import 'dart:convert';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/malformedmessage.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:cwtch/widgets/quotedmessage.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../messagecache.dart';
import '../profile.dart';

class QuotedMessageStructure {
  final String quotedHash;
  final String body;
  QuotedMessageStructure(this.quotedHash, this.body);

  Map<String, dynamic> toJson() => {
        'quotedHash': quotedHash,
        'body': body,
      };
}

class QuotedMessage extends Message {
  final MessageMetadata metadata;
  final String content;
  QuotedMessage(this.metadata, this.content);

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          try {
            dynamic message = jsonDecode(this.content);
            return Text(message["body"]);
          } catch (e) {
            return MalformedBubble();
          }
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }

  @override
  Widget getWidget(BuildContext context) {
    try {
      dynamic message = jsonDecode(this.content);

      if (message["body"] == null || message["quotedHash"] == null) {
        return MalformedBubble();
      }

      return ChangeNotifierProvider.value(
          value: this.metadata,
          builder: (bcontext, child) {
            return MessageRow(QuotedMessageBubble(message["body"], messageHandler(bcontext, metadata.profileOnion, metadata.conversationIdentifier, ByContentHash(message["quotedHash"]))));
          });
    } catch (e) {
      return MalformedBubble();
    }
  }
}

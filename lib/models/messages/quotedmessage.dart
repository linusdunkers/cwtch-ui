import 'dart:convert';

import 'package:cwtch/config.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/malformedmessage.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:cwtch/widgets/quotedmessage.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../settings.dart';
import '../../third_party/linkify/flutter_linkify.dart';

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
            dynamic message = jsonDecode(
              this.content,
            );
            var content = message["body"];
            var formatMessages = Provider.of<Settings>(bcontext).isExperimentEnabled(FormattingExperiment);
            return SelectableLinkify(
                text: content + '\u202F',
                options: LinkifyOptions(messageFormatting: formatMessages, parseLinks: false, looseUrl: true, defaultToHttps: true),
                linkifiers: [UrlLinkifier()],
                onOpen: null,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 12.0 * Provider.of<Settings>(context).fontScaling, fontWeight: FontWeight.normal, fontFamily: "Inter", overflow: TextOverflow.ellipsis),
                codeStyle: TextStyle(fontSize: 12.0 * Provider.of<Settings>(context).fontScaling, fontWeight: FontWeight.normal, fontFamily: "Inter", overflow: TextOverflow.ellipsis),
                textWidthBasis: TextWidthBasis.longestLine);
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
  Widget getWidget(BuildContext context, Key key, int index) {
    try {
      dynamic message = jsonDecode(this.content);

      if (message["body"] == null || message["quotedHash"] == null) {
        return MalformedMessage(this.metadata).getWidget(context, key, index);
      }

      return ChangeNotifierProvider.value(
          value: this.metadata,
          builder: (bcontext, child) {
            return MessageRow(QuotedMessageBubble(message["body"], messageHandler(bcontext, metadata.profileOnion, metadata.conversationIdentifier, ByContentHash(message["quotedHash"]))), index,
                key: key);
          });
    } catch (e) {
      return MalformedMessage(this.metadata).getWidget(context, key, index);
    }
  }
}

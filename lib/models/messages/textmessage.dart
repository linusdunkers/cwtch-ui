import 'dart:math';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/malformedmessage.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagebubble.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../settings.dart';
import '../../third_party/linkify/flutter_linkify.dart';

class TextMessage extends Message {
  final MessageMetadata metadata;
  final String content;

  TextMessage(this.metadata, this.content);

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          var formatMessages = Provider.of<Settings>(bcontext).isExperimentEnabled(FormattingExperiment);
          return SelectableLinkify(
            text: content + '\u202F',
            options: LinkifyOptions(messageFormatting: formatMessages, parseLinks: false, looseUrl: true, defaultToHttps: true),
            linkifiers: [UrlLinkifier()],
            onOpen: null,
            textAlign: TextAlign.left,
            style: TextStyle(overflow: TextOverflow.ellipsis),
            codeStyle: TextStyle(overflow: TextOverflow.ellipsis),
            textWidthBasis: TextWidthBasis.longestLine,
          );
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }

  @override
  Widget getWidget(BuildContext context, Key key, int index) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          return MessageRow(
            MessageBubble(this.content),
            index,
            key: key,
          );
        });
  }
}

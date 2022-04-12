import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/malformedmessage.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagebubble.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class TextMessage extends Message {
  final MessageMetadata metadata;
  final String content;

  TextMessage(this.metadata, this.content);

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          return SelectableText(this.content);
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }

  @override
  Widget getWidget(BuildContext context, Key key) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          return MessageRow(
            MessageBubble(this.content),
            key: key,
          );
        });
  }
}

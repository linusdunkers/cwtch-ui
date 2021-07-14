import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/messagebubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../model.dart';
import '../../settings.dart';

class TextMessage extends Message {
  final MessageMetadata metadata;
  final String content;

  TextMessage(this.metadata, this.content);

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          return Text(this.content);
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }

  @override
  Widget getWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          String idx = Provider.of<ContactInfoState>(context).isGroup == true && this.metadata.signature != null ? this.metadata.signature! : this.metadata.messageIndex.toString();
          return MessageRow(MessageBubble(this.content), key: Provider.of<ContactInfoState>(bcontext).getMessageKey(idx));
        });
  }
}

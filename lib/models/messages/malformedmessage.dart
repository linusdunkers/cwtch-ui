import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MalformedMessage extends Message {
  final MessageMetadata metadata;
  MalformedMessage(this.metadata);

  @override
  Widget getWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (context, child) {
          return MessageRow(MalformedBubble());
        });
  }

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          return MalformedBubble();
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }
}

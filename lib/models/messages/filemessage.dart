import 'dart:convert';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/filebubble.dart';
import 'package:cwtch/widgets/invitationbubble.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../model.dart';

class FileMessage extends Message {
  final MessageMetadata metadata;
  final String content;

  FileMessage(this.metadata, this.content);

  @override
  Widget getWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          String idx = Provider.of<ContactInfoState>(context).isGroup == true && this.metadata.signature != null ? this.metadata.signature! : this.metadata.messageIndex.toString();
          dynamic shareObj = jsonDecode(this.content);
          if (shareObj == null) {
            return MessageRow(MalformedBubble());
          }
          String nameSuggestion = shareObj['f'] as String;
          String rootHash = shareObj['h'] as String;
          String nonce = shareObj['n'] as String;
          int fileSize = shareObj['s'] as int;

          return MessageRow(FileBubble(nameSuggestion, rootHash, nonce, fileSize), key: Provider.of<ContactInfoState>(bcontext).getMessageKey(idx));
        });
  }

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          dynamic shareObj = jsonDecode(this.content);
          if (shareObj == null) {
            return MessageRow(MalformedBubble());
          }
          String nameSuggestion = shareObj['n'] as String;
          String rootHash = shareObj['h'] as String;
          String nonce = shareObj['n'] as String;
          int fileSize = shareObj['s']  as int;
          return FileBubble(nameSuggestion, rootHash, nonce, fileSize);
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }
}

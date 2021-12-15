import 'dart:convert';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/filebubble.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../model.dart';

class FileMessage extends Message {
  final MessageMetadata metadata;
  final String content;
  final RegExp nonHex = RegExp(r'[^a-f0-9]');

  FileMessage(this.metadata, this.content);

  @override
  Widget getWidget(BuildContext context, Key key) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          dynamic shareObj = jsonDecode(this.content);
          if (shareObj == null) {
            return MessageRow(MalformedBubble());
          }
          String nameSuggestion = shareObj['f'] as String;
          String rootHash = shareObj['h'] as String;
          String nonce = shareObj['n'] as String;
          int fileSize = shareObj['s'] as int;

          if (!validHash(rootHash, nonce)) {
            return MessageRow(MalformedBubble());
          }

          return MessageRow(FileBubble(nameSuggestion, rootHash, nonce, fileSize), key: key);
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
          int fileSize = shareObj['s'] as int;
          if (!validHash(rootHash, nonce)) {
            return MessageRow(MalformedBubble());
          }
          return FileBubble(
            nameSuggestion,
            rootHash,
            nonce,
            fileSize,
            interactive: false,
          );
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }

  bool validHash(String hash, String nonce) {
    return hash.length == 128 && nonce.length == 48 && !hash.contains(nonHex) && !nonce.contains(nonHex);
  }
}

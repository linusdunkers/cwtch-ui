import 'dart:convert';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/filebubble.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../profile.dart';

class FileMessage extends Message {
  final MessageMetadata metadata;
  final String content;
  final RegExp nonHex = RegExp(r'[^a-f0-9]');

  FileMessage(this.metadata, this.content);

  @override
  Widget getWidget(BuildContext context, Key key, int index) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          try {
            dynamic shareObj = jsonDecode(this.content);
            if (shareObj == null) {
              return MessageRow(MalformedBubble(), index);
            }
            String nameSuggestion = shareObj['f'] as String;
            String rootHash = shareObj['h'] as String;
            String nonce = shareObj['n'] as String;
            int fileSize = shareObj['s'] as int;
            String fileKey = rootHash + "." + nonce;

           if (metadata.attributes["file-downloaded"] != "true") {
             if (!Provider.of<ProfileInfoState>(context,listen: false).downloadKnown(fileKey)) {
              Provider.of<FlwtchState>(context, listen: false).cwtch.CheckDownloadStatus(Provider.of<ProfileInfoState>(context, listen: false).onion, fileKey);
             }
            }

            if (!validHash(rootHash, nonce)) {
              return MessageRow(MalformedBubble(), index);
            }

            return MessageRow(FileBubble(nameSuggestion, rootHash, nonce, fileSize, isAuto: metadata.isAuto), index, key: key);
          } catch (e) {
            return MessageRow(MalformedBubble(), index);
          }
        });
  }

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          dynamic shareObj = jsonDecode(this.content);
          if (shareObj == null) {
            return MessageRow(MalformedBubble(), 0);
          }
          String nameSuggestion = shareObj['f'] as String;
          String rootHash = shareObj['h'] as String;
          String nonce = shareObj['n'] as String;
          int fileSize = shareObj['s'] as int;
          if (!validHash(rootHash, nonce)) {
            return MessageRow(MalformedBubble(), 0);
          }
          return Container(
              alignment: Alignment.center,
              height: 100,
              child: FileBubble(
                nameSuggestion,
                rootHash,
                nonce,
                fileSize,
                isAuto: metadata.isAuto,
                interactive: false,
                isPreview: true,
              ));
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

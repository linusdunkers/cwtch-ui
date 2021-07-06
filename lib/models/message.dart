import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'messages/invitemessage.dart';
import 'messages/malformedmessage.dart';
import 'messages/quotedmessage.dart';
import 'messages/textmessage.dart';

abstract class Message {
  MessageMetadata getMetadata();
  Widget getWidget(BuildContext context);
  Widget getPreviewWidget(BuildContext context);
}

Future<Message> messageHandler(BuildContext context, String profileOnion, String contactHandle, int index) {
  try {
    var rawMessageEnvelopeFuture = Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessage(profileOnion, contactHandle, index);
    return rawMessageEnvelopeFuture.then((dynamic rawMessageEnvelope) {
      dynamic messageWrapper = jsonDecode(rawMessageEnvelope);
      if (messageWrapper['Message'] == null || messageWrapper['Message'] == '' || messageWrapper['Message'] == '{}') {
        return Future.delayed(Duration(seconds: 2), () {
          return messageHandler(context, profileOnion, contactHandle, index).then((value) => value);
        });
      }

      dynamic message = jsonDecode(messageWrapper['Message']);
      var content = message['d'] as dynamic;
      var overlay = int.parse(message['o'].toString());

      // Construct the initial metadata
      var timestamp = DateTime.tryParse(messageWrapper['Timestamp'])!;
      var senderHandle = messageWrapper['PeerID'];
      var senderImage = messageWrapper['ContactImage'];
      var flags = int.parse(messageWrapper['Flags'].toString(), radix: 2);
      var ackd = messageWrapper['Acknowledged'];
      var error = messageWrapper['Error'] != null;

      String? signature;
      // If this is a group, store the signature
      if (contactHandle.length == 32) {
        signature = messageWrapper['Signature'];
      }

      var metadata = MessageMetadata(profileOnion, contactHandle, index, timestamp, senderHandle, senderImage, signature, flags, ackd, error);

      switch (overlay) {
        case 1:
          return TextMessage(metadata, content);
        case 100:
        case 101:
          return InviteMessage(overlay, metadata, content);
        case 10:
          return QuotedMessage(metadata, content);
        default:
          // Metadata is valid, content is not..
          return MalformedMessage(metadata);
      }
    });
  } catch (e) {
    return Future.value(MalformedMessage(MessageMetadata(profileOnion, contactHandle, index, DateTime.now(), "", "", null, 0, false, true)));
  }
}

class MessageMetadata extends ChangeNotifier {
  // meta-metadata
  final String profileOnion;
  final String contactHandle;
  final int messageIndex;

  final DateTime timestamp;
  final String senderHandle;
  final String? senderImage;
  int _flags;
  bool _ackd;
  bool _error;

  final String? signature;

  int get flags => this._flags;
  set flags(int newVal) {
    this._flags = newVal;
    notifyListeners();
  }

  bool get ackd => this._ackd;
  set ackd(bool newVal) {
    this._ackd = newVal;
    notifyListeners();
  }

  bool get error => this._error;
  set error(bool newVal) {
    this._error = newVal;
    notifyListeners();
  }

  MessageMetadata(this.profileOnion, this.contactHandle, this.messageIndex, this.timestamp, this.senderHandle, this.senderImage, this.signature, this._flags, this._ackd, this._error);
}

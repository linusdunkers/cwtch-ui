import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'messages/invitemessage.dart';
import 'messages/malformedmessage.dart';
import 'messages/quotedmessage.dart';
import 'messages/textmessage.dart';

// Define the overlays
const TextMessageOverlay = 1;
const QuotedMessageOverlay = 10;
const SuggestContactOverlay = 100;
const InviteGroupOverlay = 101;

// Defines the length of the tor v3 onion address. Code using this constant will
// need to updated when we allow multiple different identifiers. At which time
// it will likely be prudent to define a proper Contact wrapper.
const TorV3ContactHandleLength = 56;

// Defines the length of a Cwtch v2 Group.
const GroupConversationHandleLength = 32;

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
      // There are 2 conditions in which this error condition can be met:
      // 1. The application == nil, in which case this instance of the UI is already
      // broken beyond repair, and will either be replaced by a new version, or requires a complete
      // restart.
      // 2. This index was incremented and we happened to fetch the timeline prior to the messages inclusion.
      // This should be rare as Timeline addition/fetching is mutex protected and Dart itself will pipeline the
      // calls to libCwtch-go - however because we use goroutines on the backend there is always a chance that one
      // will find itself delayed.
      // The second case is recoverable by tail-recursing this future.
      if (messageWrapper['Message'] == null || messageWrapper['Message'] == '' || messageWrapper['Message'] == '{}') {
        return Future.delayed(Duration(seconds: 2), () {
          print("Tail recursive call to messageHandler called. This should be a rare event. If you see multiples of this log over a short period of time please log it as a bug.");
          return messageHandler(context, profileOnion, contactHandle, index).then((value) => value);
        });
      }

      // Construct the initial metadata
      var timestamp = DateTime.tryParse(messageWrapper['Timestamp'])!;
      var senderHandle = messageWrapper['PeerID'];
      var senderImage = messageWrapper['ContactImage'];
      var flags = int.parse(messageWrapper['Flags'].toString(), radix: 2);
      var ackd = messageWrapper['Acknowledged'];
      var error = messageWrapper['Error'] != null;
      String? signature;
      // If this is a group, store the signature
      if (contactHandle.length == GroupConversationHandleLength) {
        signature = messageWrapper['Signature'];
      }
      var metadata = MessageMetadata(profileOnion, contactHandle, index, timestamp, senderHandle, senderImage, signature, flags, ackd, error);

      try {
        dynamic message = jsonDecode(messageWrapper['Message']);
        var content = message['d'] as dynamic;
        var overlay = int.parse(message['o'].toString());

        switch (overlay) {
          case TextMessageOverlay:
            return TextMessage(metadata, content);
          case SuggestContactOverlay:
          case InviteGroupOverlay:
            return InviteMessage(overlay, metadata, content);
          case QuotedMessageOverlay:
            return QuotedMessage(metadata, content);
          default:
            // Metadata is valid, content is not..
            return MalformedMessage(metadata);
        }
      } catch (e) {
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

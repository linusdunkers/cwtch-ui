import 'dart:convert';
import 'package:cwtch/config.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../model.dart';
import 'messages/filemessage.dart';
import 'messages/invitemessage.dart';
import 'messages/malformedmessage.dart';
import 'messages/quotedmessage.dart';
import 'messages/textmessage.dart';

// Define the overlays
const TextMessageOverlay = 1;
const QuotedMessageOverlay = 10;
const SuggestContactOverlay = 100;
const InviteGroupOverlay = 101;
const FileShareOverlay = 200;

// Defines the length of the tor v3 onion address. Code using this constant will
// need to updated when we allow multiple different identifiers. At which time
// it will likely be prudent to define a proper Contact wrapper.
const TorV3ContactHandleLength = 56;

// Defines the length of a Cwtch v2 Group.
const GroupConversationHandleLength = 32;

abstract class Message {
  MessageMetadata getMetadata();
  Widget getWidget(BuildContext context, Key key);
  Widget getPreviewWidget(BuildContext context);
}

Message compileOverlay(MessageMetadata metadata, String messageData) {
  try {
    dynamic message = jsonDecode(messageData);
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
      case FileShareOverlay:
        return FileMessage(metadata, content);
      default:
        // Metadata is valid, content is not..
        return MalformedMessage(metadata);
    }
  } catch (e) {
    return MalformedMessage(metadata);
  }
}

Future<Message> messageHandler(BuildContext context, String profileOnion, int conversationIdentifier, int index, {bool byID = false}) {
  try {
    var cache = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(conversationIdentifier)?.messageCache;
    if (cache != null && cache.length > index) {
      if (cache[index] != null) {
        return Future.value(compileOverlay(cache[index]!.metadata, cache[index]!.wrapper));
      }
    }
  } catch (e) {
    // provider check failed...make an expensive call...
  }

  try {
    Future<dynamic> rawMessageEnvelopeFuture;

    if (byID) {
      rawMessageEnvelopeFuture = Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessageByID(profileOnion, conversationIdentifier, index);
    } else {
      rawMessageEnvelopeFuture = Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessage(profileOnion, conversationIdentifier, index);
    }

    return rawMessageEnvelopeFuture.then((dynamic rawMessageEnvelope) {
      var metadata = MessageMetadata(profileOnion, conversationIdentifier, index, DateTime.now(), "", "", "", <String, String>{}, false, true, false);
      try {
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
            return messageHandler(context, profileOnion, conversationIdentifier, -1, byID: byID).then((value) => value);
          });
        }

        // Construct the initial metadata
        var messageID = messageWrapper['ID'];
        var timestamp = DateTime.tryParse(messageWrapper['Timestamp'])!;
        var senderHandle = messageWrapper['PeerID'];
        var senderImage = messageWrapper['ContactImage'];
        var attributes = messageWrapper['Attributes'];
        var ackd = messageWrapper['Acknowledged'];
        var error = messageWrapper['Error'] != null;
        var signature = messageWrapper['Signature'];
        metadata = MessageMetadata(profileOnion, conversationIdentifier, messageID, timestamp, senderHandle, senderImage, signature, attributes, ackd, error, false);

        return compileOverlay(metadata, messageWrapper['Message']);
      } catch (e) {
        EnvironmentConfig.debugLog("an error! " + e.toString());
        return MalformedMessage(metadata);
      }
    });
  } catch (e) {
    return Future.value(MalformedMessage(MessageMetadata(profileOnion, conversationIdentifier, -1, DateTime.now(), "", "", "", <String, String>{}, false, true, false)));
  }
}

class MessageMetadata extends ChangeNotifier {
  // meta-metadata
  final String profileOnion;
  final int conversationIdentifier;
  final int messageID;

  final DateTime timestamp;
  final String senderHandle;
  final String? senderImage;
  final dynamic _attributes;
  bool _ackd;
  bool _error;
  final bool isAuto;

  final String? signature;

  dynamic get attributes => this._attributes;

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

  MessageMetadata(
      this.profileOnion, this.conversationIdentifier, this.messageID, this.timestamp, this.senderHandle, this.senderImage, this.signature, this._attributes, this._ackd, this._error, this.isAuto);
}

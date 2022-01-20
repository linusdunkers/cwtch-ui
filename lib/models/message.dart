import 'dart:convert';
import 'package:cwtch/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import 'messagecache.dart';
import 'messages/filemessage.dart';
import 'messages/invitemessage.dart';
import 'messages/malformedmessage.dart';
import 'messages/quotedmessage.dart';
import 'messages/textmessage.dart';
import 'profile.dart';

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

Future<Message> messageHandler(BuildContext context, String profileOnion, int conversationIdentifier,
    {bool byIndex = false, int? index, bool byID = false, int? id, bool byHash = false, String? hash}) {
  var malformedMetadata = MessageMetadata(profileOnion, conversationIdentifier, 0, DateTime.now(), "", "", "", <String, String>{}, false, true, false);
  if (!byIndex && !byID && !byHash) {
    EnvironmentConfig.debugLog("Error calling messageHandler: one of byIndex, byID, byHash must be set");
    return Future.value(MalformedMessage(malformedMetadata));
  }
  if ((byID && id == null) || (byIndex && index == null) || (byHash && hash == null)) {
    EnvironmentConfig.debugLog("Error calling messageHandler: byType needs corresponding value and it was not set");
    return Future.value(MalformedMessage(malformedMetadata));
  }

  // Hit cache
  MessageInfo? messageInfo = getMessageInfoFromCache(context, profileOnion, conversationIdentifier, byIndex: byIndex, index: index, byID: byID, id: id, byHash: byHash, hash: hash);
  if (messageInfo != null) {
    return Future.value(compileOverlay(messageInfo.metadata, messageInfo.wrapper));
  }

  // Fetch and Cache
  var messageInfoFuture = fetchAndCacheMessageInfo(context, profileOnion, conversationIdentifier, byIndex: byIndex, index: index, byID: byID, id: id, byHash: byHash, hash: hash);
  return messageInfoFuture.then((MessageInfo? messageInfo) {
    if (messageInfo != null) {
      return compileOverlay(messageInfo.metadata, messageInfo.wrapper);
    } else {
      return MalformedMessage(malformedMetadata);
    }
  });
}

MessageInfo? getMessageInfoFromCache(BuildContext context, String profileOnion, int conversationIdentifier,
    {bool byIndex = false, int? index, bool byID = false, int? id, bool byHash = false, String? hash}) {
  // Hit cache
  try {
    var cache = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(conversationIdentifier)?.messageCache;
    if (cache != null) {
      MessageInfo? messageInfo = null;
      if (byID) {
        messageInfo = cache.getById(id!);
      } else if (byHash) {
        messageInfo = cache.getByContentHash(hash!);
      } else {
        messageInfo = cache.getByIndex(index!);
      }
      if (messageInfo != null) {
        return messageInfo;
      }
    }
  } catch (e) {
    EnvironmentConfig.debugLog("message handler exception on get from cache: $e");
    // provider check failed...make an expensive call...
  }
  return null;
}

Future<MessageInfo?> fetchAndCacheMessageInfo(BuildContext context, String profileOnion, int conversationIdentifier,
    {bool byIndex = false, int? index, bool byID = false, int? id, bool byHash = false, String? hash}) {
// Load and cache
  try {
    Future<dynamic> rawMessageEnvelopeFuture;

    if (byID) {
      rawMessageEnvelopeFuture = Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessageByID(profileOnion, conversationIdentifier, id!);
    } else if (byHash) {
      rawMessageEnvelopeFuture = Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessageByContentHash(profileOnion, conversationIdentifier, hash!);
    } else {
      rawMessageEnvelopeFuture = Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessage(profileOnion, conversationIdentifier, index!);
    }

    return rawMessageEnvelopeFuture.then((dynamic rawMessageEnvelope) {
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
            return fetchAndCacheMessageInfo(context, profileOnion, conversationIdentifier, byIndex: byIndex, index: index, byID: byID, id: id, byHash: byHash, hash: hash).then((value) => value);
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
        var contenthash = messageWrapper['ContentHash'];
        var localIndex = messageWrapper['LocalIndex'];
        var metadata = MessageMetadata(profileOnion, conversationIdentifier, messageID, timestamp, senderHandle, senderImage, signature, attributes, ackd, error, false);
        var messageInfo = new MessageInfo(metadata, messageWrapper['Message']);

        var cache = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(conversationIdentifier)?.messageCache;

        if (cache != null) {
          if (byID) {
            cache.addUnindexed(messageInfo, contenthash);
          } else if (byHash) {
            cache.addUnindexed(messageInfo, contenthash);
          } else {
            cache.add(messageInfo, index!, contenthash);
          }
        }

        return messageInfo;
      } catch (e) {
        EnvironmentConfig.debugLog("message handler exception on parse message and cache: " + e.toString());
        return null;
      }
    });
  } catch (e) {
    EnvironmentConfig.debugLog("message handler exeption on get message: $e");
    return Future.value(null);
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

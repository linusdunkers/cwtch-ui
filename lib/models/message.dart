import 'dart:convert';
import 'package:cwtch/config.dart';
import 'package:cwtch/cwtch/cwtch.dart';
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

abstract class CacheHandler {
  Future<MessageInfo?> get(Cwtch cwtch, String profileOnion, int conversationIdentifier, MessageCache cache);
}

class ByIndex implements CacheHandler {
  int index;

  ByIndex(this.index);

  Future<MessageInfo?> lookup(MessageCache cache) async {
    var msg = cache.getByIndex(index);
    return msg;
  }

  Future<MessageInfo?> get(Cwtch cwtch, String profileOnion, int conversationIdentifier, MessageCache cache) async {
    // if in cache, get. But if the cache has unsynced or not in cache, we'll have to do a fetch
    if (cache.indexUnsynced == 0 && index < cache.cacheByIndex.length) {
      return cache.getByIndex(index);
    }

    // otherwise we are going to fetch, so we'll fetch a chunk of messages
    // observationally flutter future builder seemed to be reaching for 20-40 message on pane load, so we start trying to load up to that many messages in one request
    var amount = 40;
    var start = index;
    // we have to keep the indexed cache contiguous so reach back to the end of it and start the fetch from there
    if (index > cache.cacheByIndex.length) {
      start = cache.cacheByIndex.length;
      amount += index - start;
    }

    // on android we may have recieved messages on the backend that we didn't process in the UI, get them
    // override the index chunk setting, the index math is wrong will we fetch these and these are all that should be missing
    if (cache.indexUnsynced > 0) {
      start = 0;
      amount = cache.indexUnsynced;
    }

    // check that we aren't asking for messages beyond stored messages
    if (start + amount >= cache.storageMessageCount) {
      amount = cache.storageMessageCount - start;
      if (amount <= 0) {
        return Future.value(null);
      }
    }

    cache.lockIndexes(start, start + amount);
    var msgs = await cwtch.GetMessages(profileOnion, conversationIdentifier, start, amount);
    int i = 0; // i used to loop through returned messages. if doesn't reach the requested count, we will use it in the finally stanza to error out the remaining asked for messages in the cache
    try {
      List<dynamic> messagesWrapper = jsonDecode(msgs);

      for (; i < messagesWrapper.length; i++) {
        var messageInfo = messageWrapperToInfo(profileOnion, conversationIdentifier, messagesWrapper[i]);
        cache.addIndexed(messageInfo, start + i);
      }
    } catch (e, stacktrace) {
      EnvironmentConfig.debugLog("Error: Getting indexed messages $start to ${start + amount} failed parsing: " + e.toString() + " " + stacktrace.toString());
    } finally {
      if (i != amount) {
        cache.malformIndexes(start + i, start + amount);
      }
    }
    return cache.getByIndex(index);
  }

  void add(MessageCache cache, MessageInfo messageInfo) {
    cache.addIndexed(messageInfo, index);
  }
}

class ById implements CacheHandler {
  int id;

  ById(this.id);

  Future<MessageInfo?> lookup(MessageCache cache) {
    return Future<MessageInfo?>.value(cache.getById(id));
  }

  Future<MessageInfo?> fetch(Cwtch cwtch, String profileOnion, int conversationIdentifier, MessageCache cache) async {
    var rawMessageEnvelope = await cwtch.GetMessageByID(profileOnion, conversationIdentifier, id);
    var messageInfo = messageJsonToInfo(profileOnion, conversationIdentifier, rawMessageEnvelope);
    if (messageInfo == null) {
      return Future.value(null);
    }
    cache.addUnindexed(messageInfo);
    return Future.value(messageInfo);
  }

  Future<MessageInfo?> get(Cwtch cwtch, String profileOnion, int conversationIdentifier, MessageCache cache) async {
    var messageInfo = await lookup(cache);
    if (messageInfo != null) {
      return Future.value(messageInfo);
    }
    return fetch(cwtch, profileOnion, conversationIdentifier, cache);
  }
}

class ByContentHash implements CacheHandler {
  String hash;

  ByContentHash(this.hash);

  Future<MessageInfo?> lookup(MessageCache cache) {
    return Future<MessageInfo?>.value(cache.getByContentHash(hash));
  }

  Future<MessageInfo?> fetch(Cwtch cwtch, String profileOnion, int conversationIdentifier, MessageCache cache) async {
    var rawMessageEnvelope = await cwtch.GetMessageByContentHash(profileOnion, conversationIdentifier, hash);
    var messageInfo = messageJsonToInfo(profileOnion, conversationIdentifier, rawMessageEnvelope);
    if (messageInfo == null) {
      return Future.value(null);
    }
    cache.addUnindexed(messageInfo);
    return Future.value(messageInfo);
  }

  Future<MessageInfo?> get(Cwtch cwtch, String profileOnion, int conversationIdentifier, MessageCache cache) async {
    var messageInfo = await lookup(cache);
    if (messageInfo != null) {
      return Future.value(messageInfo);
    }
    return fetch(cwtch, profileOnion, conversationIdentifier, cache);
  }
}

Future<Message> messageHandler(BuildContext context, String profileOnion, int conversationIdentifier, CacheHandler cacheHandler) async {
  var malformedMetadata = MessageMetadata(profileOnion, conversationIdentifier, 0, DateTime.now(), "", "", "", <String, String>{}, false, true, false, "");
  var cwtch = Provider.of<FlwtchState>(context, listen: false).cwtch;

  MessageCache? cache;
  try {
    cache = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(conversationIdentifier)?.messageCache;
    if (cache == null) {
      EnvironmentConfig.debugLog("error: cannot get message cache for profile: $profileOnion conversation: $conversationIdentifier");
      return MalformedMessage(malformedMetadata);
    }
  } catch (e) {
    EnvironmentConfig.debugLog("message handler exception on get from cache: $e");
    // provider check failed...make an expensive call...
    return MalformedMessage(malformedMetadata);
  }

  MessageInfo? messageInfo = await cacheHandler.get(cwtch, profileOnion, conversationIdentifier, cache);

  if (messageInfo != null) {
    return compileOverlay(messageInfo.metadata, messageInfo.wrapper);
  } else {
    return MalformedMessage(malformedMetadata);
  }
}

MessageInfo? messageJsonToInfo(String profileOnion, int conversationIdentifier, dynamic messageJson) {
  try {
    dynamic messageWrapper = jsonDecode(messageJson);

    if (messageWrapper == null || messageWrapper['Message'] == '' || messageWrapper['Message'] == '{}') {
      return null;
    }

    return messageWrapperToInfo(profileOnion, conversationIdentifier, messageWrapper);
  } catch (e, stacktrace) {
    EnvironmentConfig.debugLog("message handler exception on parse message and cache: " + e.toString() + " " + stacktrace.toString());
    return null;
  }
}

MessageInfo messageWrapperToInfo(String profileOnion, int conversationIdentifier, dynamic messageWrapper) {
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
  var metadata = MessageMetadata(profileOnion, conversationIdentifier, messageID, timestamp, senderHandle, senderImage, signature, attributes, ackd, error, false, contenthash);
  var messageInfo = new MessageInfo(metadata, messageWrapper['Message']);

  return messageInfo;
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
  final String contenthash;

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

  MessageMetadata(this.profileOnion, this.conversationIdentifier, this.messageID, this.timestamp, this.senderHandle, this.senderImage, this.signature, this._attributes, this._ackd, this._error,
      this.isAuto, this.contenthash);
}

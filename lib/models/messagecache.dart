import 'package:flutter/foundation.dart';

import 'message.dart';

class MessageInfo {
  final MessageMetadata metadata;
  final String wrapper;
  MessageInfo(this.metadata, this.wrapper);
}

class MessageCache extends ChangeNotifier {
  late Map<int, MessageInfo> cache;
  late List<int?> cacheByIndex;
  late Map<String, int> cacheByHash;

  MessageCache() {
    cache = {};
    cacheByIndex = List.empty(growable: true);
    cacheByHash = {};
  }

  int get indexedLength => cacheByIndex.length;

  MessageInfo? getById(int id) => cache[id];
  MessageInfo? getByIndex(int index) {
    if (index >= cacheByIndex.length) {
      return null;
    }
    return cache[cacheByIndex[index]];
  }

  MessageInfo? getByContentHash(String contenthash) => cache[cacheByHash[contenthash]];

  void addNew(String profileOnion, int conversation, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data, String? contenthash) {
    this.cache[messageID] = MessageInfo(MessageMetadata(profileOnion, conversation, messageID, timestamp, senderHandle, senderImage, "", {}, false, false, isAuto), data);
    this.cacheByIndex.insert(0, messageID);
    if (contenthash != null && contenthash != "") {
      this.cacheByHash[contenthash] = messageID;
    }
    notifyListeners();
  }

  void add(MessageInfo messageInfo, int index, String? contenthash) {
    this.cache[messageInfo.metadata.messageID] = messageInfo;
    this.cacheByIndex.insert(index, messageInfo.metadata.messageID);
    if (contenthash != null && contenthash != "") {
      this.cacheByHash[contenthash] = messageInfo.metadata.messageID;
    }
    notifyListeners();
  }

  void addUnindexed(MessageInfo messageInfo, String? contenthash) {
    this.cache[messageInfo.metadata.messageID] = messageInfo;
    if (contenthash != null && contenthash != "") {
      this.cacheByHash[contenthash] = messageInfo.metadata.messageID;
    }
    notifyListeners();
  }

  void ackCache(int messageID) {
    cache[messageID]?.metadata.ackd = true;
    notifyListeners();
  }

  void errCache(int messageID) {
    cache[messageID]?.metadata.error = true;
    notifyListeners();
  }
}

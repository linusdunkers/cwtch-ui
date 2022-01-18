import 'message.dart';

class MessageInfo {
  final MessageMetadata metadata;
  final String wrapper;
  MessageInfo(this.metadata, this.wrapper);
}

class MessageCache {
  late Map<int, MessageInfo> cache;
  late List<int?> cacheByIndex;

  MessageCache() {
    this.cache = {};
    this.cacheByIndex = List.empty(growable: true);
  }


  void addNew(int conversation, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data) {
    this.cache[messageID] = MessageInfo(MessageMetadata(profileOnion, conversation, messageID, timestamp, senderHandle, senderImage, "", {}, false, false, isAuto), data);
    this.cacheByIndex.insert(0, messageID);
  }

  void bumpMessageCache() {
    this.messageCache.insert(0, null);
    this.totalMessages += 1;
  }

  void ackCache(int messageID) {
    cache[messageID]?.metadata.ackd = true;
  }
}
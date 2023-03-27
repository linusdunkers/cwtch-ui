import 'dart:async';
import 'package:flutter/foundation.dart';
import 'message.dart';

// we only count up to 100 unread messages, if more than that we can't accurately resync message cache, just reset
// https://git.openprivacy.ca/cwtch.im/libcwtch-go/src/branch/trunk/utils/eventHandler.go#L210
const MaxUnreadBeforeCacheReset = 100;

class MessageInfo {
  late MessageMetadata metadata;
  late String wrapper;

  MessageInfo(this.metadata, this.wrapper);

  int size() {
    var wrapperSize = wrapper.length * 2;
    return wrapperSize;
  }
}

class LocalIndexMessage {
  late bool cacheOnly;
  late bool isLoading;
  late Future<void> loaded;
  late Completer<void> loader;

  late int? messageId;

  LocalIndexMessage(int? messageId, {cacheOnly = false, isLoading = false}) {
    this.messageId = messageId;
    this.cacheOnly = cacheOnly;
    this.isLoading = isLoading;
    if (isLoading) {
      loader = Completer<void>();
      loaded = loader.future;
    }
  }

  void finishLoad(int messageId) {
    this.messageId = messageId;
    isLoading = false;
    loader.complete(true);
  }

  void failLoad() {
    this.messageId = null;
    isLoading = false;
    loader.complete(true);
  }

  Future<void> waitForLoad() {
    return loaded;
  }

  Future<int?> get() async {
    if (isLoading) {
      await waitForLoad();
    }
    return messageId;
  }
}

// Message cache stores messages for use by the UI and uses MessageHandler and associated ByX loaders
// the cache stores messages in a cache indexed by their storage Id, and has two secondary indexes into it, content hash, and local index
// Index is the primary way to access the cache as it is a sequential ordered access and is used by the message pane
// contentHash is used for fetching replies
// by Id is used when composing a reply
// cacheByIndex supports additional features than just a direct index into the cache (byID)
// it allows locking of ranges in order to support bulk sequential loading (see ByIndex in message.dart)
// cacheByIndex allows allows inserting temporarily non storage backed messages so that Send Message can be respected instantly and then updated upon insertion into backend
// the message cache needs storageMessageCount maintained by the system so it can inform bulk loading when it's reaching the end of fetchable messages
class MessageCache extends ChangeNotifier {
  // cache of MessageId to Message
  late Map<int, MessageInfo> cache;

  // local index to MessageId
  late List<LocalIndexMessage> cacheByIndex;
  // index unsynced is used on android on reconnect to tell us new messages are in the backend that should be at the front of the index cache
  int _indexUnsynced = 0;

  // map of content hash to MessageId
  late Map<String, int> cacheByHash;

  late int _storageMessageCount;

  MessageCache(int storageMessageCount) {
    cache = {};
    cacheByIndex = List.empty(growable: true);
    cacheByHash = {};
    this._storageMessageCount = storageMessageCount;
  }

  int get storageMessageCount => _storageMessageCount;
  set storageMessageCount(int newval) {
    this._storageMessageCount = newval;
  }

  // On android reconnect, if backend supplied message count > UI message count, add the differnce to the front of the index
  void addFrontIndexGap(int count) {
    this._indexUnsynced = count;
  }

  int get indexUnsynced => _indexUnsynced;

  MessageInfo? getById(int id) => cache[id];

  Future<MessageInfo?> getByIndex(int index) async {
    if (index >= cacheByIndex.length) {
      return null;
    }
    var id = await cacheByIndex[index].get();
    if (id == null) {
      return Future<MessageInfo?>.value(null);
    }
    return cache[id];
  }

  int findIndex(int id) {
    return cacheByIndex.indexWhere((element) => element.messageId == id);
  }

  MessageInfo? getByContentHash(String contenthash) => cache[cacheByHash[contenthash]];

  void addNew(String profileOnion, int conversation, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data, String contenthash) {
    this.cache[messageID] = MessageInfo(MessageMetadata(profileOnion, conversation, messageID, timestamp, senderHandle, senderImage, "", {}, false, false, isAuto, contenthash), data);
    this.cacheByIndex.insert(0, LocalIndexMessage(messageID));
    if (contenthash != null && contenthash != "") {
      this.cacheByHash[contenthash] = messageID;
    }
  }

  // inserts place holder values into the index cache that will block on .get() until .finishLoad() is called on them with message contents
  // or .failLoad() is called on them to mark them malformed
  // this prevents successive ui message build requests from triggering multiple GetMesssage requests to the backend, as the first one locks a block of messages and the rest wait on that
  void lockIndexes(int start, int end) {
    for (var i = start; i < end; i++) {
      this.cacheByIndex.insert(i, LocalIndexMessage(null, isLoading: true));
      // if there are unsynced messages on the index cache it means there are messages at the front, and by the logic in message/ByIndex/get() we will be loading those
      // there for we can decrement the count as this will be one of them
      if (this._indexUnsynced > 0) {
        this._indexUnsynced--;
      }
    }
  }

  void malformIndexes(int start, int end) {
    for (var i = start; i < end; i++) {
      this.cacheByIndex[i].failLoad();
    }
  }

  void addIndexed(MessageInfo messageInfo, int index) {
    this.cache[messageInfo.metadata.messageID] = messageInfo;
    if (index < this.cacheByIndex.length) {
      this.cacheByIndex[index].finishLoad(messageInfo.metadata.messageID);
    } else {
      this.cacheByIndex.insert(index, LocalIndexMessage(messageInfo.metadata.messageID));
    }
    this.cacheByHash[messageInfo.metadata.contenthash] = messageInfo.metadata.messageID;
  }

  void addUnindexed(MessageInfo messageInfo) {
    this.cache[messageInfo.metadata.messageID] = messageInfo;
    if (messageInfo.metadata.contenthash != "") {
      this.cacheByHash[messageInfo.metadata.contenthash] = messageInfo.metadata.messageID;
    }
  }

  void ackCache(int messageID) {
    cache[messageID]?.metadata.ackd = true;
    notifyListeners();
  }

  void errCache(int messageID) {
    cache[messageID]?.metadata.error = true;
    notifyListeners();
  }

  void notifyUpdate(int messageID) {
    notifyListeners();
  }

  int size() {
    // very naive cache size, assuming MessageInfo are fairly large on average
    // and everything else is small in comparison
    int cacheSize = cache.entries.map((e) => e.value.size()).fold(0, (previousValue, element) => previousValue + element);
    return cacheSize + cacheByHash.length * 64 + cacheByIndex.length * 16;
  }

  void updateTranslationEvent(int messageID, String translation) {
    cache[messageID]?.metadata.updateTranslationEvent(translation);
    notifyListeners();
  }
}

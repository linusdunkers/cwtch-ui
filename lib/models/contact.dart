import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';

import 'message.dart';
import 'messagecache.dart';

class ContactInfoState extends ChangeNotifier {
  final String profileOnion;
  final int identifier;
  final String onion;
  late String _nickname;

  late bool _accepted;
  late bool _blocked;
  late String _status;
  late String _imagePath;
  late String _savePeerHistory;
  late int _unreadMessages = 0;
  late int _totalMessages = 0;
  late DateTime _lastMessageTime;
  late Map<String, GlobalKey<MessageRowState>> keys;
  late List<MessageCache?> messageCache;
  int _newMarker = 0;
  DateTime _newMarkerClearAt = DateTime.now();

  // todo: a nicer way to model contacts, groups and other "entities"
  late bool _isGroup;
  String? _server;
  late bool _archived;

  String? _acnCircuit;

  ContactInfoState(this.profileOnion, this.identifier, this.onion,
      {nickname = "",
      isGroup = false,
      accepted = false,
      blocked = false,
      status = "",
      imagePath = "",
      savePeerHistory = "DeleteHistoryConfirmed",
      numMessages = 0,
      numUnread = 0,
      lastMessageTime,
      server,
      archived = false}) {
    this._nickname = nickname;
    this._isGroup = isGroup;
    this._accepted = accepted;
    this._blocked = blocked;
    this._status = status;
    this._imagePath = imagePath;
    this._totalMessages = numMessages;
    this._unreadMessages = numUnread;
    this._savePeerHistory = savePeerHistory;
    this._lastMessageTime = lastMessageTime == null ? DateTime.fromMillisecondsSinceEpoch(0) : lastMessageTime;
    this._server = server;
    this._archived = archived;
    this.messageCache = List.empty(growable: true);
    keys = Map<String, GlobalKey<MessageRowState>>();
  }

  String get nickname => this._nickname;

  String get savePeerHistory => this._savePeerHistory;

  String? get acnCircuit => this._acnCircuit;
  set acnCircuit(String? acnCircuit) {
    this._acnCircuit = acnCircuit;
    notifyListeners();
  }

  // Indicated whether the conversation is archived, in which case it will
  // be moved to the very bottom of the active conversations list until
  // new messages appear
  set isArchived(bool archived) {
    this._archived = archived;
    notifyListeners();
  }

  bool get isArchived => this._archived;

  set savePeerHistory(String newVal) {
    this._savePeerHistory = newVal;
    notifyListeners();
  }

  set nickname(String newVal) {
    this._nickname = newVal;
    notifyListeners();
  }

  bool get isGroup => this._isGroup;
  set isGroup(bool newVal) {
    this._isGroup = newVal;
    notifyListeners();
  }

  bool get isBlocked => this._blocked;

  bool get isInvitation => !this._blocked && !this._accepted;

  set accepted(bool newVal) {
    this._accepted = newVal;
    notifyListeners();
  }

  set blocked(bool newVal) {
    this._blocked = newVal;
    notifyListeners();
  }

  String get status => this._status;
  set status(String newVal) {
    this._status = newVal;
    notifyListeners();
  }

  int get unreadMessages => this._unreadMessages;
  set unreadMessages(int newVal) {
    // don't reset newMarker position when unreadMessages is being cleared
    if (newVal > 0) {
      this._newMarker = newVal;
    } else {
      this._newMarkerClearAt = DateTime.now().add(const Duration(minutes: 2));
    }
    this._unreadMessages = newVal;
    notifyListeners();
  }

  int get newMarker {
    if (DateTime.now().isAfter(this._newMarkerClearAt)) {
      // perform heresy
      this._newMarker = 0;
      // no need to notifyListeners() because presumably this getter is
      // being called from a renderer anyway
    }
    return this._newMarker;
  }

  // what's a getter that sometimes sets without a setter
  // that sometimes doesn't set
  set newMarker(int newVal) {
    // only unreadMessages++ can set newMarker = 1;
    // avoids drawing a marker when the convo is already open
    if (newVal >= 1) {
      this._newMarker = newVal;
      notifyListeners();
    }
  }

  int get totalMessages => this._totalMessages;
  set totalMessages(int newVal) {
    this._totalMessages = newVal;
    notifyListeners();
  }

  String get imagePath => this._imagePath;
  set imagePath(String newVal) {
    this._imagePath = newVal;
    notifyListeners();
  }

  DateTime get lastMessageTime => this._lastMessageTime;
  set lastMessageTime(DateTime newVal) {
    this._lastMessageTime = newVal;
    notifyListeners();
  }

  // we only allow callers to fetch the server
  get server => this._server;

  bool isOnline() {
    if (this.isGroup == true) {
      // We now have an out of sync warning so we will mark these as online...
      return this.status == "Authenticated" || this.status == "Synced";
    } else {
      return this.status == "Authenticated";
    }
  }

  GlobalKey<MessageRowState> getMessageKey(int conversation, int message) {
    String index = "c: " + conversation.toString() + " m:" + message.toString();
    if (keys[index] == null) {
      keys[index] = GlobalKey<MessageRowState>();
    }
    GlobalKey<MessageRowState> ret = keys[index]!;
    return ret;
  }

  GlobalKey<MessageRowState>? getMessageKeyOrFail(int conversation, int message) {
    String index = "c: " + conversation.toString() + " m:" + message.toString();

    if (keys[index] == null) {
      return null;
    }
    GlobalKey<MessageRowState> ret = keys[index]!;
    return ret;
  }

  void updateMessageCache(int conversation, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data) {
    this.messageCache.insert(0, MessageCache(MessageMetadata(profileOnion, conversation, messageID, timestamp, senderHandle, senderImage, "", {}, false, false, isAuto), data));
    this.totalMessages += 1;
  }

  void bumpMessageCache() {
    this.messageCache.insert(0, null);
    this.totalMessages += 1;
  }

  void ackCache(int messageID) {
    this.messageCache.firstWhere((element) => element?.metadata.messageID == messageID)?.metadata.ackd = true;
    notifyListeners();
  }
}

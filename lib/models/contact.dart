import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'message.dart';
import 'messagecache.dart';

enum ConversationNotificationPolicy {
  Default,
  OptIn,
  Never,
}

extension Nameable on ConversationNotificationPolicy {
  String toName(BuildContext context) {
    switch (this) {
      case ConversationNotificationPolicy.Default:
        return AppLocalizations.of(context)!.conversationNotificationPolicyDefault;
      case ConversationNotificationPolicy.OptIn:
        return AppLocalizations.of(context)!.conversationNotificationPolicyOptIn;
      case ConversationNotificationPolicy.Never:
        return AppLocalizations.of(context)!.conversationNotificationPolicyNever;
    }
  }
}

class ContactInfoState extends ChangeNotifier {
  final String profileOnion;
  final int identifier;
  final String onion;
  late String _nickname;

  late ConversationNotificationPolicy _notificationPolicy;

  late bool _accepted;
  late bool _blocked;
  late String _status;
  late String _imagePath;
  late String _defaultImagePath;
  late String _savePeerHistory;
  late int _unreadMessages = 0;
  late int _totalMessages = 0;
  late DateTime _lastMessageTime;
  late Map<String, GlobalKey<MessageRowState>> keys;
  int _newMarkerMsgIndex = -1;
  late MessageCache messageCache;

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
      defaultImagePath = "",
      savePeerHistory = "DeleteHistoryConfirmed",
      numMessages = 0,
      numUnread = 0,
      lastMessageTime,
      server,
      archived = false,
      notificationPolicy = "ConversationNotificationPolicy.Default"}) {
    this._nickname = nickname;
    this._isGroup = isGroup;
    this._accepted = accepted;
    this._blocked = blocked;
    this._status = status;
    this._imagePath = imagePath;
    this._defaultImagePath = defaultImagePath;
    this._totalMessages = numMessages;
    this._unreadMessages = numUnread;
    this._savePeerHistory = savePeerHistory;
    this._lastMessageTime = lastMessageTime == null ? DateTime.fromMillisecondsSinceEpoch(0) : lastMessageTime;
    this._server = server;
    this._archived = archived;
    this._notificationPolicy = notificationPolicyFromString(notificationPolicy);
    this.messageCache = new MessageCache(_totalMessages);
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

  void selected() {
    this._newMarkerMsgIndex = this._unreadMessages - 1;
    this._unreadMessages = 0;
  }

  void unselected() {
    this._newMarkerMsgIndex = -1;
  }

  int get unreadMessages => this._unreadMessages;

  set unreadMessages(int newVal) {
    this._unreadMessages = newVal;
    notifyListeners();
  }

  int get newMarkerMsgIndex {
    return this._newMarkerMsgIndex;
  }

  int get totalMessages => this._totalMessages;

  set totalMessages(int newVal) {
    this._totalMessages = newVal;
    this.messageCache.storageMessageCount = newVal;
    notifyListeners();
  }

  String get imagePath {
    // don't show custom images for blocked contacts..
    if (!this.isBlocked) {
      return this._imagePath;
    }
    return this.defaultImagePath;
  }

  set imagePath(String newVal) {
    this._imagePath = newVal;
    notifyListeners();
  }

  String get defaultImagePath => this._defaultImagePath;

  set defaultImagePath(String newVal) {
    this._defaultImagePath = newVal;
    notifyListeners();
  }

  DateTime get lastMessageTime => this._lastMessageTime;

  set lastMessageTime(DateTime newVal) {
    this._lastMessageTime = newVal;
    notifyListeners();
  }

  // we only allow callers to fetch the server
  String? get server => this._server;

  bool isOnline() {
    if (this.isGroup == true) {
      // We now have an out of sync warning so we will mark these as online...
      return this.status == "Authenticated" || this.status == "Synced";
    } else {
      return this.status == "Authenticated";
    }
  }

  ConversationNotificationPolicy get notificationsPolicy => _notificationPolicy;

  set notificationsPolicy(ConversationNotificationPolicy newVal) {
    _notificationPolicy = newVal;
    notifyListeners();
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

  void newMessage(int identifier, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data, String contenthash, bool selectedConversation) {
    if (!selectedConversation) {
      unreadMessages++;
    }
    if (_newMarkerMsgIndex == -1) {
      if (!selectedConversation) {
        _newMarkerMsgIndex = 0;
      }
    } else {
      _newMarkerMsgIndex++;
    }

    this._lastMessageTime = timestamp;
    this.messageCache.addNew(profileOnion, identifier, messageID, timestamp, senderHandle, senderImage, isAuto, data, contenthash);
    this.totalMessages += 1;

    // We only ever see messages from authenticated peers.
    // If the contact is marked as offline then override this - can happen when the contact is removed from the front
    // end during syncing.
    if (isOnline() == false) {
      status = "Authenticated";
    }
    notifyListeners();
  }

  void ackCache(int messageID) {
    this.messageCache.ackCache(messageID);
    notifyListeners();
  }

  void errCache(int messageID) {
    this.messageCache.errCache(messageID);
    notifyListeners();
  }

  static ConversationNotificationPolicy notificationPolicyFromString(String val) {
    switch (val) {
      case "ConversationNotificationPolicy.Default":
        return ConversationNotificationPolicy.Default;
      case "ConversationNotificationPolicy.OptIn":
        return ConversationNotificationPolicy.OptIn;
      case "ConversationNotificationPolicy.Never":
        return ConversationNotificationPolicy.Never;
    }
    return ConversationNotificationPolicy.Never;
  }
}

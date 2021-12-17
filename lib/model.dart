import 'dart:convert';

import 'package:cwtch/config.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/cupertino.dart';
import 'package:cwtch/models/profileservers.dart';

////////////////////
///   UI State   ///
////////////////////

class ChatMessage {
  final int o;
  final String d;

  ChatMessage({required this.o, required this.d});

  ChatMessage.fromJson(Map<String, dynamic> json)
      : o = json['o'],
        d = json['d'];

  Map<String, dynamic> toJson() => {
        'o': o,
        'd': d,
      };
}

enum ModalState {
  none,
  storageMigration
}

class AppState extends ChangeNotifier {
  bool cwtchInit = false;
  ModalState modalState = ModalState.none;
  bool cwtchIsClosing = false;
  String appError = "";
  String? _selectedProfile;
  int? _selectedConversation;
  int _initialScrollIndex = 0;
  int _hoveredIndex = -1;
  int? _selectedIndex;
  bool _unreadMessagesBelow = false;

  void SetCwtchInit() {
    cwtchInit = true;
    notifyListeners();
  }

  void SetAppError(String error) {
    appError = error;
    notifyListeners();
  }

  void SetModalState(ModalState newState) {
    modalState = newState;
    notifyListeners();
  }

  String? get selectedProfile => _selectedProfile;
  set selectedProfile(String? newVal) {
    this._selectedProfile = newVal;
    notifyListeners();
  }

  int? get selectedConversation => _selectedConversation;
  set selectedConversation(int? newVal) {
    this._selectedConversation = newVal;
    notifyListeners();
  }

  int? get selectedIndex => _selectedIndex;
  set selectedIndex(int? newVal) {
    this._selectedIndex = newVal;
    notifyListeners();
  }

  // Never use this for message lookup - can be a non-indexed value
  // e.g. -1
  int get hoveredIndex => _hoveredIndex;
  set hoveredIndex(int newVal) {
    this._hoveredIndex = newVal;
    notifyListeners();
  }

  bool get unreadMessagesBelow => _unreadMessagesBelow;
  set unreadMessagesBelow(bool newVal) {
    this._unreadMessagesBelow = newVal;
    notifyListeners();
  }

  int get initialScrollIndex => _initialScrollIndex;
  set initialScrollIndex(int newVal) {
    this._initialScrollIndex = newVal;
    notifyListeners();
  }

  bool isLandscape(BuildContext c) => MediaQuery.of(c).size.width > MediaQuery.of(c).size.height;
}

///////////////////
///  Providers  ///
///////////////////

class ProfileListState extends ChangeNotifier {
  List<ProfileInfoState> _profiles = [];
  int get num => _profiles.length;

  void add(String onion, String name, String picture, String contactsJson, String serverJson, bool online, bool encrypted) {
    var idx = _profiles.indexWhere((element) => element.onion == onion);
    if (idx == -1) {
      _profiles.add(ProfileInfoState(onion: onion, nickname: name, imagePath: picture, contactsJson: contactsJson, serversJson: serverJson, online: online, encrypted: encrypted));
    } else {
      _profiles[idx].updateFrom(onion, name, picture, contactsJson, serverJson, online);
    }
    notifyListeners();
  }

  List<ProfileInfoState> get profiles => _profiles.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

  ProfileInfoState? getProfile(String onion) {
    int idx = _profiles.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _profiles[idx] : null;
  }

  void delete(String onion) {
    _profiles.removeWhere((element) => element.onion == onion);
    notifyListeners();
  }
}

class ContactListState extends ChangeNotifier {
  ProfileServerListState? servers;
  List<ContactInfoState> _contacts = [];
  String _filter = "";
  int get num => _contacts.length;
  int get numFiltered => isFiltered ? filteredList().length : num;
  bool get isFiltered => _filter != "";
  String get filter => _filter;
  set filter(String newVal) {
    _filter = newVal.toLowerCase();
    notifyListeners();
  }

  void connectServers(ProfileServerListState servers) {
    this.servers = servers;
  }

  List<ContactInfoState> filteredList() {
    if (!isFiltered) return contacts;
    return _contacts.where((ContactInfoState c) => c.onion.toLowerCase().startsWith(_filter) || (c.nickname.toLowerCase().contains(_filter))).toList();
  }

  void addAll(Iterable<ContactInfoState> newContacts) {
    _contacts.addAll(newContacts);
    servers?.clearGroups();
    _contacts.forEach((contact) {
      if (contact.isGroup) {
        servers?.addGroup(contact);
      }
    });
    notifyListeners();
  }

  void add(ContactInfoState newContact) {
    _contacts.add(newContact);
    if (newContact.isGroup) {
      servers?.addGroup(newContact);
    }
    notifyListeners();
  }

  void resort() {
    _contacts.sort((ContactInfoState a, ContactInfoState b) {
      // return -1 = a first in list
      // return 1 = b first in list
      // blocked contacts last
      if (a.isBlocked == true && b.isBlocked != true) return 1;
      if (a.isBlocked != true && b.isBlocked == true) return -1;
      // archive is next...
      if (!a.isArchived && b.isArchived) return -1;
      if (a.isArchived && !b.isArchived) return 1;
      // special sorting for contacts with no messages in either history
      if (a.lastMessageTime.millisecondsSinceEpoch == 0 && b.lastMessageTime.millisecondsSinceEpoch == 0) {
        // online contacts first
        if (a.isOnline() && !b.isOnline()) return -1;
        if (!a.isOnline() && b.isOnline()) return 1;
        // finally resort to onion
        return a.onion.toString().compareTo(b.onion.toString());
      }
      // finally... most recent history first
      if (a.lastMessageTime.millisecondsSinceEpoch == 0) return 1;
      if (b.lastMessageTime.millisecondsSinceEpoch == 0) return -1;
      return b.lastMessageTime.compareTo(a.lastMessageTime);
    });
    //<todo> if(changed) {
    notifyListeners();
    //} </todo>
  }

  void updateLastMessageTime(int forIdentifier, DateTime newMessageTime) {
    var contact = getContact(forIdentifier);
    if (contact == null) return;

    // Assert that the new time is after the current last message time AND that
    // new message time is before the current time.
    if (newMessageTime.isAfter(contact.lastMessageTime)) {
      if (newMessageTime.isBefore(DateTime.now().toLocal())) {
        contact.lastMessageTime = newMessageTime;
      } else {
        // Otherwise set the last message time to now...
        contact.lastMessageTime = DateTime.now().toLocal();
      }
      resort();
    }
  }

  List<ContactInfoState> get contacts => _contacts.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

  ContactInfoState? getContact(int identifier) {
    int idx = _contacts.indexWhere((element) => element.identifier == identifier);
    return idx >= 0 ? _contacts[idx] : null;
  }

  void removeContact(int identifier) {
    int idx = _contacts.indexWhere((element) => element.identifier == identifier);
    if (idx >= 0) {
      _contacts.removeAt(idx);
      notifyListeners();
    }
  }

  ContactInfoState? findContact(String byHandle) {
    int idx = _contacts.indexWhere((element) => element.onion == byHandle);
    return idx >= 0 ? _contacts[idx] : null;
  }
}

class ProfileInfoState extends ChangeNotifier {
  ProfileServerListState _servers = ProfileServerListState();
  ContactListState _contacts = ContactListState();
  final String onion;
  String _nickname = "";
  String _imagePath = "";
  int _unreadMessages = 0;
  bool _online = false;
  Map<String, FileDownloadProgress> _downloads = Map<String, FileDownloadProgress>();

  // assume profiles are encrypted...this will be set to false
  // in the constructor if the profile is encrypted with the defacto password.
  bool _encrypted = true;

  ProfileInfoState({
    required this.onion,
    nickname = "",
    imagePath = "",
    unreadMessages = 0,
    contactsJson = "",
    serversJson = "",
    online = false,
    encrypted = true,
  }) {
    this._nickname = nickname;
    this._imagePath = imagePath;
    this._unreadMessages = unreadMessages;
    this._online = online;
    this._encrypted = encrypted;

    _contacts.connectServers(this._servers);

    if (contactsJson != null && contactsJson != "" && contactsJson != "null") {
      this.replaceServers(serversJson);

      List<dynamic> contacts = jsonDecode(contactsJson);
      this._contacts.addAll(contacts.map((contact) {
        return ContactInfoState(this.onion, contact["identifier"], contact["onion"],
            nickname: contact["name"],
            status: contact["status"],
            imagePath: contact["picture"],
            authorization: stringToContactAuthorization(contact["authorization"]),
            savePeerHistory: contact["saveConversationHistory"],
            numMessages: contact["numMessages"],
            numUnread: contact["numUnread"],
            isGroup: contact["isGroup"],
            server: contact["groupServer"],
            archived: contact["isArchived"] == true,
            lastMessageTime: DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"])));
      }));

      // dummy set to invoke sort-on-load
      if (this._contacts.num > 0) {
        this._contacts.updateLastMessageTime(this._contacts._contacts.first.identifier, this._contacts._contacts.first.lastMessageTime);
      }
    }
  }

  // Parse out the server list json into our server info state struct...
  void replaceServers(String serversJson) {
    if (serversJson != "" && serversJson != "null") {
      List<dynamic> servers = jsonDecode(serversJson);
      this._servers.replace(servers.map((server) {
        // TODO Keys...
        return RemoteServerInfoState(onion: server["onion"], identifier: server["identifier"], description: server["description"], status: server["status"]);
      }));

      this._contacts.contacts.forEach((contact) {
        if (contact.isGroup) {
          _servers.addGroup(contact);
        }
      });

      notifyListeners();
    }
  }

  //
  void updateServerStatusCache(String server, String status) {
    this._servers.updateServerState(server, status);
    notifyListeners();
  }

  //  Getters and Setters for Online Status
  bool get isOnline => this._online;
  set isOnline(bool newValue) {
    this._online = newValue;
    notifyListeners();
  }

  // Check encrypted status for profile info screen
  bool get isEncrypted => this._encrypted;

  String get nickname => this._nickname;
  set nickname(String newValue) {
    this._nickname = newValue;
    notifyListeners();
  }

  String get imagePath => this._imagePath;
  set imagePath(String newVal) {
    this._imagePath = newVal;
    notifyListeners();
  }

  int get unreadMessages => this._unreadMessages;
  set unreadMessages(int newVal) {
    this._unreadMessages = newVal;
    notifyListeners();
  }

  // Remove a contact from a list. Currently only used when rejecting a group invitation.
  // Eventually will also be used for other removals.
  void removeContact(String handle) {
    int idx = this.contactList._contacts.indexWhere((element) => element.onion == handle);
    this.contactList._contacts.removeAt(idx);
    notifyListeners();
  }

  ContactListState get contactList => this._contacts;
  ProfileServerListState get serverList => this._servers;

  @override
  void dispose() {
    super.dispose();
    print("profileinfostate.dispose()");
  }

  void updateFrom(String onion, String name, String picture, String contactsJson, String serverJson, bool online) {
    this._nickname = name;
    this._imagePath = picture;
    this._online = online;
    this.replaceServers(serverJson);

    if (contactsJson != null && contactsJson != "" && contactsJson != "null") {
      List<dynamic> contacts = jsonDecode(contactsJson);
      contacts.forEach((contact) {
        var profileContact = this._contacts.getContact(contact["onion"]);
        if (profileContact != null) {
          profileContact.status = contact["status"];
          profileContact.totalMessages = contact["numMessages"];
          profileContact.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"]));
        } else {
          this._contacts.add(ContactInfoState(
                this.onion,
                contact["identifier"],
                contact["onion"],
                nickname: contact["name"],
                status: contact["status"],
                imagePath: contact["picture"],
                authorization: stringToContactAuthorization(contact["authorization"]),
                savePeerHistory: contact["saveConversationHistory"],
                numMessages: contact["numMessages"],
                numUnread: contact["numUnread"],
                isGroup: contact["isGroup"],
                server: contact["groupServer"],
                lastMessageTime: DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"])),
              ));
        }
      });
    }
  }

  void downloadInit(String fileKey, int numChunks) {
    this._downloads[fileKey] = FileDownloadProgress(numChunks, DateTime.now());
  }

  void downloadUpdate(String fileKey, int progress, int numChunks) {
    if (!downloadActive(fileKey)) {
      if (progress < 0) {
        this._downloads[fileKey] = FileDownloadProgress(numChunks, DateTime.now());
        this._downloads[fileKey]!.interrupted = true;
        notifyListeners();
      } else {
        print("error: received progress for unknown download " + fileKey);
      }
    } else {
      if (this._downloads[fileKey]!.interrupted) {
        this._downloads[fileKey]!.interrupted = false;
      }
      this._downloads[fileKey]!.chunksDownloaded = progress;
      this._downloads[fileKey]!.chunksTotal = numChunks;
      notifyListeners();
    }
  }

  void downloadMarkManifest(String fileKey) {
    if (!downloadActive(fileKey)) {
      print("error: received download completion notice for unknown download " + fileKey);
    } else {
      this._downloads[fileKey]!.gotManifest = true;
      notifyListeners();
    }
  }

  void downloadMarkFinished(String fileKey, String finalPath) {
    if (!downloadActive(fileKey)) {
      // happens as a result of a CheckDownloadStatus call,
      // invoked from a historical (timeline) download message
      // so setting numChunks correctly shouldn't matter
      this.downloadInit(fileKey, 1);
    }
    this._downloads[fileKey]!.timeEnd = DateTime.now();
    this._downloads[fileKey]!.downloadedTo = finalPath;
    this._downloads[fileKey]!.complete = true;
    notifyListeners();
  }

  bool downloadActive(String fileKey) {
    return this._downloads.containsKey(fileKey) && !this._downloads[fileKey]!.interrupted;
  }

  bool downloadGotManifest(String fileKey) {
    return this._downloads.containsKey(fileKey) && this._downloads[fileKey]!.gotManifest;
  }

  bool downloadComplete(String fileKey) {
    return this._downloads.containsKey(fileKey) && this._downloads[fileKey]!.complete;
  }

  bool downloadInterrupted(String fileKey) {
    return this._downloads.containsKey(fileKey) && this._downloads[fileKey]!.interrupted;
  }

  void downloadMarkResumed(String fileKey) {
    if (this._downloads.containsKey(fileKey)) {
      this._downloads[fileKey]!.interrupted = false;
    }
  }

  double downloadProgress(String fileKey) {
    return this._downloads.containsKey(fileKey) ? this._downloads[fileKey]!.progress() : 0.0;
  }

  // used for loading interrupted download info; use downloadMarkFinished for successful downloads
  void downloadSetPath(String fileKey, String path) {
    if (this._downloads.containsKey(fileKey)) {
      this._downloads[fileKey]!.downloadedTo = path;
    }
  }

  String? downloadFinalPath(String fileKey) {
    return this._downloads.containsKey(fileKey) ? this._downloads[fileKey]!.downloadedTo : null;
  }

  String downloadSpeed(String fileKey) {
    if (!downloadActive(fileKey) || this._downloads[fileKey]!.chunksDownloaded == 0) {
      return "0 B/s";
    }
    var bytes = this._downloads[fileKey]!.chunksDownloaded * 4096;
    var seconds = (this._downloads[fileKey]!.timeEnd ?? DateTime.now()).difference(this._downloads[fileKey]!.timeStart!).inSeconds;
    if (seconds == 0) {
      return "0 B/s";
    }
    return prettyBytes((bytes / seconds).round()) + "/s";
  }
}

class FileDownloadProgress {
  int chunksDownloaded = 0;
  int chunksTotal = 1;
  bool complete = false;
  bool gotManifest = false;
  bool interrupted = false;
  String? downloadedTo;
  DateTime? timeStart;
  DateTime? timeEnd;

  FileDownloadProgress(this.chunksTotal, this.timeStart);
  double progress() {
    return 1.0 * chunksDownloaded / chunksTotal;
  }
}

String prettyBytes(int bytes) {
  if (bytes > 1000000000) {
    return (1.0 * bytes / 1000000000).toStringAsFixed(1) + " GB";
  } else if (bytes > 1000000) {
    return (1.0 * bytes / 1000000).toStringAsFixed(1) + " MB";
  } else if (bytes > 1000) {
    return (1.0 * bytes / 1000).toStringAsFixed(1) + " kB";
  } else {
    return bytes.toString() + " B";
  }
}

enum ContactAuthorization { unknown, approved, blocked }

ContactAuthorization stringToContactAuthorization(String authStr) {
  switch (authStr) {
    case "approved":
      return ContactAuthorization.approved;
    case "blocked":
      return ContactAuthorization.blocked;
    default:
      return ContactAuthorization.unknown;
  }
}

class MessageCache {
  final MessageMetadata metadata;
  final String wrapper;
  MessageCache(this.metadata, this.wrapper);
}

class ContactInfoState extends ChangeNotifier {
  final String profileOnion;
  final int identifier;
  final String onion;
  late String _nickname;

  late ContactAuthorization _authorization;
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

  ContactInfoState(this.profileOnion, this.identifier, this.onion,
      {nickname = "",
      isGroup = false,
      authorization = ContactAuthorization.unknown,
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
    this._authorization = authorization;
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

  bool get isBlocked => this._authorization == ContactAuthorization.blocked;

  bool get isInvitation => this._authorization == ContactAuthorization.unknown;

  ContactAuthorization get authorization => this._authorization;
  set authorization(ContactAuthorization newAuth) {
    this._authorization = newAuth;
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

  void updateMessageCache(int conversation, int messageID, DateTime timestamp, String senderHandle, String senderImage, String data) {
    this.messageCache.insert(0, MessageCache(MessageMetadata(profileOnion, conversation, messageID, timestamp, senderHandle, senderImage, "", {}, false, false), data));
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

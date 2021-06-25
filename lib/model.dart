import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/widgets/messagebubble.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:collection';

import 'cwtch/cwtch.dart';
import 'main.dart';

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

class AppState extends ChangeNotifier {
  bool cwtchInit = false;
  bool cwtchIsClosing = false;
  String appError = "";
  String? _selectedProfile;
  String? _selectedConversation;

  void SetCwtchInit() {
    cwtchInit = true;
    notifyListeners();
  }

  void SetAppError(String error) {
    appError = error;
    notifyListeners();
  }

  String? get selectedProfile => _selectedProfile;
  set selectedProfile(String? newVal) {
    this._selectedProfile = newVal;
    notifyListeners();
  }

  String? get selectedConversation => _selectedConversation;
  set selectedConversation(String? newVal) {
    this._selectedConversation = newVal;
    notifyListeners();
  }

  bool isLandscape(BuildContext c) => MediaQuery.of(c).size.width > MediaQuery.of(c).size.height;
}

class ContactListState extends ChangeNotifier {
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

  List<ContactInfoState> filteredList() {
    if (!isFiltered) return contacts;
    return _contacts.where((ContactInfoState c) => c.onion.toLowerCase().startsWith(_filter) || (c.nickname.toLowerCase().contains(_filter))).toList();
  }

  void addAll(Iterable<ContactInfoState> newContacts) {
    _contacts.addAll(newContacts);
    notifyListeners();
  }

  void add(ContactInfoState newContact) {
    _contacts.add(newContact);
    notifyListeners();
  }

  void resort() {
    _contacts.sort((ContactInfoState a, ContactInfoState b) {
      // return -1 = a first in list
      // return 1 = b first in list
      // blocked contacts last
      if (a.isBlocked == true && b.isBlocked != true) return 1;
      if (a.isBlocked != true && b.isBlocked == true) return -1;
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

  void updateLastMessageTime(String forOnion, DateTime newVal) {
    var contact = getContact(forOnion);
    if (contact == null) return;

    contact.lastMessageTime = newVal;
    resort();
  }

  List<ContactInfoState> get contacts => _contacts.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

  ContactInfoState? getContact(String onion) {
    int idx = _contacts.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _contacts[idx] : null;
  }

  void removeContact(String onion) {
    int idx = _contacts.indexWhere((element) => element.onion == onion);
    if (idx >= 0) {
      _contacts.removeAt(idx);
      notifyListeners();
    }
  }
}

class ProfileInfoState extends ChangeNotifier {
  ContactListState _contacts = ContactListState();
  ServerListState _servers = ServerListState();
  final String onion;
  String _nickname = "";
  String _imagePath = "";
  int _unreadMessages = 0;
  bool _online = false;

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

    if (contactsJson != null && contactsJson != "" && contactsJson != "null") {
      List<dynamic> contacts = jsonDecode(contactsJson);
      this._contacts.addAll(contacts.map((contact) {
        return ContactInfoState(this.onion, contact["onion"],
            nickname: contact["name"],
            status: contact["status"],
            imagePath: contact["picture"],
            isBlocked: contact["authorization"] == "blocked",
            isInvitation: contact["authorization"] == "unknown",
            savePeerHistory: contact["saveConversationHistory"],
            numMessages: contact["numMessages"],
            numUnread: contact["numUnread"],
            isGroup: contact["isGroup"],
            server: contact["groupServer"],
            lastMessageTime: DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"])));
      }));

      // dummy set to invoke sort-on-load
      if (this._contacts.num > 0) {
        this._contacts.updateLastMessageTime(this._contacts._contacts.first.onion, this._contacts._contacts.first.lastMessageTime);
      }
    }

    this.replaceServers(serversJson);
  }

  // Parse out the server list json into our server info state struct...
  void replaceServers(String serversJson) {
    if (serversJson != "" && serversJson != "null") {
      print("got servers $serversJson");
      List<dynamic> servers = jsonDecode(serversJson);
      this._servers.replace(servers.map((server) {
        // TODO Keys...
        return ServerInfoState(onion: server["onion"], status: server["status"]);
      }));
      notifyListeners();
    }
  }

  //
  void updateServerStatusCache(String server, String status) {
    this._servers.updateServerCache(server, status);
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
  ServerListState get serverList => this._servers;

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
                contact["onion"],
                nickname: contact["name"],
                status: contact["status"],
                imagePath: contact["picture"],
                isBlocked: contact["authorization"] == "blocked",
                isInvitation: contact["authorization"] == "unknown",
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
}

class ContactInfoState extends ChangeNotifier {
  final String profileOnion;
  final String onion;
  late String _nickname;

  late bool _isInvitation;
  late bool _isBlocked;
  late String _status;
  late String _imagePath;
  late String _savePeerHistory;
  late int _unreadMessages = 0;
  late int _totalMessages = 0;
  late DateTime _lastMessageTime;
  late Map<String, GlobalKey<MessageBubbleState>> keys;

  // todo: a nicer way to model contacts, groups and other "entities"
  late bool _isGroup;
  String? _server;

  ContactInfoState(
    this.profileOnion,
    this.onion, {
    nickname = "",
    isGroup = false,
    isInvitation = false,
    isBlocked = false,
    status = "",
    imagePath = "",
    savePeerHistory = "DeleteHistoryConfirmed",
    numMessages = 0,
    numUnread = 0,
    lastMessageTime,
    server,
  }) {
    this._nickname = nickname;
    this._isGroup = isGroup;
    this._isInvitation = isInvitation;
    this._isBlocked = isBlocked;
    this._status = status;
    this._imagePath = imagePath;
    this._totalMessages = numMessages;
    this._unreadMessages = numUnread;
    this._savePeerHistory = savePeerHistory;
    this._lastMessageTime = lastMessageTime == null ? DateTime.fromMillisecondsSinceEpoch(0) : lastMessageTime;
    this._server = server;
    keys = Map<String, GlobalKey<MessageBubbleState>>();
  }

  String get nickname => this._nickname;

  String get savePeerHistory => this._savePeerHistory;
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

  bool get isBlocked => this._isBlocked;
  set isBlocked(bool newVal) {
    this._isBlocked = newVal;
    notifyListeners();
  }

  bool get isInvitation => this._isInvitation;
  set isInvitation(bool newVal) {
    this._isInvitation = newVal;
    notifyListeners();
  }

  String get status => this._status;
  set status(String newVal) {
    this._status = newVal;
    notifyListeners();
  }

  int get unreadMessages => this._unreadMessages;
  set unreadMessages(int newVal) {
    this._unreadMessages = newVal;
    notifyListeners();
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

  GlobalKey<MessageBubbleState> getMessageKey(String index) {
    if (keys[index] == null) {
      keys[index] = GlobalKey<MessageBubbleState>();
    }
    GlobalKey<MessageBubbleState> ret = keys[index]!;
    return ret;
  }
}

class MessageState extends ChangeNotifier {
  final String profileOnion;
  final String contactHandle;
  final int messageIndex;
  late String _message;
  late int _overlay;
  late String _inviteTarget;
  late String _inviteNick;
  late DateTime _timestamp;
  late String _senderOnion;
  late int _flags;
  String? _senderImage;
  late String _signature = "";
  late bool _ackd = false;
  late bool _error = false;
  late bool _loaded = false;
  late bool _malformed = false;

  MessageState({
    required BuildContext context,
    required this.profileOnion,
    required this.contactHandle,
    required this.messageIndex,
  }) {
    this._senderOnion = profileOnion;
    tryLoad(context);
  }

  get message => this._message;
  get overlay => this._overlay;
  get timestamp => this._timestamp;
  int get flags => this._flags;
  set flags(int newVal) {
    this._flags = newVal;
    notifyListeners();
  }

  bool get ackd => this._ackd;
  bool get error => this._error;
  bool get malformed => this._malformed;
  bool get loaded => this._loaded;
  get senderOnion => this._senderOnion;
  get senderImage => this._senderImage;
  get signature => this._signature;
  get isInvite => this.overlay == 100 || this.overlay == 101;
  get inviteTarget => this._inviteTarget;
  get inviteNick => this._inviteNick;

  set ackd(bool newVal) {
    this._ackd = newVal;
    notifyListeners();
  }

  set error(bool newVal) {
    this._error = newVal;
    notifyListeners();
  }

  set malformed(bool newVal) {
    this._malformed = newVal;
    notifyListeners();
  }

  set loaded(bool newVal) {
    // quickly-arriving messages get discarded before loading sometimes
    if (!hasListeners) return;
    this._loaded = newVal;
    notifyListeners();
  }

  void tryLoad(BuildContext context) {
    Provider.of<FlwtchState>(context, listen: false).cwtch.GetMessage(profileOnion, contactHandle, messageIndex).then((jsonMessage) {
      try {
        dynamic messageWrapper = jsonDecode(jsonMessage);
        if (messageWrapper['Message'] == null || messageWrapper['Message'] == '' || messageWrapper['Message'] == '{}') {
          this._senderOnion = profileOnion;
          Future.delayed(const Duration(milliseconds: 2), () {
            tryLoad(context);
          });
          return;
        }
        dynamic message = jsonDecode(messageWrapper['Message']);
        this._message = message['d'];
        this._overlay = int.parse(message['o'].toString());
        this._timestamp = DateTime.tryParse(messageWrapper['Timestamp'])!;
        this._senderOnion = messageWrapper['PeerID'];
        this._senderImage = messageWrapper['ContactImage'];
        this._flags = int.parse(messageWrapper['Flags'].toString(), radix: 2);

        // If this is a group, store the signature
        if (contactHandle.length == 32) {
          this._signature = messageWrapper['Signature'];
        }

        // if this is an invite, get the contact handle
        if (this.isInvite) {
          if (message['d'].toString().length == 56) {
            this._inviteTarget = message['d'];
            var targetContact = Provider.of<ProfileInfoState>(context).contactList.getContact(this._inviteTarget);
            this._inviteNick = targetContact == null ? message['d'] : targetContact.nickname;
          } else {
            var parts = message['d'].toString().split("||");
            if (parts.length == 2) {
              var jsonObj = jsonDecode(utf8.fuse(base64).decode(parts[1].substring(5)));
              this._inviteTarget = jsonObj['GroupID'];
              this._inviteNick = jsonObj['GroupName'];
            }
          }
        }

        this.loaded = true;

        //update ackd and error last as they are changenotified
        this.ackd = messageWrapper['Acknowledged'];
        if (messageWrapper['Error'] != null) {
          this.error = true;
        }
      } catch (e) {
        this._overlay = -1;
        this.loaded = true;
        this.malformed = true;
      }
    });
  }
}

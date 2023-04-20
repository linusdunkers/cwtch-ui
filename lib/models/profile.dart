import 'dart:convert';

import 'package:cwtch/config.dart';
import 'package:cwtch/models/remoteserver.dart';
import 'package:flutter/widgets.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../themes/opaque.dart';
import '../views/contactsview.dart';
import 'contact.dart';
import 'contactlist.dart';
import 'filedownloadprogress.dart';
import 'messagecache.dart';
import 'profileservers.dart';

class ProfileInfoState extends ChangeNotifier {
  ProfileServerListState _servers = ProfileServerListState();
  ContactListState _contacts = ContactListState();
  final String onion;
  String _nickname = "";
  String _imagePath = "";
  String _defaultImagePath = "";
  int _unreadMessages = 0;
  bool _online = false;
  Map<String, FileDownloadProgress> _downloads = Map<String, FileDownloadProgress>();
  Map<String, int> _downloadTriggers = Map<String, int>();
  ItemScrollController contactListScrollController = new ItemScrollController();
  // assume profiles are encrypted...this will be set to false
  // in the constructor if the profile is encrypted with the defacto password.
  bool _encrypted = true;

  bool _autostart = true;
  bool _enabled = false;

  ProfileInfoState({
    required this.onion,
    nickname = "",
    imagePath = "",
    defaultImagePath = "",
    unreadMessages = 0,
    contactsJson = "",
    serversJson = "",
    online = false,
    autostart = true,
    encrypted = true,
    String,
  }) {
    this._nickname = nickname;
    this._imagePath = imagePath;
    this._defaultImagePath = defaultImagePath;
    this._unreadMessages = unreadMessages;
    this._online = online;
    this._enabled = _enabled;
    this._autostart = autostart;
    if (autostart) {
      this._enabled = true;
    }
    this._encrypted = encrypted;

    _contacts.connectServers(this._servers);

    if (contactsJson != null && contactsJson != "" && contactsJson != "null") {
      this.replaceServers(serversJson);

      List<dynamic> contacts = jsonDecode(contactsJson);
      this._contacts.addAll(contacts.map((contact) {
        this._unreadMessages += contact["numUnread"] as int;
        return ContactInfoState(this.onion, contact["identifier"], contact["onion"],
            nickname: contact["name"],
            localNickname: contact["localname"],
            status: contact["status"],
            imagePath: contact["picture"],
            defaultImagePath: contact["isGroup"] ? contact["picture"] : contact["defaultPicture"],
            accepted: contact["accepted"],
            blocked: contact["blocked"],
            savePeerHistory: contact["saveConversationHistory"],
            numMessages: contact["numMessages"],
            numUnread: contact["numUnread"],
            isGroup: contact["isGroup"],
            server: contact["groupServer"],
            archived: contact["isArchived"] == true,
            lastMessageTime: DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"])),
            pinned: contact["attributes"]?["local.profile.pinned"] == "true",
            notificationPolicy: contact["notificationPolicy"] ?? "ConversationNotificationPolicy.Default");
      }));

      // dummy set to invoke sort-on-load
      if (this._contacts.num > 0) {
        this._contacts.updateLastMessageTime(this._contacts.contacts.first.identifier, this._contacts.contacts.first.lastMessageTime);
      }
    }
  }

  // Parse out the server list json into our server info state struct...
  void replaceServers(String serversJson) {
    if (serversJson != "" && serversJson != "null") {
      List<dynamic> servers = jsonDecode(serversJson);
      this._servers.replace(servers.map((server) {
        // TODO Keys...
        var preSyncStartTime = DateTime.tryParse(server["syncProgress"]["startTime"]);
        var lastMessageTime = DateTime.tryParse(server["syncProgress"]["lastMessageTime"]);
        return RemoteServerInfoState(server["onion"], server["identifier"], server["description"], server["status"], lastPreSyncMessageTime: preSyncStartTime, mostRecentMessageTime: lastMessageTime);
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
  set isEncrypted(bool newValue) {
    this._encrypted = newValue;
    notifyListeners();
  }

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

  bool get enabled => this._enabled;

  set enabled(bool newVal) {
    this._enabled = newVal;
    notifyListeners();
  }

  bool get autostart => this._autostart;

  set autostart(bool newVal) {
    this._autostart = newVal;
    notifyListeners();
  }

  String get defaultImagePath => this._defaultImagePath;

  set defaultImagePath(String newVal) {
    this._defaultImagePath = newVal;
    notifyListeners();
  }

  int get unreadMessages => this._unreadMessages;

  set unreadMessages(int newVal) {
    this._unreadMessages = newVal;
    notifyListeners();
  }

  void recountUnread() {
    this._unreadMessages = _contacts.contacts.fold(0, (i, c) => i + c.unreadMessages);
  }

  // Remove a contact from a list. Currently only used when rejecting a group invitation.
  // Eventually will also be used for other removals.
  void removeContact(String handle) {
    this.contactList.removeContactByHandle(handle);
    notifyListeners();
  }

  ContactListState get contactList => this._contacts;

  ProfileServerListState get serverList => this._servers;

  @override
  void dispose() {
    super.dispose();
  }

  void updateFrom(String onion, String name, String picture, String contactsJson, String serverJson, bool online) {
    this._nickname = name;
    this._imagePath = picture;
    this._online = online;
    this._unreadMessages = 0;
    this.replaceServers(serverJson);

    if (contactsJson != null && contactsJson != "" && contactsJson != "null") {
      List<dynamic> contacts = jsonDecode(contactsJson);
      contacts.forEach((contact) {
        var profileContact = this._contacts.getContact(contact["identifier"]);
        this._unreadMessages += contact["numUnread"] as int;
        if (profileContact != null) {
          profileContact.status = contact["status"];

          var newCount = contact["numMessages"];
          if (newCount != profileContact.totalMessages) {
            profileContact.messageCache.addFrontIndexGap(newCount - profileContact.totalMessages);
          }
          profileContact.totalMessages = newCount;
          profileContact.unreadMessages = contact["numUnread"];
          profileContact.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"]));
        } else {
          this._contacts.add(ContactInfoState(
                this.onion,
                contact["identifier"],
                contact["onion"],
                nickname: contact["name"],
                defaultImagePath: contact["defaultPicture"],
                status: contact["status"],
                imagePath: contact["picture"],
                accepted: contact["accepted"],
                blocked: contact["blocked"],
                savePeerHistory: contact["saveConversationHistory"],
                numMessages: contact["numMessages"],
                numUnread: contact["numUnread"],
                isGroup: contact["isGroup"],
                server: contact["groupServer"],
                lastMessageTime: DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"])),
                notificationPolicy: contact["notificationPolicy"] ?? "ConversationNotificationPolicy.Default",
              ));
        }
      });
    }
    this._contacts.resort();
  }

  void newMessage(
      int identifier, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data, String contenthash, bool selectedProfile, bool selectedConversation) {
    if (!selectedProfile) {
      unreadMessages++;
      notifyListeners();
    }

    contactList.newMessage(identifier, messageID, timestamp, senderHandle, senderImage, isAuto, data, contenthash, selectedConversation);
  }

  void downloadInit(String fileKey, int numChunks) {
    this._downloads[fileKey] = FileDownloadProgress(numChunks, DateTime.now());
    notifyListeners();
  }

  void downloadUpdate(String fileKey, int progress, int numChunks) {
    if (!downloadActive(fileKey)) {
      this._downloads[fileKey] = FileDownloadProgress(numChunks, DateTime.now());
      if (progress < 0) {
        this._downloads[fileKey]!.interrupted = true;
      }
    } else {
      if (this._downloads[fileKey]!.interrupted) {
        this._downloads[fileKey]!.interrupted = false;
      }
      this._downloads[fileKey]!.chunksDownloaded = progress;
      this._downloads[fileKey]!.chunksTotal = numChunks;
      this._downloads[fileKey]!.markUpdate();
    }
    notifyListeners();
  }

  void downloadMarkManifest(String fileKey) {
    if (!downloadActive(fileKey)) {
      this._downloads[fileKey] = FileDownloadProgress(1, DateTime.now());
    }
    this._downloads[fileKey]!.gotManifest = true;
    this._downloads[fileKey]!.markUpdate();
    notifyListeners();
  }

  void downloadMarkFinished(String fileKey, String finalPath) {
    if (!downloadActive(fileKey)) {
      // happens as a result of a CheckDownloadStatus call,
      // invoked from a historical (timeline) download message
      // so setting numChunks correctly shouldn't matter
      this.downloadInit(fileKey, 1);
    }

    // Update the contact with a custom profile image if we are
    // waiting for one...
    if (this._downloadTriggers.containsKey(fileKey)) {
      int identifier = this._downloadTriggers[fileKey]!;
      this.contactList.getContact(identifier)!.imagePath = finalPath;
      notifyListeners();
    }

    // only update if different
    if (!this._downloads[fileKey]!.complete) {
      this._downloads[fileKey]!.timeEnd = DateTime.now();
      this._downloads[fileKey]!.downloadedTo = finalPath;
      this._downloads[fileKey]!.complete = true;
      this._downloads[fileKey]!.markUpdate();
      notifyListeners();
    }
  }

  bool downloadKnown(String fileKey) {
    return this._downloads.containsKey(fileKey);
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
    if (this._downloads.containsKey(fileKey)) {
      if (this._downloads[fileKey]!.interrupted) {
        return true;
      }

      if (this._downloads[fileKey]!.requested != null) {
        if (DateTime.now().difference(this._downloads[fileKey]!.requested!) > Duration(minutes: 1)) {
          this._downloads[fileKey]!.requested = null;
          this._downloads[fileKey]!.interrupted = true;
          return true;
        }
        if (DateTime.now().difference(this._downloads[fileKey]!.lastUpdate) > Duration(minutes: 1)) {
          this._downloads[fileKey]!.requested = null;
          this._downloads[fileKey]!.interrupted = true;
          return true;
        }
      }
    }
    return false;
  }

  void downloadMarkResumed(String fileKey) {
    if (this._downloads.containsKey(fileKey)) {
      this._downloads[fileKey]!.interrupted = false;
      this._downloads[fileKey]!.requested = DateTime.now();
      this._downloads[fileKey]!.markUpdate();
      notifyListeners();
    }
  }

  double downloadProgress(String fileKey) {
    return this._downloads.containsKey(fileKey) ? this._downloads[fileKey]!.progress() : 0.0;
  }

  // used for loading interrupted download info; use downloadMarkFinished for successful downloads
  void downloadSetPath(String fileKey, String path) {
    if (this._downloads.containsKey(fileKey)) {
      this._downloads[fileKey]!.downloadedTo = path;
      notifyListeners();
    }
  }

  // set the download path for the sender
  void downloadSetPathForSender(String fileKey, String path) {
    // we may trigger this event for auto-downloaded receivers too,
    // as such we don't assume anything else about the file...other than that
    // it exists.
    if (!this._downloads.containsKey(fileKey)) {
      // this will be overwritten by download update if the file is being downloaded
      this._downloads[fileKey] = FileDownloadProgress(1, DateTime.now());
    }
    this._downloads[fileKey]!.downloadedTo = path;
    notifyListeners();
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

  void waitForDownloadComplete(int identifier, String fileKey) {
    _downloadTriggers[fileKey] = identifier;
    notifyListeners();
  }

  int cacheMemUsage() {
    return _contacts.cacheMemUsage();
  }

  void downloadReset(String fileKey) {
    this._downloads.remove(fileKey);
    notifyListeners();
  }

  // Profile Attributes. Can be set in Profile Edit View...
  List<String?> attributes = [null, null, null];
  void setAttribute(int i, String? value) {
    this.attributes[i] = value;
    notifyListeners();
  }

  ProfileStatusMenu availabilityStatus = ProfileStatusMenu.available;
  void setAvailabilityStatus(String status) {
    switch (status) {
      case "available":
        availabilityStatus = ProfileStatusMenu.available;
        break;
      case "busy":
        availabilityStatus = ProfileStatusMenu.busy;
        break;
      case "away":
        availabilityStatus = ProfileStatusMenu.away;
        break;
      default:
        ProfileStatusMenu.available;
    }
    notifyListeners();
  }

  Color getBorderColor(OpaqueThemeType theme) {
    switch (this.availabilityStatus) {
      case ProfileStatusMenu.available:
        return theme.portraitOnlineBorderColor;
      case ProfileStatusMenu.away:
        return theme.portraitOnlineAwayColor;
      case ProfileStatusMenu.busy:
        return theme.portraitOnlineBusyColor;
    }
  }
}

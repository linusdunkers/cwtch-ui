import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'contact.dart';
import 'contactlist.dart';
import 'filedownloadprogress.dart';
import 'profileservers.dart';

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
            accepted: contact["accepted"],
            blocked: contact["blocked"],
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
    this.contactList.removeContactByHandle(handle);
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
        var profileContact = this._contacts.getContact(contact["identifier"]);
        if (profileContact != null) {
          profileContact.status = contact["status"];
          profileContact.totalMessages = contact["numMessages"];
          profileContact.unreadMessages = contact["numUnread"];
          profileContact.lastMessageTime = DateTime.fromMillisecondsSinceEpoch(1000 * int.parse(contact["lastMsgTime"]));
        } else {
          this._contacts.add(ContactInfoState(
                this.onion,
                contact["identifier"],
                contact["onion"],
                nickname: contact["name"],
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
              ));
        }
      });
    }
    this._contacts.resort();
  }

  void downloadInit(String fileKey, int numChunks) {
    this._downloads[fileKey] = FileDownloadProgress(numChunks, DateTime.now());
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
    }
    notifyListeners();
  }

  void downloadMarkManifest(String fileKey) {
    if (!downloadActive(fileKey)) {
      this._downloads[fileKey] = FileDownloadProgress(1, DateTime.now());
    }
    this._downloads[fileKey]!.gotManifest = true;
    notifyListeners();
  }

  void downloadMarkFinished(String fileKey, String finalPath) {
    if (!downloadActive(fileKey)) {
      // happens as a result of a CheckDownloadStatus call,
      // invoked from a historical (timeline) download message
      // so setting numChunks correctly shouldn't matter
      this.downloadInit(fileKey, 1);
    }
    // only update if different
    if (!this._downloads[fileKey]!.complete) {
      this._downloads[fileKey]!.timeEnd = DateTime.now();
      this._downloads[fileKey]!.downloadedTo = finalPath;
      this._downloads[fileKey]!.complete = true;
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

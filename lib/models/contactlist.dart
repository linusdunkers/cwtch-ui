import 'package:flutter/widgets.dart';

import 'contact.dart';
import 'profileservers.dart';

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
    resort();
    notifyListeners();
  }

  void add(ContactInfoState newContact) {
    _contacts.add(newContact);
    if (newContact.isGroup) {
      servers?.addGroup(newContact);
    }
    resort();
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

      // unapproved top
      if (a.isInvitation && !b.isInvitation) return -1;
      if (!a.isInvitation && b.isInvitation) return 1;

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

  void removeContactByHandle(String handle) {
    int idx = _contacts.indexWhere((element) => element.onion == handle);
    _contacts.removeAt(idx);
    notifyListeners();
  }

  ContactInfoState? findContact(String byHandle) {
    int idx = _contacts.indexWhere((element) => element.onion == byHandle);
    return idx >= 0 ? _contacts[idx] : null;
  }

  void newMessage(int identifier, int messageID, DateTime timestamp, String senderHandle, String senderImage, bool isAuto, String data, String contenthash, bool selectedConversation) {
    getContact(identifier)?.newMessage(identifier, messageID, timestamp, senderHandle, senderImage, isAuto, data, contenthash, selectedConversation);
    updateLastMessageTime(identifier, DateTime.now());
  }
}

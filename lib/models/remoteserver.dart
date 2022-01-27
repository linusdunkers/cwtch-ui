import 'package:flutter/cupertino.dart';

import 'contact.dart';

class RemoteServerInfoState extends ChangeNotifier {
  final String onion;
  final int identifier;
  String _status;
  String description;
  List<ContactInfoState> _groups = [];

  double syncProgress = 0;
  DateTime lastPreSyncMessagTime = new DateTime(2020);

  RemoteServerInfoState(this.onion, this.identifier, this.description, this._status);

  void updateDescription(String newDescription) {
    this.description = newDescription;
    notifyListeners();
  }

  void clearGroups() {
    _groups = [];
  }

  void addGroup(ContactInfoState group) {
    _groups.add(group);
    notifyListeners();
  }

  String get status => _status;
  set status(String newStatus) {
    _status = newStatus;
    if (status == "Authenticated") {
      // syncing, set lastPreSyncMessageTime
      _groups.forEach((g) {
        if(g.lastMessageTime.isAfter(lastPreSyncMessagTime)) {
          lastPreSyncMessagTime = g.lastMessageTime;
        }
      });
    }
    notifyListeners();
  }

  void updateSyncProgressFor(DateTime point) {
    var range = lastPreSyncMessagTime.difference(DateTime.now());
    var pointFromStart = lastPreSyncMessagTime.difference(point);
    syncProgress = pointFromStart.inSeconds / range.inSeconds * 100;
    groups.forEach((g) { g.serverSyncProgress = syncProgress;});
    notifyListeners();
  }

  List<ContactInfoState> get groups => _groups.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier
}
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

  RemoteServerInfoState(this.onion, this.identifier, this.description, this._status, {lastPreSyncMessageTime, mostRecentMessageTime}) {
    if (_status == "Authenticated") {
      this.lastPreSyncMessagTime = lastPreSyncMessageTime;
      updateSyncProgressFor(mostRecentMessageTime);
    }
  }

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
        if (g.lastMessageTime.isAfter(lastPreSyncMessagTime)) {
          lastPreSyncMessagTime = g.lastMessageTime;
        }
      });
    }
    notifyListeners();
  }

  // updateSyncProgressFor point takes a message's time, and updates the server sync progress,
  // based on that point in time between the precalculated lastPreSyncMessagTime and Now
  void updateSyncProgressFor(DateTime point) {
    var range = lastPreSyncMessagTime.toUtc().difference(DateTime.now().toUtc());
    var pointFromStart = lastPreSyncMessagTime.toUtc().difference(point.toUtc());
    if (!pointFromStart.isNegative) { // ! is Negative cus all the duration's we're calculating incidently are negative
      // this message is from before we think we should be syncing with the server
      // Can be because of a new server or a full resync, either way, use this (oldest message) as our lastPreSyncMessageTime
      this.lastPreSyncMessagTime = point;
      pointFromStart = lastPreSyncMessagTime.toUtc().difference(point.toUtc());
    }
    syncProgress = pointFromStart.inSeconds / range.inSeconds;
    notifyListeners();
  }

  List<ContactInfoState> get groups => _groups.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier
}

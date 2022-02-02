import 'package:cwtch/models/remoteserver.dart';
import 'package:flutter/material.dart';

import 'contact.dart';

class ProfileServerListState extends ChangeNotifier {
  List<RemoteServerInfoState> _servers = [];

  void replace(Iterable<RemoteServerInfoState> newServers) {
    _servers.clear();
    _servers.addAll(newServers);
    resort();
    notifyListeners();
  }

  RemoteServerInfoState? getServer(String onion) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _servers[idx] : null;
  }

  void updateServerState(String onion, String status) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    if (idx >= 0) {
      _servers[idx].status = status;
    } else {
      print("Tried to update server cache without a starting state...this is probably an error");
    }
    resort();
    notifyListeners();
  }

  void resort() {
    _servers.sort((RemoteServerInfoState a, RemoteServerInfoState b) {
      // return -1 = a first in list
      // return 1 = b first in list

      // online v syncing v offline
      if (a.status == "Synced" && b.status != "Synced") {
        return -1;
      } else if (a.status != "Synced" && b.status == "Synced") {
        return 1;
      }
      if (a.status == "Authenticated" && b.status != "Authenticated") {
        return -1;
      } else if (a.status != "Authenticated" && b.status == "Authenticated") {
        return 1;
      }

      // num of groups
      if (a.groups.length > b.groups.length) {
        return -1;
      } else if (b.groups.length > a.groups.length) {
        return 1;
      }

      return 0;
    });
  }

  void clearGroups() {
    _servers.map((server) => server.clearGroups());
  }

  void addGroup(ContactInfoState group) {
    int idx = _servers.indexWhere((element) => element.onion == group.server);
    if (idx >= 0) {
      _servers[idx].addGroup(group);
    }
  }

  List<RemoteServerInfoState> get servers => _servers.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

}

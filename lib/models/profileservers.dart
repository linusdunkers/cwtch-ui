import 'package:cwtch/model.dart';
import 'package:flutter/material.dart';

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
      _servers[idx] = RemoteServerInfoState(onion: onion, description:  _servers[idx].description, status: status);
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
      if (a.status == "Synced" && b.status != "Synced") {
        return -1;
      } else  if (a.status != "Synced" && b.status == "Synced") {
        return 1;
      }
      return 0;
    });
  }

  void clearGroups() {
    _servers.map((server) => server.clearGroups());
  }

  void addGroup(ContactInfoState group) {
    print("serverList adding group ${group.onion} to ${group.server}");

    int idx = _servers.indexWhere((element) => element.onion == group.server);
    if (idx >= 0) {
      _servers[idx].addGroup(group);
    }
  }

  List<RemoteServerInfoState> get servers => _servers.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

}

class RemoteServerInfoState extends ChangeNotifier {
  final String onion;
  final String status;
  String description;
  List<ContactInfoState> _groups = [];

  RemoteServerInfoState({required this.onion, required this.description, required this.status});
  
  void updateDescription(String newDescription) {
    this.description = newDescription;
    notifyListeners();
  }

  void clearGroups() {
    print("Server CLEARING group");
    description = "cleared groups";
    _groups = [];
  }

  void addGroup(ContactInfoState group) {
    print("server $onion adding group ${group.onion}");
    _groups.add(group);
    print("now has ${_groups.length}");
    description = "i have ${_groups.length} groups";
    notifyListeners();
  }

  int get groupsLen => _groups.length;

  List<ContactInfoState> get groups => _groups.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

}

import 'package:flutter/material.dart';

class ProfileServerListState extends ChangeNotifier {
  List<RemoteServerInfoState> _servers = [];

  void replace(Iterable<RemoteServerInfoState> newServers) {
    _servers.clear();
    _servers.addAll(newServers);
    notifyListeners();
  }

  RemoteServerInfoState? getServer(String onion) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _servers[idx] : null;
  }

  void updateServerCache(String onion, String description, String status) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    if (idx >= 0) {
      _servers[idx] = RemoteServerInfoState(onion: onion, description: description, status: status);
    } else {
      print("Tried to update server cache without a starting state...this is probably an error");
    }
    notifyListeners();
  }

  List<RemoteServerInfoState> get servers => _servers.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

}

class RemoteServerInfoState extends ChangeNotifier {
  final String onion;
  final String status;
  final String description;

  RemoteServerInfoState({required this.onion, required this.description, required this.status});
}

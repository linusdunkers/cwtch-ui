import 'package:flutter/material.dart';

class ServerListState extends ChangeNotifier {
  List<ServerInfoState> _servers = [];

  void replace(Iterable<ServerInfoState> newServers) {
    _servers.clear();
    _servers.addAll(newServers);
    notifyListeners();
  }

  ServerInfoState? getServer(String onion) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _servers[idx] : null;
  }

  void updateServerCache(String onion, String status) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    if (idx >= 0) {
      _servers[idx] = ServerInfoState(onion: onion, status: status);
    } else {
      print("Tried to update server cache without a starting state...this is probably an error");
    }
    notifyListeners();
  }

  List<ServerInfoState> get servers => _servers.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

}

class ServerInfoState extends ChangeNotifier {
  final String onion;
  final String status;

  ServerInfoState({required this.onion, required this.status});
}

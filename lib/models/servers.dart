import 'package:flutter/material.dart';

class ServerListState extends ChangeNotifier {
  List<ServerInfoState> _servers = [];

  void replace(Iterable<ServerInfoState> newServers) {
    _servers.clear();
    _servers.addAll(newServers);
    notifyListeners();
  }

  void clear() {
    _servers.clear();
  }

  ServerInfoState? getServer(String onion) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _servers[idx] : null;
  }

  void add(String onion, String serverBundle, bool running, String description, bool autoStart, bool isEncrypted) {
    var sis = ServerInfoState(onion: onion, serverBundle: serverBundle, running: running, description: description, autoStart: autoStart, isEncrypted: isEncrypted);
    int idx = _servers.indexWhere((element) => element.onion == onion);
    if (idx >= 0) {
      _servers[idx] = sis;
    } else {
      _servers.add(ServerInfoState(onion: onion, serverBundle: serverBundle, running: running, description: description, autoStart: autoStart, isEncrypted: isEncrypted));
    }
    notifyListeners();
  }

  void updateServer(String onion, String serverBundle, bool running, String description, bool autoStart, bool isEncrypted) {
    int idx = _servers.indexWhere((element) => element.onion == onion);
    if (idx >= 0) {
      _servers[idx] = ServerInfoState(onion: onion, serverBundle: serverBundle, running: running, description: description, autoStart: autoStart, isEncrypted: isEncrypted);
    } else {
      print("Tried to update server list without a starting state...this is probably an error");
    }
    notifyListeners();
  }

  void updateServerStats(String onion, int newTotalMessages, int newConnections) {
    var server = getServer(onion);
    if (server != null) {
      server.setStats(newTotalMessages, newConnections);
      resort();
      notifyListeners();
    }
  }

  void delete(String onion) {
    _servers.removeWhere((element) => element.onion == onion);
    notifyListeners();
  }

  void resort() {
    _servers.sort((ServerInfoState a, ServerInfoState b) {
      // return -1 = a first in list
      // return 1 = b first in list
      if (a.totalMessages > b.totalMessages) {
        return -1;
      } else if (b.totalMessages > a.totalMessages) {
        return 1;
      }

      return 0;
    });
  }

  List<ServerInfoState> get servers => _servers.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

}

class ServerInfoState extends ChangeNotifier {
  String onion;
  String serverBundle;
  String description;
  bool running;
  bool autoStart;
  bool isEncrypted;
  int totalMessages = 0;
  int connections = 0;

  ServerInfoState({required this.onion, required this.serverBundle, required this.running, required this.description, required this.autoStart, required this.isEncrypted});

  void setAutostart(bool val) {
    autoStart = val;
    notifyListeners();
  }

  void setRunning(bool val) {
    running = val;
    notifyListeners();
  }

  void setDescription(String val) {
    description = val;
    notifyListeners();
  }

  void setStats(int newTotalMessages, int newConnections) {
    totalMessages = newTotalMessages;
    connections = newConnections;
    notifyListeners();
  }
}

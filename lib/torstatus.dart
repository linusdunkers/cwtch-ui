import 'package:flutter/material.dart';

class TorStatus extends ChangeNotifier {
  int progress;
  String status;
  bool connected;
  String version;

  TorStatus({this.connected = false, this.progress = 0, this.status = "", this.version = ""});

  /// Called by the event bus.
  handleUpdate(int new_progress, String new_status) {
    if (progress == 100) {
      connected = true;
    } else {
      connected = false;
    }

    progress = new_progress;
    status = new_status;
    if (new_progress != 100) {
      status = "$new_progress% - $new_status";
    }

    notifyListeners();
  }

  updateVersion(String new_version) {
    version = new_version;
    notifyListeners();
  }
}

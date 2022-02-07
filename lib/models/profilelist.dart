import 'package:flutter/widgets.dart';

import 'profile.dart';

class ProfileListState extends ChangeNotifier {
  List<ProfileInfoState> _profiles = [];
  int get num => _profiles.length;

  void add(String onion, String name, String picture, String defaultPicture, String contactsJson, String serverJson, bool online, bool encrypted) {
    var idx = _profiles.indexWhere((element) => element.onion == onion);
    if (idx == -1) {
      _profiles.add(ProfileInfoState(
          onion: onion, nickname: name, imagePath: picture, defaultImagePath: defaultPicture, contactsJson: contactsJson, serversJson: serverJson, online: online, encrypted: encrypted));
    } else {
      _profiles[idx].updateFrom(onion, name, picture, contactsJson, serverJson, online);
    }
    notifyListeners();
  }

  List<ProfileInfoState> get profiles => _profiles.sublist(0); //todo: copy?? dont want caller able to bypass changenotifier

  ProfileInfoState? getProfile(String onion) {
    int idx = _profiles.indexWhere((element) => element.onion == onion);
    return idx >= 0 ? _profiles[idx] : null;
  }

  void delete(String onion) {
    _profiles.removeWhere((element) => element.onion == onion);
    notifyListeners();
  }

  int generateUnreadCount(String selectedProfile) => _profiles.where((p) => p.onion != selectedProfile).fold(0, (i, p) => i + p.unreadMessages);
}

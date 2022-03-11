import 'dart:async';

import 'package:flutter/widgets.dart';

enum ModalState { none, storageMigration, shutdown }

class AppState extends ChangeNotifier {
  bool cwtchInit = false;
  ModalState modalState = ModalState.none;
  bool cwtchIsClosing = false;
  String appError = "";
  String? _selectedProfile;
  int? _selectedConversation;
  int _initialScrollIndex = 0;
  int _hoveredIndex = -1;
  int? _selectedIndex;
  bool _unreadMessagesBelow = false;
  bool _disableFilePicker = false;
  bool _focus = true;

  StreamController<bool> _profilesUnreadNotifyControler = StreamController<bool>();
  late Stream<bool> profilesUnreadNotify;

  AppState() {
    profilesUnreadNotify = _profilesUnreadNotifyControler.stream.asBroadcastStream();
  }

  void SetCwtchInit() {
    cwtchInit = true;
    notifyListeners();
  }

  void SetAppError(String error) {
    appError = error;
    notifyListeners();
  }

  void SetModalState(ModalState newState) {
    modalState = newState;
    notifyListeners();
  }

  String? get selectedProfile => _selectedProfile;
  set selectedProfile(String? newVal) {
    this._selectedProfile = newVal;
    notifyListeners();
  }

  int? get selectedConversation => _selectedConversation;
  set selectedConversation(int? newVal) {
    this._selectedConversation = newVal;
    notifyListeners();
  }

  int? get selectedIndex => _selectedIndex;
  set selectedIndex(int? newVal) {
    this._selectedIndex = newVal;
    notifyListeners();
  }

  bool get disableFilePicker => _disableFilePicker;
  set disableFilePicker(bool newVal) {
    this._disableFilePicker = newVal;
    notifyListeners();
  }

  // Never use this for message lookup - can be a non-indexed value
  // e.g. -1
  int get hoveredIndex => _hoveredIndex;
  set hoveredIndex(int newVal) {
    this._hoveredIndex = newVal;
    notifyListeners();
  }

  bool get unreadMessagesBelow => _unreadMessagesBelow;
  set unreadMessagesBelow(bool newVal) {
    this._unreadMessagesBelow = newVal;
    notifyListeners();
  }

  int get initialScrollIndex => _initialScrollIndex;
  set initialScrollIndex(int newVal) {
    this._initialScrollIndex = newVal;
    notifyListeners();
  }

  bool get focus => _focus;
  set focus(bool newVal) {
    _focus = newVal;
    notifyListeners();
  }

  bool isLandscape(BuildContext c) => MediaQuery.of(c).size.width > MediaQuery.of(c).size.height;

  void notifyProfileUnread() {
    _profilesUnreadNotifyControler.add(true);
  }

  Stream<bool> getUnreadProfileNotifyStream() {
    return profilesUnreadNotify;
  }
}

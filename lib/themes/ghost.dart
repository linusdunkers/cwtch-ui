import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const ghost_theme = "ghost";

OpaqueThemeType GetGhostTheme(String mode) {
  if (mode == mode_dark) {
    return GhostDark();
  } else {
    return GhostLight();
  }
}

class GhostDark extends CwtchDark {
  static final Color background = Color(0xFF0D0D1F);
  static final Color header = Color(0xFF0D0D1F);
  static final Color userBubble = Color(0xFF1A237E);
  static final Color peerBubble = Color(0xFF000051);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFDFFFD);
  static final Color accent = Color(0xFFD20070);

  get theme => ghost_theme;
  get mode => mode_dark;

  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get mainTextColor => font; //whiteishPurple;
  get defaultButtonColor => accent; //hotPink;
  get textfieldHintColor => mainTextColor; //TODO pick
  get toolbarIconColor => settings; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
}

class GhostLight extends CwtchLight {
  static final Color background = Color(0xFFFDFDFF);
  static final Color header = Color(0xFFAAB6FE);
  static final Color userBubble = Color(0xFFAAB6FE);
  static final Color peerBubble = Color(0xFFE8EAF6);
  static final Color font = Color(0xFF0D0D1F);
  static final Color settings = Color(0xFF0D0D1F);
  static final Color accent = Color(0xFFD20070);

  get theme => ghost_theme;
  get mode => mode_light;

  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => header; //softPurple;
  get mainTextColor => settings;
  get defaultButtonColor => accent; // hotPink;
  get textfieldHintColor => font; //TODO pick
  get scrollbarDefaultColor => accent;
  get portraitContactBadgeColor => accent;
  get toolbarIconColor => settings; //darkPurple;
  get messageFromMeBackgroundColor => userBubble; //brightPurple;
  get messageFromMeTextColor => font; //mainTextColor;
  get messageFromOtherBackgroundColor => peerBubble; //purple;
  get messageFromOtherTextColor => font; //darkPurple;
}

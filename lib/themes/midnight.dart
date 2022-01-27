import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const midnight_theme = "midnight";

OpaqueThemeType GetMidnightTheme(String mode) {
  if (mode == mode_dark) {
    return MidnightDark();
  } else {
    return MidnightLight();
  }
}

class MidnightDark extends CwtchDark {
  static final Color background = Color(0xFF1B1B1B);
  static final Color header = Color(0xFF1B1B1B);
  static final Color userBubble = Color(0xFF373737);
  static final Color peerBubble = Color(0xFF494949);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFFFDFF);
  static final Color accent = Color(0xFFD20070);

  get theme => midnight_theme;
  get mode => mode_dark;

  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get topbarColor => header; //darkGreyPurple;
  get mainTextColor => font; //whiteishPurple;
  get defaultButtonColor => accent; //hotPink;
  get textfieldHintColor => mainTextColor; //TODO pick
  get toolbarIconColor => settings; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
}

class MidnightLight extends CwtchLight {
  static final Color background = Color(0xFFFFFDFF);
  static final Color header = Color(0xFFE0E0E0);
  static final Color userBubble = Color(0xFFE0E0E0);
  static final Color peerBubble = Color(0xFFBABDBE);
  static final Color font = Color(0xFF1B1B1B);
  static final Color settings = Color(0xFF1B1B1B);
  static final Color accent = Color(0xFFD20070);

  get theme => midnight_theme;
  get mode => mode_light;

  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => background; //whitePurple;
  get topbarColor => header; //softPurple;
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
  get textfieldBackgroundColor => userBubble;
}

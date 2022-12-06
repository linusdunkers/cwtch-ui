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
  static final Color accentGray = Color(0xFFE0E0E0);
  static final Color background = Color(0xFF1B1B1B);
  static final Color backgroundAlt = Color(0xFF494949);
  static final Color header = Color(0xFF1B1B1B);
  static final Color userBubble = Color(0xFF373737);
  static final Color peerBubble = Color(0xFF494949);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFFFDFF);
  static final Color accent = Color(0xFFD20070);

  get theme => midnight_theme;
  get mode => mode_dark;

  get backgroundHilightElementColor => backgroundAlt;
  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get defaultButtonColor => accent; //hotPink;
  get dropShadowColor => accentGray;
  get mainTextColor => font; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
  get scrollbarDefaultColor => accentGray;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => mainTextColor;
  get toolbarIconColor => settings; //whiteishPurple;
  get topbarColor => header; //darkGreyPurple;
}

class MidnightLight extends CwtchLight {
  static final Color background = Color(0xFFFBFBFB);//Color(0xFFFFFDFF);
  static final Color header = Color(0xFFE0E0E0);
  static final Color userBubble = Color(0xFFE0E0E0);
  static final Color peerBubble = Color(0xFFBABDBE);
  static final Color font = Color(0xFF1B1B1B);
  static final Color settings = Color(0xFF1B1B1B);
  static final Color accent = Color(0xFFD20070);

  get theme => midnight_theme;
  get mode => mode_light;

  get backgroundHilightElementColor => peerBubble;
  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => background; //whitePurple;
  get defaultButtonColor => accent; // hotPink;
  get mainTextColor => settings;
  get messageFromMeBackgroundColor => userBubble; //brightPurple;
  get messageFromMeTextColor => font; //mainTextColor;
  get messageFromOtherBackgroundColor => peerBubble; //purple;
  get messageFromOtherTextColor => font; //darkPurple;
  get portraitContactBadgeColor => accent;
  get portraitOfflineBorderColor => peerBubble;
  get portraitOnlineBorderColor => font;
  get scrollbarDefaultColor => accent;
  get textfieldBackgroundColor => userBubble;
  get textfieldHintColor => font;
  get toolbarIconColor => settings; //darkPurple;
  get topbarColor => header; //softPurple;
}

import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const witch_theme = "witch";

OpaqueThemeType GetWitchTheme(String mode) {
  if (mode == mode_dark) {
    return WitchDark();
  } else {
    return WitchLight();
  }
}

class WitchDark extends CwtchDark {
  static final Color background = Color(0xFF0E1E0E);
  static final Color header = Color(0xFF0E1E0E);
  static final Color userBubble = Color(0xFF1B5E20);
  static final Color peerBubble = Color(0xFF003300);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFDFFFD);
  static final Color accent = Color(0xFFD20070);

  get theme => witch_theme;
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
}

class WitchLight extends CwtchLight {
  static final Color background = Color(0xFFFDFFFD);
  static final Color header = Color(0xFF80E27E);
  static final Color userBubble = Color(0xFF80E27E);
  static final Color peerBubble = Color(0xFFE8F5E9);
  static final Color font = Color(0xFF0E1E0E);
  static final Color settings = Color(0xFF0E1E0E);
  static final Color accent = Color(0xFFD20070);

  get theme => witch_theme;
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
}

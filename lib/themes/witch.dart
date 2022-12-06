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

  get backgroundHilightElementColor => peerBubble;
  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get defaultButtonColor => accent; //hotPink;
  get mainTextColor => font; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
  get scrollbarDefaultColor => accent;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => mainTextColor;
  get toolbarIconColor => settings; //whiteishPurple;
  get topbarColor => header; //darkGreyPurple;
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
  get scrollbarDefaultColor => accent;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => font;
  get toolbarIconColor => settings; //darkPurple;
  get topbarColor => header; //softPurple;
}

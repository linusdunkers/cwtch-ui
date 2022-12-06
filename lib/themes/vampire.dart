import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const vampire_theme = "vampire";

OpaqueThemeType GetVampireTheme(String mode) {
  if (mode == mode_dark) {
    return VampireDark();
  } else {
    return VampireLight();
  }
}

class VampireDark extends CwtchDark {
  static final Color background = Color(0xFF281831);
  static final Color header = Color(0xFF281831);
  static final Color userBubble = Color(0xFF9A1218);
  static final Color peerBubble = Color(0xFF422850);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFDFFFD);
  static final Color accent = Color(0xFF8E64A5);

  get theme => vampire_theme;
  get mode => mode_dark;

  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get defaultButtonColor => accent; //hotPink;
  get mainTextColor => font; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
  get scrollbarDefaultColor => accent;
  get textfieldHintColor => mainTextColor;
  get toolbarIconColor => settings; //whiteishPurple;
  get topbarColor => header; //darkGreyPurple;
}

class VampireLight extends CwtchLight {
  static final Color background = Color(0xFFFFFDFD);
  static final Color header = Color(0xFFD8C7E1);
  static final Color userBubble = Color(0xFFD8C7E1);
  static final Color peerBubble = Color(0xFFFFEBEE);
  static final Color font = Color(0xFF281831);
  static final Color settings = Color(0xFF281831);
  static final Color accent = Color(0xFF8E64A5);

  get theme => vampire_theme;
  get mode => mode_light;

  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => background; //whitePurple;
  get defaultButtonColor => accent; // hotPink;
  get dropShadowColor => userBubble;
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

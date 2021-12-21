import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const pumpkin_theme = "pumpkin";

OpaqueThemeType GetPumpkinTheme(String mode) {
  if (mode == mode_dark) {
    return PumpkinDark();
  } else {
    return PumpkinLight();
  }
}

class PumpkinDark extends CwtchDark {
  static final Color background = Color(0xFF281831);
  static final Color header = Color(0xFF281831);
  static final Color userBubble = Color(0xFFB53D00);
  static final Color peerBubble = Color(0xFF422850);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFFFBF6);
  static final Color accent = Color(0xFF8E64A5);

  get theme => pumpkin_theme;
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

class PumpkinLight extends CwtchLight {
  static final Color background = Color(0xFFFFFBF6);
  static final Color header = Color(0xFFFF9800);
  static final Color userBubble = Color(0xFFFF9800);
  static final Color peerBubble = Color(0xFFD8C7E1);
  static final Color font = Color(0xFF281831);
  static final Color settings = Color(0xFF281831);
  static final Color accent = Color(0xFF8E64A5);

  get theme => pumpkin_theme;
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

import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const neon1_theme = "neon1";

OpaqueThemeType GetNeon1Theme(String mode) {
  if (mode == mode_dark) {
    return Neon1Dark();
  } else {
    return Neon1Light();
  }
}

class Neon1Dark extends CwtchDark {
  static final Color background = Color(0xFF290826);
  static final Color header = Color(0xFF290826);
  static final Color userBubble = Color(0xFFD20070);
  static final Color peerBubble = Color(0xFF26A9A4);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFFFDFF);
  static final Color accent = Color(0xFFA604FE);

  get theme => neon1_theme;
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

class Neon1Light extends CwtchLight {
  static final Color background = Color(0xFFFFFDFF);
  static final Color header = Color(0xFFFF94C2);
  static final Color userBubble = Color(0xFFFF94C2);
  static final Color peerBubble = Color(0xFFE7F6F6);
  static final Color font = Color(0xFF290826);
  static final Color settings = Color(0xFF290826);
  static final Color accent = Color(0xFFA604FE);

  get theme => neon1_theme;
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
  get portraitOfflineBorderColor => peerBubble;
  get portraitOnlineBorderColor => font;
  get scrollbarDefaultColor => accent;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => font;
  get toolbarIconColor => settings; //darkPurple;
  get topbarColor => header; //softPurple
}

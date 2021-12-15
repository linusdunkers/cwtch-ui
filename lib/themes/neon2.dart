import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const neon2_theme = "neon2";

OpaqueThemeType GetNeon2Theme(String mode) {
  if (mode == mode_dark) {
    return Neon2Dark();
  } else {
    return Neon2Light();
  }
}

class Neon2Dark extends CwtchDark {
  static final Color background = Color(0xFF290826);
  static final Color header = Color(0xFF290826);
  static final Color userBubble = Color(0xFFA604FE);
  static final Color peerBubble = Color(0xFF03AD00);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFFFDFF);
  static final Color accent = Color(0xFFA604FE);

  get theme => neon2_theme;
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

class Neon2Light extends CwtchLight {
  static final Color background = Color(0xFFFFFDFF);
  static final Color header = Color(0xFFD8C7E1);
  static final Color userBubble = Color(0xFFD8C7E1);
  static final Color peerBubble = Color(0xFF80E27E);
  static final Color font = Color(0xFF290826);
  static final Color settings = Color(0xFF290826);
  static final Color accent = Color(0xFFA604FE);

  get theme => neon2_theme;
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
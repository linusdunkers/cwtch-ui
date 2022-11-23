import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const juniper_theme = "juniper";

OpaqueThemeType GetJuniperTheme(String mode) {
  // there is only one juniper theme
  return Juniper();
}

class Juniper extends CwtchDark {
  static final Color background = Color(0xFF1B1B1B);
  static final Color backgroundAlt = Color(0xFF494949);
  static final Color header = Color(0xFF1B1B1B);
  static final Color userBubble = Color(0xFF373737);
  static final Color peerBubble = Color(0xFF494949);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFFFFDFF);
  static final Color accent = Color(0xFF9E6A56);

  get theme => juniper_theme;
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
  get backgroundHilightElementColor => backgroundAlt;
}

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
  get mainTextColor => font; //whiteishPurple;
  get defaultButtonColor => accent; //hotPink;
  get textfieldHintColor => mainTextColor; //TODO pick
  get toolbarIconColor => settings; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;

  /*get backgroundHilightElementColor => deepPurple;
  get sendHintTextColor => mauvePurple;
  get hilightElementColor => purple;
  get defaultButtonTextColor => whiteishPurple;
  get defaultButtonDisabledColor => lightGrey;
  get defaultButtonDisabledTextColor => darkGreyPurple;
  get textfieldBackgroundColor => deepPurple;
  get textfieldBorderColor => deepPurple;
  get textfieldErrorColor => hotPink;
  get scrollbarDefaultColor => purple;
  get portraitBackgroundColor => deepPurple;
  get portraitOnlineBorderColor => whiteishPurple;
  get portraitOfflineBorderColor => purple;
  get portraitBlockedBorderColor => lightGrey;
  get portraitBlockedTextColor => lightGrey;
  get portraitContactBadgeColor => hotPink;
  get portraitContactBadgeTextColor => whiteishPurple;
  get portraitProfileBadgeColor => mauvePurple;
  get portraitProfileBadgeTextColor => darkGreyPurple;
  get dropShadowColor => mauvePurple;*/

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

  /*get backgroundHilightElementColor => softPurple;
  get sendHintTextColor  => purple;
  get hilightElementColor => purple; //darkPurple; // todo shouldn't be this, too dark, makes font unreadable
  get defaultButtonTextColor => whitePurple; // ?
  get defaultButtonDisabledColor => softGrey;
  get textfieldBackgroundColor => purple;
  get textfieldBorderColor => purple;
  get textfieldErrorColor => hotPink;
  get portraitBackgroundColor => softPurple;
  get portraitOnlineBorderColor => greyPurple;
  get portraitOfflineBorderColor => greyPurple;
  get portraitBlockedBorderColor => softGrey;
  get portraitBlockedTextColor => softGrey;
  get portraitContactBadgeTextColor => whitePurple;
  get portraitProfileBadgeColor => brightPurple;
  get portraitProfileBadgeTextColor => whitePurple;
  get dropShadowColor => purple;*/
}
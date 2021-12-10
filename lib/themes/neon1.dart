import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

final neon1_theme = "neon1";
final neon1_name = "Neon1"; //Todo translate

final Color darkGreyPurple = Color(0xFF281831);
final Color deepPurple = Color(0xFF422850);
final Color mauvePurple = Color(0xFF8E64A5);
final Color whiteishPurple = Color(0xFFE3DFE4);
final Color lightGrey = Color(0xFF9E9E9E);

final Color whitePurple = Color(0xFFFFFDFF);
final Color softPurple = Color(0xFFFDF3FC);
final Color purple = Color(0xFFDFB9DE);
final Color brightPurple = Color(0xFFD1B0E0); // not in new: portrait badge color
final Color darkPurple = Color(0xFF350052);
final Color greyPurple = Color(0xFF775F84); // not in new: portrait borders
final Color pink = Color(0xFFE85DA1); // not in new: active button color
final Color hotPink = Color(0xFFD20070); // Color(0xFFD01972);
final Color softGrey = Color(0xFFB3B6B3); // not in new theme: blocked
//static final Color softGreen = Color(0xFFA0FFB0);
//static final Color softRed = Color(0xFFFFA0B0);

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

  get name => neon1_name;
  get theme => neon1_theme;
  get mode => mode_dark;

  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  //get backgroundHilightElementColor => deepPurple;
  get mainTextColor => font; //whiteishPurple;
  //get sendHintTextColor => mauvePurple;
  //get hilightElementColor => purple;
  get defaultButtonColor => accent; //hotPink;
  /*get defaultButtonTextColor => whiteishPurple;
  get defaultButtonDisabledColor => lightGrey;
  get defaultButtonDisabledTextColor => darkGreyPurple;
  get textfieldBackgroundColor => deepPurple;
  get textfieldBorderColor => deepPurple;*/
  get textfieldHintColor => mainTextColor; //TODO pick
 /* get textfieldErrorColor => hotPink;
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
  get toolbarIconColor => settings; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
}

class Neon1Light extends CwtchLight {
  static final Color background = Color(0xFFFFFDFF);
  static final Color header = Color(0xFFFF94C2);
  static final Color userBubble = Color(0xFFFF94C2);
  static final Color peerBubble = Color(0xFFE7F6F6);
  static final Color font = Color(0xFF290826);
  static final Color settings = Color(0xFF290826);
  static final Color accent = Color(0xFFA604FE);

  get name => neon1_name;
  get theme => neon1_theme;
  get mode => mode_light;

  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => header; //softPurple;
  //get backgroundHilightElementColor => softPurple;
  get mainTextColor => settings;
  //get sendHintTextColor  => purple;
  //get hilightElementColor => purple; //darkPurple; // todo shouldn't be this, too dark, makes font unreadable
  get defaultButtonColor => accent; // hotPink;
  /*get defaultButtonTextColor => whitePurple; // ?
  get defaultButtonDisabledColor => softGrey;
  get textfieldBackgroundColor => purple;
  get textfieldBorderColor => purple; */
  get textfieldHintColor => font; //TODO pick
  //get textfieldErrorColor => hotPink;
  get scrollbarDefaultColor => accent;
  /*get portraitBackgroundColor => softPurple;
  get portraitOnlineBorderColor => greyPurple;
  get portraitOfflineBorderColor => greyPurple;
  get portraitBlockedBorderColor => softGrey;
  get portraitBlockedTextColor => softGrey;*/
  get portraitContactBadgeColor => accent;
  /*get portraitContactBadgeTextColor => whitePurple;
  get portraitProfileBadgeColor => brightPurple;
  get portraitProfileBadgeTextColor => whitePurple;
  get dropShadowColor => purple;*/
  get toolbarIconColor => settings; //darkPurple;
  get messageFromMeBackgroundColor => userBubble; //brightPurple;
  get messageFromMeTextColor => font; //mainTextColor;
  get messageFromOtherBackgroundColor => peerBubble; //purple;
  get messageFromOtherTextColor => font; //darkPurple;
}
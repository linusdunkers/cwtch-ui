import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';

import 'opaque.dart';

const cwtch_theme = "cwtch";

final Color darkGreyPurple = Color(0xFF281831);
final Color deepPurple = Color(0xFF422850);
final Color mauvePurple = Color(0xFF8E64A5);
final Color whiteishPurple = Color(0xFFE3DFE4);
final Color lightGrey = Color(0xFF9E9E9E);
final Color softGreen = Color(0xFFA0FFB0);
final Color softRed = Color(0xFFFFA0B0);

final Color whitePurple = Color(0xFFFFFDFF);
final Color softPurple = Color(0xFFFDF3FC);
final Color purple = Color(0xFFDFB9DE);
final Color brightPurple = Color(0xFFD1B0E0); // not in new: portrait badge color
final Color darkPurple = Color(0xFF350052);
final Color greyPurple = Color(0xFF775F84); // not in new: portrait borders
final Color pink = Color(0xFFE85DA1); // not in new: active button color
final Color hotPink = Color(0xFFD20070); // Color(0xFFD01972);
final Color softGrey = Color(0xFFB3B6B3); // not in new theme: blocked

OpaqueThemeType GetCwtchTheme(String mode) {
  if (mode == mode_dark) {
    return CwtchDark();
  } else {
    return CwtchLight();
  }
}

class CwtchDark extends OpaqueThemeType {
  static final Color background = darkGreyPurple;
  static final Color header = darkGreyPurple;
  static final Color userBubble = mauvePurple;
  static final Color peerBubble = deepPurple;
  static final Color font = whiteishPurple;
  static final Color settings = whiteishPurple;
  static final Color accent = hotPink;

  get theme => cwtch_theme;
  get mode => mode_dark;

  get backgroundHilightElementColor => deepPurple;
  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get defaultButtonColor => accent; //hotPink;
  get defaultButtonDisabledColor => lightGrey;
  get defaultButtonDisabledTextColor => darkGreyPurple;
  get defaultButtonTextColor => whiteishPurple;
  get dropShadowColor => mauvePurple;
  get hilightElementColor => purple;
  get mainTextColor => font; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
  get portraitBackgroundColor => deepPurple;
  get portraitBlockedBorderColor => lightGrey;
  get portraitBlockedTextColor => lightGrey;
  get portraitContactBadgeColor => hotPink;
  get portraitContactBadgeTextColor => whiteishPurple;
  get portraitOfflineBorderColor => purple;
  get portraitOnlineBorderColor => whiteishPurple;
  get portraitProfileBadgeColor => hotPink;
  get portraitProfileBadgeTextColor => whiteishPurple;
  get scrollbarDefaultColor => purple;
  get sendHintTextColor => mauvePurple;
  get textfieldBackgroundColor => deepPurple;
  get textfieldBorderColor => deepPurple;
  get textfieldErrorColor => hotPink;
  get textfieldHintColor => mainTextColor;
  get toolbarIconColor => settings; //whiteishPurple;
  get topbarColor => header; //darkGreyPurple;
}

class CwtchLight extends OpaqueThemeType {
  static final Color background = whitePurple;
  static final Color header = softPurple;
  static final Color userBubble = purple;
  static final Color peerBubble = softPurple;
  static final Color font = darkPurple;
  static final Color settings = darkPurple;
  static final Color accent = hotPink;

  get theme => cwtch_theme;
  get mode => mode_light;

  get backgroundHilightElementColor => softPurple;
  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => background; //whitePurple;
  get defaultButtonColor => accent; // hotPink;
  get defaultButtonDisabledColor => softGrey;
  get defaultButtonTextColor => whitePurple; // ?
  get dropShadowColor => purple;
  get hilightElementColor => purple;
  get mainTextColor => settings;
  get messageFromMeBackgroundColor => userBubble; //brightPurple;
  get messageFromMeTextColor => font; //mainTextColor;
  get messageFromOtherBackgroundColor => peerBubble; //purple;
  get messageFromOtherTextColor => font; //darkPurple;
  get portraitBackgroundColor => softPurple;
  get portraitBlockedBorderColor => softGrey;
  get portraitBlockedTextColor => softGrey;
  get portraitContactBadgeColor => accent;
  get portraitContactBadgeTextColor => whitePurple;
  get portraitOfflineBorderColor => greyPurple;
  get portraitOnlineBorderColor => greyPurple;
  get portraitProfileBadgeColor => accent;
  get portraitProfileBadgeTextColor => whitePurple;
  get scrollbarDefaultColor => accent;
  get sendHintTextColor => purple;
  get textfieldBackgroundColor => purple;
  get textfieldBorderColor => purple;
  get textfieldErrorColor => hotPink;
  get textfieldHintColor => font;
  get toolbarIconColor => settings; //darkPurple;
  get topbarColor => header; //softPurple;
}

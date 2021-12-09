import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';

import 'opaque.dart';

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
//static final Color softGreen = Color(0xFFA0FFB0);
//static final Color softRed = Color(0xFFFFA0B0);

class OpaqueDark extends OpaqueThemeType {
  static final Color background = darkGreyPurple;
  static final Color header = darkGreyPurple;
  static final Color userBubble = mauvePurple;
  static final Color peerBubble = deepPurple;
  static final Color font = whiteishPurple;
  static final Color settings = whiteishPurple;
  static final Color accent = hotPink;

  String identifier() {
    return mode_dark;
  }

  Color backgroundMainColor() {
    return background; // darkGreyPurple;
  }

  Color backgroundPaneColor() {
    return header; //darkGreyPurple;
  }

  Color backgroundHilightElementColor() {
    return deepPurple;
  }

  Color mainTextColor() {
    return font; //whiteishPurple;
  }

  Color sendHintTextColor() {
    return mauvePurple;
  }

  Color hilightElementColor() {
    return purple;
  }

  Color defaultButtonColor() {
    return accent; //hotPink;
  }

  Color defaultButtonActiveColor() {
    return pink;
  }

  Color defaultButtonTextColor() {
    return whiteishPurple;
  }

  Color defaultButtonDisabledColor() {
    return lightGrey;
  }

  Color defaultButtonDisabledTextColor() {
    return darkGreyPurple;
  }

  Color textfieldBackgroundColor() {
    return deepPurple;
  }

  Color textfieldBorderColor() {
    return deepPurple;
  }

  Color textfieldHintColor() {
    return mainTextColor(); //TODO pick
  }

  Color textfieldErrorColor() {
    return hotPink;
  }

  Color scrollbarDefaultColor() {
    return purple;
  }

  Color portraitBackgroundColor() {
    return deepPurple;
  }

  Color portraitOnlineBorderColor() {
    return whiteishPurple;
  }

  Color portraitOfflineBorderColor() {
    return purple;
  }

  Color portraitBlockedBorderColor() {
    return lightGrey;
  }

  Color portraitBlockedTextColor() {
    return lightGrey;
  }

  Color portraitContactBadgeColor() {
    return hotPink;
  }

  Color portraitContactBadgeTextColor() {
    return whiteishPurple;
  }

  Color portraitProfileBadgeColor() {
    return mauvePurple;
  }

  Color portraitProfileBadgeTextColor() {
    return darkGreyPurple;
  }

  Color dropShadowColor() {
    return mauvePurple;
  }

  Color toolbarIconColor() {
    return settings; //whiteishPurple;
  }

  Color messageFromMeBackgroundColor() {
    return userBubble; //  mauvePurple;
  }

  Color messageFromMeTextColor() {
    return font; //whiteishPurple;
  }

  Color messageFromOtherBackgroundColor() {
    return peerBubble; //deepPurple;
  }

  Color messageFromOtherTextColor() {
    return font; //whiteishPurple;
  }
}

class OpaqueLight extends OpaqueThemeType {
  static final Color background = whitePurple;
  static final Color header = softPurple;
  static final Color userBubble = purple;
  static final Color peerBubble = softPurple;
  static final Color font = darkPurple;
  static final Color settings = darkPurple;
  static final Color accent = hotPink;


  String identifier() {
    return mode_light;
  }

  // Main screen background color (message pane, item rows)
  Color backgroundMainColor() {
    return background; //whitePurple;
  }

  // Top pane ane pane colors (settings)
  Color backgroundPaneColor() {
    return header; //softPurple;
  }

  // Selected row color
  Color backgroundHilightElementColor() {
    // Todo: lighten? cant
    // hm... in light its the top pane color. but in dark its unique
    return softPurple;
  }

  // Main text color
  Color mainTextColor() {
    return settings;
  }

  // Faded text color for suggestions in textfields
  Color sendHintTextColor() {
    return purple;
  }

  // pressed row, offline heart
  Color hilightElementColor() {
    return purple; //darkPurple; // todo shouldn't be this, too dark, makes font unreadable
  }

  Color defaultButtonColor() {
    return accent; // hotPink;
  }

  Color defaultButtonActiveColor() {
    return pink; // todo: lighten in light, darken in dark
  }

  Color defaultButtonTextColor() {
    return whitePurple; // ?
  }

  Color defaultButtonDisabledColor() {
    return softGrey;
  }

  Color textfieldBackgroundColor() {
    return purple;
  }

  Color textfieldBorderColor() {
    return purple;
  }
  
  Color textfieldHintColor() {
    return font; //TODO pick
  }

  Color textfieldErrorColor() {
    return hotPink;
  }

  // todo button
  Color scrollbarDefaultColor() {
    return accent;
  }

  Color portraitBackgroundColor() {
    return softPurple;
  }

  Color portraitOnlineBorderColor() {
    return greyPurple;
  }

  Color portraitOfflineBorderColor() {
    return greyPurple;
  }

  Color portraitBlockedBorderColor() {
    return softGrey;
  }

  Color portraitBlockedTextColor() {
    return softGrey;
  }

  Color portraitContactBadgeColor() {
    return accent;
  }

  Color portraitContactBadgeTextColor() {
    return whitePurple; // todo button color
  }

  // TODO del
  Color portraitProfileBadgeColor() {
    return brightPurple;
  }

  // TODO del
  Color portraitProfileBadgeTextColor() {
    return whitePurple;
  }

  Color dropShadowColor() {
    return purple;
  }

  Color toolbarIconColor() {
    return settings; //darkPurple;
  }

  Color messageFromMeBackgroundColor() {
    return userBubble; //brightPurple;
  }

  Color messageFromMeTextColor() {
    return font; //mainTextColor();
  }

  Color messageFromOtherBackgroundColor() {
    return peerBubble; //purple;
  }

  Color messageFromOtherTextColor() {
    return font; //darkPurple;
  }
}
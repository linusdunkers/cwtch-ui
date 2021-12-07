import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';

import 'opaque.dart';

class OpaqueDark extends OpaqueThemeType {
  static final Color darkGreyPurple = Color(0xFF281831);
  static final Color deepPurple = Color(0xFF422850);
  static final Color mauvePurple = Color(0xFF8E64A5);
  static final Color purple = Color(0xFFDFB9DE);
  static final Color whitePurple = Color(0xFFE3DFE4);
  static final Color softPurple = Color(0xFFFDF3FC);
  static final Color pink = Color(0xFFE85DA1);
  static final Color hotPink = Color(0xFFD01972);
  static final Color lightGrey = Color(0xFF9E9E9E);
  static final Color softGreen = Color(0xFFA0FFB0);
  static final Color softRed = Color(0xFFFFA0B0);

  String identifier() {
    return "dark";
  }

  Color backgroundMainColor() {
    return darkGreyPurple;
  }

  Color backgroundPaneColor() {
    return darkGreyPurple;
  }

  Color backgroundHilightElementColor() {
    return deepPurple;
  }

  Color mainTextColor() {
    return whitePurple;
  }

  Color altTextColor() {
    return mauvePurple;
  }

  Color hilightElementTextColor() {
    return purple;
  }

  Color defaultButtonColor() {
    return hotPink;
  }

  Color defaultButtonActiveColor() {
    return pink;
  }

  Color defaultButtonTextColor() {
    return whitePurple;
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

  Color textfieldErrorColor() {
    return hotPink;
  }

  Color scrollbarDefaultColor() {
    return purple;
  }

  Color scrollbarActiveColor() {
    return hotPink;
  }

  Color portraitOnlineBorderColor() {
    return whitePurple;
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
    return whitePurple;
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
    return whitePurple;
  }

  Color messageFromMeBackgroundColor() {
    return mauvePurple;
  }

  Color messageFromMeTextColor() {
    return whitePurple;
  }

  Color messageFromOtherBackgroundColor() {
    return deepPurple;
  }

  Color messageFromOtherTextColor() {
    return whitePurple;
  }
}

class OpaqueLight extends OpaqueThemeType {
  static final Color whitePurple = Color(0xFFFFFDFF);
  static final Color softPurple = Color(0xFFFDF3FC);
  static final Color purple = Color(0xFFDFB9DE);
  static final Color brightPurple = Color(0xFFD1B0E0);
  static final Color darkPurple = Color(0xFF350052);
  static final Color greyPurple = Color(0xFF775F84);
  static final Color pink = Color(0xFFE85DA1);
  static final Color hotPink = Color(0xFFD01972);
  static final Color lightGrey = Color(0xFFB3B6B3);
  static final Color softGreen = Color(0xFFA0FFB0);
  static final Color softRed = Color(0xFFFFA0B0);

  String identifier() {
    return "light";
  }

  Color backgroundMainColor() {
    return whitePurple;
  }

  Color backgroundPaneColor() {
    return softPurple;
  }

  Color backgroundHilightElementColor() {
    return softPurple;
  }

  Color mainTextColor() {
    return darkPurple;
  }

  Color altTextColor() {
    return purple;
  }

  Color hilightElementTextColor() {
    return darkPurple;
  }

  Color defaultButtonColor() {
    return hotPink;
  }

  Color defaultButtonActiveColor() {
    return pink;
  }

  Color defaultButtonTextColor() {
    return whitePurple;
  }

  Color defaultButtonDisabledColor() {
    return lightGrey;
  }

  Color textfieldBackgroundColor() {
    return purple;
  }

  Color textfieldBorderColor() {
    return purple;
  }

  Color textfieldErrorColor() {
    return hotPink;
  }

  Color scrollbarDefaultColor() {
    return darkPurple;
  }

  Color scrollbarActiveColor() {
    return hotPink;
  }

  Color portraitOnlineBorderColor() {
    return greyPurple;
  }

  Color portraitOfflineBorderColor() {
    return greyPurple;
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
    return whitePurple;
  }

  Color portraitProfileBadgeColor() {
    return brightPurple;
  }

  Color portraitProfileBadgeTextColor() {
    return whitePurple;
  }

  Color dropShadowColor() {
    return purple;
  }

  Color toolbarIconColor() {
    return darkPurple;
  }

  Color messageFromMeBackgroundColor() {
    return brightPurple;
  }

  Color messageFromMeTextColor() {
    return mainTextColor();
  }

  Color messageFromOtherBackgroundColor() {
    return purple;
  }

  Color messageFromOtherTextColor() {
    return darkPurple;
  }
}
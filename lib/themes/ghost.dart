import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const ghost_theme = "ghost";

OpaqueThemeType GetGhostTheme(String mode) {
  if (mode == mode_dark) {
    return GhostDark();
  } else {
    return GhostLight();
  }
}

class GhostDark extends CwtchDark {
  static final Color darkBlue = Color(0xFF000051);
  static final Color lightBlue = Color(0xFF1A237E);

  static final Color background = Color(0xFF0D0D1F);
  static final Color header = Color(0xFF0D0D1F);
  static final Color userBubble = lightBlue;
  static final Color peerBubble = darkBlue;
  static final Color font = Colors.white;
  static final Color settings = Color(0xFFFDFFFD);
  static final Color accent = lightBlue;//Color(0xFFD20070);

  get theme => ghost_theme;
  get mode => mode_dark;

  get backgroundHilightElementColor => darkBlue;
  get backgroundMainColor => background;
  get backgroundPaneColor => header;
  get defaultButtonColor => accent;
  get dropShadowColor => GhostLight.darkBlue;
  get mainTextColor => font;
  get messageFromMeBackgroundColor => userBubble;
  get messageFromMeTextColor => font;
  get messageFromOtherBackgroundColor => peerBubble;
  get messageFromOtherTextColor => font;
  get scrollbarDefaultColor => lightBlue;
  get sendHintTextColor => GhostLight.darkBlue;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => mainTextColor;
  get toolbarIconColor => settings;
  get topbarColor => header;
}

class GhostLight extends CwtchLight {
  static final Color darkBlue = Color(0xFFAAB6FE);
  static final Color lighterDarkBlue = Color(0xFFc3ccfe);
  static final Color lightBlue = Color(0xFFE8EAF6);

  static final Color background = Color(0xFFFDFDFF);
  static final Color header = darkBlue;
  static final Color userBubble = darkBlue;
  static final Color peerBubble = lightBlue;
  static final Color font = Color(0xFF0D0D1F);
  static final Color settings = Color(0xFF0D0D1F);
  static final Color accent = darkBlue;

  get theme => ghost_theme;
  get mode => mode_light;

  get backgroundHilightElementColor => peerBubble;
  get backgroundMainColor => background;
  get backgroundPaneColor => background;
  get defaultButtonColor => accent;
  get defaultButtonActiveColor => lighterDarkBlue;
  get defaultButtonDisabledColor => peerBubble;
  get dropShadowColor => darkBlue;
  get mainTextColor => settings;
  get messageFromMeBackgroundColor => userBubble;
  get messageFromMeTextColor => font;
  get messageFromOtherBackgroundColor => peerBubble;
  get messageFromOtherTextColor => font;
  get portraitContactBadgeColor => accent;
  get scrollbarDefaultColor => accent;
  get sendHintTextColor => lightBlue;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => font;
  get toolbarIconColor => settings;
  get topbarColor => header;
}

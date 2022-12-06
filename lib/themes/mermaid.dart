import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

const mermaid_theme = "mermaid";

OpaqueThemeType GetMermaidTheme(String mode) {
  if (mode == mode_dark) {
    return MermaidDark();
  } else {
    return MermaidLight();
  }
}

class MermaidDark extends CwtchDark {
  static final Color lavender = Color(0xFFB194C1);

  static final Color background = Color(0xFF102426);
  static final Color header = Color(0xFF102426);
  static final Color userBubble = Color(0xFF00838F);
  static final Color peerBubble = Color(0xFF00363A);
  static final Color font = Colors.white;
  static final Color settings = Color(0xFFF7FCFD);
  static final Color accent = Color(0xFF8E64A5);

  get theme => mermaid_theme;
  get mode => mode_dark;

  get backgroundHilightElementColor => peerBubble;
  get backgroundMainColor => background; // darkGreyPurple;
  get backgroundPaneColor => header; //darkGreyPurple;
  get defaultButtonColor => accent; //hotPink;
  get dropShadowColor => lavender;
  get mainTextColor => font; //whiteishPurple;
  get messageFromMeBackgroundColor => userBubble; //  mauvePurple;
  get messageFromMeTextColor => font; //whiteishPurple;
  get messageFromOtherBackgroundColor => peerBubble; //deepPurple;
  get messageFromOtherTextColor => font; //whiteishPurple;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => mainTextColor;
  get toolbarIconColor => settings; //whiteishPurple;
  get topbarColor => header; //darkGreyPurple;
}

class MermaidLight extends CwtchLight {
  static final Color background = Color(0xFFF7FCFD);
  static final Color header = Color(0xFF56C8D8);
  static final Color userBubble = Color(0xFF56C8D8);
  static final Color peerBubble = Color(0xFFB2EBF2);
  static final Color font = Color(0xFF102426);
  static final Color settings = Color(0xFF102426);
  static final Color accent = Color(0xFF8E64A5);

  get theme => mermaid_theme;
  get mode => mode_light;

  get backgroundHilightElementColor => peerBubble;
  get backgroundMainColor => background; //whitePurple;
  get backgroundPaneColor => background; //whitePurple;
  get defaultButtonColor => accent; // hotPink;
  get dropShadowColor => peerBubble;
  get mainTextColor => settings;
  get messageFromMeBackgroundColor => userBubble; //brightPurple;
  get messageFromMeTextColor => font; //mainTextColor;
  get messageFromOtherBackgroundColor => peerBubble; //purple;
  get messageFromOtherTextColor => font; //darkPurple;
  get portraitContactBadgeColor => accent;
  get scrollbarDefaultColor => accent;
  get textfieldBackgroundColor => peerBubble;
  get textfieldBorderColor => userBubble;
  get textfieldHintColor => font;
  get toolbarIconColor => settings; //darkPurple;
  get topbarColor => header; //softPurple;
}

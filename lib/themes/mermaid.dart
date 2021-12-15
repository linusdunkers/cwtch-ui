import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';

import 'opaque.dart';

final mermaid_theme = "mermaid";
final mermaid_name = "Mermaid"; //Todo translate

OpaqueThemeType GetMermaidTheme(String mode) {
  if (mode == mode_dark) {
    return MermaidDark();
  } else {
    return MermaidLight();
  }
}

class MermaidDark extends CwtchDark {
  static final Color background = Color(0xFF102426);
  static final Color header = Color(0xFF102426);
  static final Color userBubble = Color(0xFF00838F);
  static final Color peerBubble = Color(0xFF00363A);
  static final Color font = Color(0xFFFFFFFF);
  static final Color settings = Color(0xFFF7FCFD);
  static final Color accent = Color(0xFF8E64A5);

  get name => mermaid_name;
  get theme => mermaid_theme;
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

class MermaidLight extends CwtchLight {
  static final Color background = Color(0xFFF7FCFD);
  static final Color header = Color(0xFF56C8D8);
  static final Color userBubble = Color(0xFF56C8D8);
  static final Color peerBubble = Color(0xFFB2EBF2);
  static final Color font = Color(0xFF102426);
  static final Color settings = Color(0xFF102426);
  static final Color accent = Color(0xFF8E64A5);

  get name => mermaid_name;
  get theme => mermaid_theme;
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
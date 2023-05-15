import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:cwtch/themes/juniper.dart';
import 'package:cwtch/themes/mermaid.dart';
import 'package:cwtch/themes/neon1.dart';
import 'package:cwtch/themes/pumpkin.dart';
import 'package:cwtch/themes/vampire.dart';
import 'package:cwtch/themes/witch.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:flutter/services.dart';

import 'ghost.dart';
import 'midnight.dart';
import 'neon2.dart';

const mode_light = "light";
const mode_dark = "dark";

final themes = {
  cwtch_theme: {mode_light: CwtchLight(), mode_dark: CwtchDark()},
  ghost_theme: {mode_light: GhostLight(), mode_dark: GhostDark()},
  juniper_theme: {mode_light: Juniper(), mode_dark: Juniper()},
  mermaid_theme: {mode_light: MermaidLight(), mode_dark: MermaidDark()},
  midnight_theme: {mode_light: MidnightLight(), mode_dark: MidnightDark()},
  neon1_theme: {mode_light: Neon1Light(), mode_dark: Neon1Dark()},
  neon2_theme: {mode_light: Neon2Light(), mode_dark: Neon2Dark()},
  pumpkin_theme: {mode_light: PumpkinLight(), mode_dark: PumpkinDark()},
  vampire_theme: {mode_light: VampireLight(), mode_dark: VampireDark()},
  witch_theme: {mode_light: WitchLight(), mode_dark: WitchDark()},
};

OpaqueThemeType getTheme(String themeId, String mode) {
  if (themeId == "") {
    themeId = cwtch_theme;
  }
  if (themeId == mode_light) {
    themeId = cwtch_theme;
    mode = mode_light;
  }
  if (themeId == mode_dark) {
    themeId = cwtch_theme;
    mode = mode_dark;
  }

  var theme = themes[themeId]?[mode];
  return theme ?? CwtchDark();
}

Color lighten(Color color, [double amount = 0.15]) {
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Color darken(Color color, [double amount = 0.15]) {
  final hsl = HSLColor.fromColor(color);
  final hslDarken = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDarken.toColor();
}

abstract class OpaqueThemeType {
  static final Color red = Color(0xFFFF0000);

  get theme => "dummy";
  get mode => mode_light;

  // Main screen background color (message pane, item rows)
  get backgroundMainColor => red;

  // pane colors (settings)
  get backgroundPaneColor => red;

  get topbarColor => red;

  get mainTextColor => red;

  // pressed row, offline heart
  get hilightElementColor => red;
  // Selected Row
  get backgroundHilightElementColor => red;
  // Faded text color for suggestions in textfields
  // Todo: implement way more places
  get sendHintTextColor => red;

  get defaultButtonColor => red;
  get defaultButtonActiveColor => /*mode == mode_light ? darken(defaultButtonColor) :*/ lighten(defaultButtonColor);
  get defaultButtonTextColor => red;
  get defaultButtonDisabledColor => red;
  get textfieldBackgroundColor => red;
  get textfieldBorderColor => red;
  get textfieldHintColor => red;
  get textfieldErrorColor => red;
  get scrollbarDefaultColor => red;
  get portraitBackgroundColor => red;
  get portraitOnlineBorderColor => red;
  get portraitOfflineBorderColor => red;
  get portraitBlockedBorderColor => red;
  get portraitBlockedTextColor => red;
  get portraitContactBadgeColor => red;
  get portraitContactBadgeTextColor => red;
  get portraitProfileBadgeColor => red;
  get portraitProfileBadgeTextColor => red;

  get portraitOnlineAwayColor => Color(0xFFFFF59D);
  get portraitOnlineBusyColor => Color(0xFFEF9A9A);

  // dropshaddpow
  // todo: probably should not be reply icon color in messagerow
  get dropShadowColor => red;

  get toolbarIconColor => red;
  get messageFromMeBackgroundColor => red;
  get messageFromMeTextColor => red;
  get messageFromOtherBackgroundColor => red;
  get messageFromOtherTextColor => red;

  // Sizes
  double contactOnionTextSize() {
    return 18;
  }
}

ThemeData mkThemeData(Settings opaque) {
  return ThemeData(
    hoverColor: opaque.current().backgroundHilightElementColor.withOpacity(0.5),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.red,
    primaryIconTheme: IconThemeData(
      color: opaque.current().mainTextColor,
    ),
    primaryColor: opaque.current().mainTextColor,
    canvasColor: opaque.current().backgroundMainColor,
    backgroundColor: opaque.current().backgroundMainColor,
    highlightColor: opaque.current().hilightElementColor,
    iconTheme: IconThemeData(
      color: opaque.current().toolbarIconColor,
    ),
    cardColor: opaque.current().backgroundMainColor,
    appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          // Status bar color
          statusBarColor: opaque.current().topbarColor,
          // Status bar brightness (optional)
          statusBarIconBrightness: opaque.current().mode == mode_light ? Brightness.dark : Brightness.light, // For Android (dark icons)
          statusBarBrightness: opaque.current().mode == mode_light ? Brightness.dark : Brightness.light, // For iOS (dark icons)
        ),
        backgroundColor: opaque.current().topbarColor,
        iconTheme: IconThemeData(
          color: opaque.current().mainTextColor,
        ),
        titleTextStyle: TextStyle(color: opaque.current().mainTextColor, fontSize: opaque.fontScaling * 18.0),
        actionsIconTheme: IconThemeData(
          color: opaque.current().mainTextColor,
        )),

    //bottomNavigationBarTheme: BottomNavigationBarThemeData(type: BottomNavigationBarType.fixed, backgroundColor: opaque.current().backgroundHilightElementColor),  // Can't determine current use
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(opaque.current().defaultButtonColor),
          foregroundColor: MaterialStateProperty.all(opaque.current().defaultButtonTextColor),
          overlayColor: MaterialStateProperty.all(opaque.current().defaultButtonActiveColor),
          padding: MaterialStateProperty.all(EdgeInsets.all(20))),
    ),
    hintColor: opaque.current().textfieldHintColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.disabled) ? opaque.current().defaultButtonDisabledColor : opaque.current().defaultButtonColor),
        foregroundColor: MaterialStateProperty.all(opaque.current().defaultButtonTextColor),
        overlayColor: MaterialStateProperty.resolveWith((states) => (states.contains(MaterialState.pressed) && states.contains(MaterialState.hovered))
            ? opaque.current().defaultButtonActiveColor
            : states.contains(MaterialState.disabled)
                ? opaque.current().defaultButtonDisabledColor
                : null),
        enableFeedback: true,
        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        )),
      ),
    ),

    scrollbarTheme: ScrollbarThemeData(isAlwaysShown: false, thumbColor: MaterialStateProperty.all(opaque.current().scrollbarDefaultColor)),
    tabBarTheme: TabBarTheme(
        labelColor: opaque.current().mainTextColor,
        unselectedLabelColor: opaque.current().mainTextColor,
        indicator: UnderlineTabIndicator(borderSide: BorderSide(color: opaque.current().defaultButtonActiveColor))),
    dialogTheme: DialogTheme(
        backgroundColor: opaque.current().backgroundPaneColor,
        titleTextStyle: TextStyle(color: opaque.current().mainTextColor),
        contentTextStyle: TextStyle(
          color: opaque.current().mainTextColor,
        )),
    textTheme: TextTheme(
      displayMedium: TextStyle(fontSize: opaque.fontScaling * 16.0, color: opaque.current().mainTextColor),
      displaySmall: TextStyle(fontSize: opaque.fontScaling * 14.0, color: opaque.current().mainTextColor),
      displayLarge: TextStyle(fontSize: opaque.fontScaling * 18.0, color: opaque.current().mainTextColor),
      titleSmall: TextStyle(fontSize: opaque.fontScaling * 16.0, color: opaque.current().mainTextColor),
      titleLarge: TextStyle(fontSize: opaque.fontScaling * 18.0, color: opaque.current().mainTextColor),
      titleMedium: TextStyle(fontSize: opaque.fontScaling * 20.0, color: opaque.current().mainTextColor),
      bodySmall: TextStyle(fontSize: opaque.fontScaling * 12.0, color: opaque.current().mainTextColor),
      bodyMedium: TextStyle(fontSize: opaque.fontScaling * 14.0, color: opaque.current().mainTextColor),
      bodyLarge: TextStyle(fontSize: opaque.fontScaling * 16.0, color: opaque.current().mainTextColor),
      headlineSmall: TextStyle(fontSize: opaque.fontScaling * 24.0, color: opaque.current().mainTextColor),
      headlineMedium: TextStyle(fontSize: opaque.fontScaling * 26.0, color: opaque.current().mainTextColor),
      headlineLarge: TextStyle(fontSize: opaque.fontScaling * 28.0, color: opaque.current().mainTextColor),
      labelSmall: TextStyle(fontSize: opaque.fontScaling * 14.0, color: opaque.current().mainTextColor),
      labelLarge: TextStyle(fontSize: opaque.fontScaling * 16.0, color: opaque.current().mainTextColor),
      labelMedium: TextStyle(fontSize: opaque.fontScaling * 18.0, color: opaque.current().mainTextColor),
    ),
    switchTheme: SwitchThemeData(
      overlayColor: MaterialStateProperty.all(opaque.current().defaultButtonActiveColor),
      thumbColor: MaterialStateProperty.all(opaque.current().mainTextColor),
      trackColor: MaterialStateProperty.all(opaque.current().dropShadowColor),
    ),
    // the only way to change the text Selection Context Menu Color ?!
    brightness: opaque.current().mode == mode_dark ? Brightness.dark : Brightness.light,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: opaque.current().mainTextColor,
        backgroundColor: opaque.current().defaultButtonColor,
        hoverColor: opaque.current().defaultButtonActiveColor,
        enableFeedback: true,
        splashColor: opaque.current().defaultButtonActiveColor),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: opaque.current().defaultButtonActiveColor, selectionColor: opaque.current().defaultButtonActiveColor, selectionHandleColor: opaque.current().defaultButtonActiveColor),
  );
}

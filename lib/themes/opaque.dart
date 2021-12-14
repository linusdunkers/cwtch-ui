import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:cwtch/themes/neon1.dart';
import 'package:cwtch/themes/vampire.dart';
import 'package:cwtch/themes/witch.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';

const mode_light = "light";
const mode_dark = "dark";

final themes = { cwtch_theme: {mode_light: CwtchLight(), mode_dark: CwtchDark()},
  neon1_theme: {mode_light: Neon1Light(), mode_dark: Neon1Dark()},
  witch_theme: {mode_light: WitchLight(), mode_dark: WitchDark()},
  vampire_theme: {mode_light: VampireLight(), mode_dark: VampireDark()},
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

  get name => "Dummy";
  get theme => "dummy";
  get mode => mode_light;

  // Main screen background color (message pane, item rows)
  get backgroundMainColor => red;

  // Top pane ane pane colors (settings)
  get backgroundPaneColor => red;

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
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primarySwatch: Colors.red,
    primaryIconTheme: IconThemeData(
      color: opaque.current().mainTextColor,
    ),
    primaryColor: opaque.current().backgroundMainColor,
    canvasColor: opaque.current().backgroundPaneColor,
    backgroundColor: opaque.current().backgroundMainColor,
    highlightColor: opaque.current().hilightElementColor,
    iconTheme: IconThemeData(
      color: opaque.current().toolbarIconColor,
    ),
    cardColor: opaque.current().backgroundMainColor,
    appBarTheme: AppBarTheme(
        backgroundColor: opaque.current().backgroundPaneColor,
        iconTheme: IconThemeData(
          color: opaque.current().mainTextColor,
        ),
        titleTextStyle: TextStyle(
          color: opaque.current().mainTextColor,
        ),
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
        splashFactory: InkRipple.splashFactory,
        padding: MaterialStateProperty.all(EdgeInsets.all(20)),
        shape: MaterialStateProperty.all(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        )),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
        isAlwaysShown: false, thumbColor: MaterialStateProperty.all(opaque.current().scrollbarDefaultColor)),
    tabBarTheme: TabBarTheme(indicator: UnderlineTabIndicator(borderSide: BorderSide(color: opaque.current().defaultButtonActiveColor))),
    dialogTheme: DialogTheme(
        backgroundColor: opaque.current().backgroundPaneColor,
        titleTextStyle: TextStyle(color: opaque.current().mainTextColor),
        contentTextStyle: TextStyle(color: opaque.current().mainTextColor)),
    textTheme: TextTheme(
        headline1: TextStyle(color: opaque.current().mainTextColor),
        headline2: TextStyle(color: opaque.current().mainTextColor),
        headline3: TextStyle(color: opaque.current().mainTextColor),
        headline4: TextStyle(color: opaque.current().mainTextColor),
        headline5: TextStyle(color: opaque.current().mainTextColor),
        headline6: TextStyle(color: opaque.current().mainTextColor),
        bodyText1: TextStyle(color: opaque.current().mainTextColor),
        bodyText2: TextStyle(color: opaque.current().mainTextColor),
        subtitle1: TextStyle(color: opaque.current().mainTextColor),
        subtitle2: TextStyle(color: opaque.current().mainTextColor),
        caption: TextStyle(color: opaque.current().mainTextColor),
        button: TextStyle(color: opaque.current().mainTextColor),
        overline: TextStyle(color: opaque.current().mainTextColor)),
    switchTheme: SwitchThemeData(
      overlayColor: MaterialStateProperty.all(opaque.current().defaultButtonActiveColor),
      thumbColor: MaterialStateProperty.all(opaque.current().mainTextColor),
      trackColor: MaterialStateProperty.all(opaque.current().dropShadowColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: opaque.current().defaultButtonColor,
        hoverColor: opaque.current().defaultButtonActiveColor,
        enableFeedback: true,
        splashColor: opaque.current().defaultButtonActiveColor),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: opaque.current().defaultButtonActiveColor, selectionColor: opaque.current().defaultButtonActiveColor, selectionHandleColor: opaque.current().defaultButtonActiveColor),
  );
}

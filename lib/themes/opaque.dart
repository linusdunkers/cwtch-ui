import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';

abstract class OpaqueThemeType {
  static final Color red = Color(0xFFFF0000);

  String identifier() {
    return "dummy";
  }

  Color backgroundMainColor() {
    return red;
  }

  Color backgroundPaneColor() {
    return red;
  }

  Color backgroundHilightElementColor() {
    return red;
  }

  Color mainTextColor() {
    return red;
  }

  Color altTextColor() {
    return red;
  }

  Color hilightElementTextColor() {
    return red;
  }

  Color defaultButtonColor() {
    return red;
  }

  Color defaultButtonActiveColor() {
    return red;
  }

  Color defaultButtonTextColor() {
    return red;
  }

  Color defaultButtonDisabledColor() {
    return red;
  }

  Color textfieldBackgroundColor() {
    return red;
  }

  Color textfieldBorderColor() {
    return red;
  }

  Color textfieldErrorColor() {
    return red;
  }

  Color scrollbarDefaultColor() {
    return red;
  }

  Color scrollbarActiveColor() {
    return red;
  }

  Color portraitOnlineBorderColor() {
    return red;
  }

  Color portraitOfflineBorderColor() {
    return red;
  }

  Color portraitBlockedBorderColor() {
    return red;
  }

  Color portraitBlockedTextColor() {
    return red;
  }

  Color portraitContactBadgeColor() {
    return red;
  }

  Color portraitContactBadgeTextColor() {
    return red;
  }

  Color portraitProfileBadgeColor() {
    return red;
  }

  Color portraitProfileBadgeTextColor() {
    return red;
  }

  Color dropShadowColor() {
    return red;
  }

  Color toolbarIconColor() {
    return red;
  }

  Color messageFromMeBackgroundColor() {
    return red;
  }

  Color messageFromMeTextColor() {
    return red;
  }

  Color messageFromOtherBackgroundColor() {
    return red;
  }

  Color messageFromOtherTextColor() {
    return red;
  }

  // ... more to come

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
      color: opaque.current().mainTextColor(),
    ),
    primaryColor: opaque.current().backgroundMainColor(),
    canvasColor: opaque.current().backgroundPaneColor(),
    backgroundColor: opaque.current().backgroundMainColor(),
    highlightColor: opaque.current().hilightElementTextColor(),
    iconTheme: IconThemeData(
      color: opaque.current().toolbarIconColor(),
    ),
    cardColor: opaque.current().backgroundMainColor(),
    appBarTheme: AppBarTheme(
        backgroundColor: opaque.current().backgroundPaneColor(),
        iconTheme: IconThemeData(
          color: opaque.current().mainTextColor(),
        ),
        titleTextStyle: TextStyle(
          color: opaque.current().mainTextColor(),
        ),
        actionsIconTheme: IconThemeData(
          color: opaque.current().mainTextColor(),
        )),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(type: BottomNavigationBarType.fixed, backgroundColor: opaque.current().backgroundHilightElementColor()),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(opaque.current().defaultButtonColor()),
          foregroundColor: MaterialStateProperty.all(opaque.current().defaultButtonTextColor()),
          overlayColor: MaterialStateProperty.all(opaque.current().defaultButtonActiveColor()),
          padding: MaterialStateProperty.all(EdgeInsets.all(20))),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.disabled) ? opaque.current().defaultButtonDisabledColor() : opaque.current().defaultButtonColor()),
        foregroundColor: MaterialStateProperty.all(opaque.current().defaultButtonTextColor()),
        overlayColor: MaterialStateProperty.resolveWith((states) => (states.contains(MaterialState.pressed) && states.contains(MaterialState.hovered))
            ? opaque.current().defaultButtonActiveColor()
            : states.contains(MaterialState.disabled)
                ? opaque.current().defaultButtonDisabledColor()
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
        isAlwaysShown: false, thumbColor: MaterialStateProperty.all(opaque.current().scrollbarActiveColor()), trackColor: MaterialStateProperty.all(opaque.current().scrollbarDefaultColor())),
    tabBarTheme: TabBarTheme(indicator: UnderlineTabIndicator(borderSide: BorderSide(color: opaque.current().defaultButtonActiveColor()))),
    dialogTheme: DialogTheme(
        backgroundColor: opaque.current().backgroundPaneColor(),
        titleTextStyle: TextStyle(color: opaque.current().mainTextColor()),
        contentTextStyle: TextStyle(color: opaque.current().mainTextColor())),
    textTheme: TextTheme(
        headline1: TextStyle(color: opaque.current().mainTextColor()),
        headline2: TextStyle(color: opaque.current().mainTextColor()),
        headline3: TextStyle(color: opaque.current().mainTextColor()),
        headline4: TextStyle(color: opaque.current().mainTextColor()),
        headline5: TextStyle(color: opaque.current().mainTextColor()),
        headline6: TextStyle(color: opaque.current().mainTextColor()),
        bodyText1: TextStyle(color: opaque.current().mainTextColor()),
        bodyText2: TextStyle(color: opaque.current().mainTextColor()),
        subtitle1: TextStyle(color: opaque.current().mainTextColor()),
        subtitle2: TextStyle(color: opaque.current().mainTextColor()),
        caption: TextStyle(color: opaque.current().mainTextColor()),
        button: TextStyle(color: opaque.current().mainTextColor()),
        overline: TextStyle(color: opaque.current().mainTextColor())),
    switchTheme: SwitchThemeData(
      overlayColor: MaterialStateProperty.all(opaque.current().defaultButtonActiveColor()),
      thumbColor: MaterialStateProperty.all(opaque.current().mainTextColor()),
      trackColor: MaterialStateProperty.all(opaque.current().dropShadowColor()),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: opaque.current().defaultButtonColor(),
        hoverColor: opaque.current().defaultButtonActiveColor(),
        enableFeedback: true,
        splashColor: opaque.current().defaultButtonActiveColor()),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: opaque.current().defaultButtonActiveColor(), selectionColor: opaque.current().defaultButtonActiveColor(), selectionHandleColor: opaque.current().defaultButtonActiveColor()),
  );
}

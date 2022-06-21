import 'package:flutter/material.dart';

// Flutter doesn't supported Luxembourgish, or Welsh, so we have to provide our
// own delegate for built-in widget translations...
class MaterialLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == "lb" || locale.languageCode == "cy";
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case "cy":
        return MaterialLocalizationCy();
      case "lb":
        return MaterialLocalizationLu();
    }
    throw UnimplementedError("unknown language");
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) {
    return false;
  }
}

// Support Welsh, Default to English
class MaterialLocalizationCy extends DefaultMaterialLocalizations {}

// Support Luxembourgish, Default to German
class MaterialLocalizationLu extends MaterialLocalizations {
  @override
  String get aboutListTileTitleRaw => r'Über $applicationName';

  @override
  String get alertDialogLabel => 'Benachrichtigung';

  @override
  String get anteMeridiemAbbreviation => 'AM';

  @override
  String get backButtonTooltip => 'Zurück';

  @override
  String get calendarModeButtonLabel => 'Zum Kalender wechseln';

  @override
  String get cancelButtonLabel => 'ABBRECHEN';

  @override
  String get closeButtonLabel => 'SCHLIEẞEN';

  @override
  String get closeButtonTooltip => 'Schließen';

  @override
  String get collapsedIconTapHint => 'Maximieren';

  @override
  String get continueButtonLabel => 'WEITER';

  @override
  String get copyButtonLabel => 'Kopieren';

  @override
  String get cutButtonLabel => 'Ausschneiden';

  @override
  String get dateHelpText => 'tt.mm.jjjj';

  @override
  String get dateInputLabel => 'Datum eingeben';

  @override
  String get dateOutOfRangeLabel => 'Außerhalb des Zeitraums.';

  @override
  String get datePickerHelpText => 'DATUM AUSWÄHLEN';

  @override
  String get dateRangeEndDateSemanticLabelRaw => r'Enddatum $fullDate';

  @override
  String get dateRangeEndLabel => 'Enddatum';

  @override
  String get dateRangePickerHelpText => 'ZEITRAUM AUSWÄHLEN';

  @override
  String get dateRangeStartDateSemanticLabelRaw => r'Startdatum $fullDate';

  @override
  String get dateRangeStartLabel => 'Startdatum';

  @override
  String get dateSeparator => '.';

  @override
  String get deleteButtonTooltip => 'Löschen';

  @override
  String get dialModeButtonLabel => 'Zur Uhrzeitauswahl wechseln';

  @override
  String get dialogLabel => 'Dialogfeld';

  @override
  String get drawerLabel => 'Navigationsmenü';

  @override
  String get expandedIconTapHint => 'Minimieren';

  @override
  String get firstPageTooltip => 'Erste Seite';

  @override
  String get hideAccountsLabel => 'Konten ausblenden';

  @override
  String get inputDateModeButtonLabel => 'Zur Texteingabe wechseln';

  @override
  String get inputTimeModeButtonLabel => 'Zum Texteingabemodus wechseln';

  @override
  String get invalidDateFormatLabel => 'Ungültiges Format.';

  @override
  String get invalidDateRangeLabel => 'Ungültiger Zeitraum.';

  @override
  String get invalidTimeLabel => 'Geben Sie eine gültige Uhrzeit ein';

  @override
  String get lastPageTooltip => 'Letzte Seite';

  @override
  String? get licensesPackageDetailTextFew => null;

  @override
  String? get licensesPackageDetailTextMany => null;

  @override
  String? get licensesPackageDetailTextOne => '1 Lizenz';

  @override
  String get licensesPackageDetailTextOther => r'$licenseCount Lizenzen';

  @override
  String? get licensesPackageDetailTextTwo => null;

  @override
  String? get licensesPackageDetailTextZero => 'No licenses';

  @override
  String get licensesPageTitle => 'Lizenzen';

  @override
  String get modalBarrierDismissLabel => 'Schließen';

  @override
  String get moreButtonTooltip => 'Mehr';

  @override
  String get nextMonthTooltip => 'Nächster Monat';

  @override
  String get nextPageTooltip => 'Nächste Seite';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get openAppDrawerTooltip => 'Navigationsmenü öffnen';

  @override
  String get pageRowsInfoTitleRaw => r'$firstRow–$lastRow von $rowCount';

  @override
  String get pageRowsInfoTitleApproximateRaw => r'$firstRow–$lastRow von etwa $rowCount';

  @override
  String get pasteButtonLabel => 'Einsetzen';

  @override
  String get popupMenuLabel => 'Pop-up-Menü';

  @override
  String get postMeridiemAbbreviation => 'PM';

  @override
  String get previousMonthTooltip => 'Vorheriger Monat';

  @override
  String get previousPageTooltip => 'Vorherige Seite';

  @override
  String get refreshIndicatorSemanticLabel => 'Aktualisieren';

  @override
  String? get remainingTextFieldCharacterCountFew => null;

  @override
  String? get remainingTextFieldCharacterCountMany => null;

  @override
  String? get remainingTextFieldCharacterCountOne => 'Noch 1 Zeichen';

  @override
  String get remainingTextFieldCharacterCountOther => r'Noch $remainingCount Zeichen';

  @override
  String? get remainingTextFieldCharacterCountTwo => null;

  @override
  String? get remainingTextFieldCharacterCountZero => 'TBD';

  @override
  String get reorderItemDown => 'Nach unten verschieben';

  @override
  String get reorderItemLeft => 'Nach links verschieben';

  @override
  String get reorderItemRight => 'Nach rechts verschieben';

  @override
  String get reorderItemToEnd => 'An das Ende verschieben';

  @override
  String get reorderItemToStart => 'An den Anfang verschieben';

  @override
  String get reorderItemUp => 'Nach oben verschieben';

  @override
  String get rowsPerPageTitle => 'Zeilen pro Seite:';

  @override
  String get saveButtonLabel => 'SPEICHERN';

  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;

  @override
  String get searchFieldLabel => 'Suchen';

  @override
  String get selectAllButtonLabel => 'Alle auswählen';

  @override
  String get selectYearSemanticsLabel => 'Jahr auswählen';

  @override
  String? get selectedRowCountTitleFew => null;

  @override
  String? get selectedRowCountTitleMany => null;

  @override
  String? get selectedRowCountTitleOne => '1 Element ausgewählt';

  @override
  String get selectedRowCountTitleOther => r'$selectedRowCount Elemente ausgewählt';

  @override
  String? get selectedRowCountTitleTwo => null;

  @override
  String? get selectedRowCountTitleZero => 'Keine Objekte ausgewählt';

  @override
  String get showAccountsLabel => 'Konten anzeigen';

  @override
  String get showMenuTooltip => 'Menü anzeigen';

  @override
  String get signedInLabel => 'Angemeldet';

  @override
  String get tabLabelRaw => r'Tab $tabIndex von $tabCount';

  @override
  TimeOfDayFormat get timeOfDayFormatRaw => TimeOfDayFormat.HH_colon_mm;

  @override
  String get timePickerDialHelpText => 'UHRZEIT AUSWÄHLEN';

  @override
  String get timePickerHourLabel => 'Stunde';

  @override
  String get timePickerHourModeAnnouncement => 'Stunden auswählen';

  @override
  String get timePickerInputHelpText => 'ZEIT EINGEBEN';

  @override
  String get timePickerMinuteLabel => 'Minute';

  @override
  String get timePickerMinuteModeAnnouncement => 'Minuten auswählen';

  @override
  String get unspecifiedDate => 'Datum';

  @override
  String get unspecifiedDateRange => 'Zeitraum';

  @override
  String get viewLicensesButtonLabel => 'LIZENZEN ANZEIGEN';

  // ***** NEW *****

  @override
  String get keyboardKeyAlt => 'Alt';

  @override
  String get keyboardKeyAltGraph => 'AltGr';

  @override
  String get keyboardKeyBackspace => 'Backspace';

  @override
  String get keyboardKeyCapsLock => 'Caps Lock';

  @override
  String get keyboardKeyChannelDown => 'Kanal Erof';

  @override
  String get keyboardKeyChannelUp => 'Kanal Up';

  @override
  String get keyboardKeyControl => 'Ctrl';

  @override
  String get keyboardKeyDelete => 'Del';

  @override
  String get keyboardKeyEisu => 'Eisū';

  @override
  String get keyboardKeyEject => 'Eject';

  @override
  String get keyboardKeyEnd => 'End';

  @override
  String get keyboardKeyEscape => 'Esc';

  @override
  String get keyboardKeyFn => 'Fn';

  @override
  String get keyboardKeyHangulMode => 'Hangul Mode';

  @override
  String get keyboardKeyHanjaMode => 'Hanja Mode';

  @override
  String get keyboardKeyHankaku => 'Hankaku';

  @override
  String get keyboardKeyHiragana => 'Hiragana';

  @override
  String get keyboardKeyHiraganaKatakana => 'Hiragana Katakana';

  @override
  String get keyboardKeyHome => 'Home';

  @override
  String get keyboardKeyInsert => 'Insert';

  @override
  String get keyboardKeyKanaMode => 'Kana Mode';

  @override
  String get keyboardKeyKanjiMode => 'Kanji Mode';

  @override
  String get keyboardKeyKatakana => 'Katakana';

  @override
  String get keyboardKeyMeta => 'Meta';

  @override
  String get keyboardKeyMetaMacOs => 'Command';

  @override
  String get keyboardKeyMetaWindows => 'Win';

  @override
  String get keyboardKeyNumLock => 'Num Lock';

  @override
  String get keyboardKeyNumpad0 => 'Num 0';

  @override
  String get keyboardKeyNumpad1 => 'Num 1';

  @override
  String get keyboardKeyNumpad2 => 'Num 2';

  @override
  String get keyboardKeyNumpad3 => 'Num 3';

  @override
  String get keyboardKeyNumpad4 => 'Num 4';

  @override
  String get keyboardKeyNumpad5 => 'Num 5';

  @override
  String get keyboardKeyNumpad6 => 'Num 6';

  @override
  String get keyboardKeyNumpad7 => 'Num 7';

  @override
  String get keyboardKeyNumpad8 => 'Num 8';

  @override
  String get keyboardKeyNumpad9 => 'Num 9';

  @override
  String get keyboardKeyNumpadAdd => 'Num +';

  @override
  String get keyboardKeyNumpadComma => 'Num ,';

  @override
  String get keyboardKeyNumpadDecimal => 'Num .';

  @override
  String get keyboardKeyNumpadDivide => 'Num /';

  @override
  String get keyboardKeyNumpadEnter => 'Num Enter';

  @override
  String get keyboardKeyNumpadEqual => 'Num =';

  @override
  String get keyboardKeyNumpadMultiply => 'Num *';

  @override
  String get keyboardKeyNumpadParenLeft => 'Num (';

  @override
  String get keyboardKeyNumpadParenRight => 'Num )';

  @override
  String get keyboardKeyNumpadSubtract => 'Num -';

  @override
  String get keyboardKeyPageDown => 'PgDown';

  @override
  String get keyboardKeyPageUp => 'PgUp';

  @override
  String get keyboardKeyPower => 'Power';

  @override
  String get keyboardKeyPowerOff => 'Power Off';

  @override
  String get keyboardKeyPrintScreen => 'Print Screen';

  @override
  String get keyboardKeyRomaji => 'Romaji';

  @override
  String get keyboardKeyScrollLock => 'Scroll Lock';

  @override
  String get keyboardKeySelect => 'Select';

  @override
  String get keyboardKeySpace => 'Spasie';

  @override
  String get keyboardKeyZenkaku => 'Zenkaku';

  @override
  String get keyboardKeyZenkakuHankaku => 'Zenkaku Hankaku';

  @override
  String aboutListTileTitle(String applicationName) {
    return aboutListTileTitleRaw.replaceFirst("$applicationName", applicationName);
  }

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) {
    // TODO: implement dateRangeEndDateSemanticLabel
    throw UnimplementedError();
  }

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) {
    // TODO: implement dateRangeStartDateSemanticLabel
    throw UnimplementedError();
  }

  @override
  // TODO: implement firstDayOfWeekIndex
  int get firstDayOfWeekIndex => throw UnimplementedError();

  @override
  String formatCompactDate(DateTime date) {
    // TODO: implement formatCompactDate
    throw UnimplementedError();
  }

  @override
  String formatDecimal(int number) {
    // TODO: implement formatDecimal
    throw UnimplementedError();
  }

  @override
  String formatFullDate(DateTime date) {
    // TODO: implement formatFullDate
    throw UnimplementedError();
  }

  @override
  String formatHour(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) {
    // TODO: implement formatHour
    throw UnimplementedError();
  }

  @override
  String formatMediumDate(DateTime date) {
    // TODO: implement formatMediumDate
    throw UnimplementedError();
  }

  @override
  String formatMinute(TimeOfDay timeOfDay) {
    // TODO: implement formatMinute
    throw UnimplementedError();
  }

  @override
  String formatMonthYear(DateTime date) {
    // TODO: implement formatMonthYear
    throw UnimplementedError();
  }

  @override
  String formatShortDate(DateTime date) {
    // TODO: implement formatShortDate
    throw UnimplementedError();
  }

  @override
  String formatShortMonthDay(DateTime date) {
    // TODO: implement formatShortMonthDay
    throw UnimplementedError();
  }

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) {
    // TODO: implement formatTimeOfDay
    throw UnimplementedError();
  }

  @override
  String formatYear(DateTime date) {
    // TODO: implement formatYear
    throw UnimplementedError();
  }

  @override
  String licensesPackageDetailText(int licenseCount) {
    // TODO: implement licensesPackageDetailText
    throw UnimplementedError();
  }

  @override
  // TODO: implement narrowWeekdays
  List<String> get narrowWeekdays => throw UnimplementedError();

  @override
  String pageRowsInfoTitle(int firstRow, int lastRow, int rowCount, bool rowCountIsApproximate) {
    // TODO: implement pageRowsInfoTitle
    throw UnimplementedError();
  }

  @override
  DateTime? parseCompactDate(String? inputString) {
    // TODO: implement parseCompactDate
    throw UnimplementedError();
  }

  @override
  String remainingTextFieldCharacterCount(int remaining) {
    return remaining.toString();
  }

  @override
  String selectedRowCountTitle(int selectedRowCount) {
    return selectedRowCount.toString();
  }

  @override
  String tabLabel({required int tabIndex, required int tabCount}) {
    // TODO: implement tabLabel
    throw UnimplementedError();
  }

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) {
    // TODO: implement timeOfDayFormat
    throw UnimplementedError();
  }
}

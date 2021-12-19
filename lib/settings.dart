import 'dart:collection';
import 'dart:ui';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'opaque.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const TapirGroupsExperiment = "tapir-groups-experiment";
const ServerManagementExperiment = "servers-experiment";
const FileSharingExperiment = "filesharing";
const ImagePreviewsExperiment = "filesharing-images";
const ClickableLinksExperiment = "clickable-links";

enum DualpaneMode {
  Single,
  Dual1to2,
  Dual1to4,
  CopyPortrait,
}

/// Settings govern the *Globally* relevant settings like Locale, Theme and Experiments.
/// We also provide access to the version information here as it is also accessed from the
/// Settings Pane.
class Settings extends ChangeNotifier {
  Locale locale;
  late PackageInfo packageInfo;
  OpaqueThemeType theme;
  // explicitly set experiments to false until told otherwise...
  bool experimentsEnabled = false;
  HashMap<String, bool> experiments = HashMap.identity();
  DualpaneMode _uiColumnModePortrait = DualpaneMode.Single;
  DualpaneMode _uiColumnModeLandscape = DualpaneMode.CopyPortrait;

  bool blockUnknownConnections = false;
  bool streamerMode = false;
  String _downloadPath = "";

  /// Set the dark theme.
  void setDark() {
    theme = OpaqueDark();
    notifyListeners();
  }

  /// Set the Light theme.
  void setLight() {
    theme = OpaqueLight();
    notifyListeners();
  }

  /// Get access to the current theme.
  OpaqueThemeType current() {
    return theme;
  }

  /// isExperimentEnabled can be used to safely check whether a particular
  /// experiment is enabled
  bool isExperimentEnabled(String experiment) {
    if (this.experimentsEnabled) {
      if (this.experiments.containsKey(experiment)) {
        // We now know it cannot be null...
        return this.experiments[experiment]! == true;
      }
    }
    return false;
  }

  /// Called by the event bus. When new settings are loaded from a file the JSON will
  /// be sent to the function and new settings will be instantiated based on the contents.
  handleUpdate(dynamic settings) {
    // Set Theme and notify listeners
    if (settings["Theme"] == "light") {
      this.setLight();
    } else {
      this.setDark();
    }

    // Set Locale and notify listeners
    switchLocale(Locale(settings["Locale"]));

    blockUnknownConnections = settings["BlockUnknownConnections"] ?? false;
    streamerMode = settings["StreamerMode"] ?? false;

    // Decide whether to enable Experiments
    experimentsEnabled = settings["ExperimentsEnabled"] ?? false;

    // Set the internal experiments map. Casting from the Map<dynamic, dynamic> that we get from JSON
    experiments = new HashMap<String, bool>.from(settings["Experiments"]);

    // single pane vs dual pane preferences
    _uiColumnModePortrait = uiColumnModeFromString(settings["UIColumnModePortrait"]);
    _uiColumnModeLandscape = uiColumnModeFromString(settings["UIColumnModeLandscape"]);

    // auto-download folder
    _downloadPath = settings["DownloadPath"] ?? "";

    // Push the experimental settings to Consumers of Settings
    notifyListeners();
  }

  /// Initialize the Package Version information
  initPackageInfo() {
    PackageInfo.fromPlatform().then((PackageInfo newPackageInfo) {
      packageInfo = newPackageInfo;
      notifyListeners();
    });
  }

  /// Switch the Locale of the App
  switchLocale(Locale newLocale) {
    locale = newLocale;
    notifyListeners();
  }

  setStreamerMode(bool newSteamerMode) {
    streamerMode = newSteamerMode;
    notifyListeners();
  }

  /// Block Unknown Connections will autoblock connections if they authenticate with public key not in our contacts list.
  /// This is one of the best tools we have to combat abuse, while it isn't ideal it does allow a user to curate their contacts
  /// list without being bothered by spurious requests (either permanently, or as a short term measure).
  /// Note: This is not an *appear offline* setting which would explicitly close the listen port, rather than simply auto disconnecting unknown attempts.
  forbidUnknownConnections() {
    blockUnknownConnections = true;
    notifyListeners();
  }

  /// Allow Unknown Connections will allow new contact requires from unknown public keys
  /// See above for more information.
  allowUnknownConnections() {
    blockUnknownConnections = false;
    notifyListeners();
  }

  /// Turn Experiments On, this will also have the side effect of enabling any
  /// Experiments that have been previously activated.
  enableExperiments() {
    experimentsEnabled = true;
    notifyListeners();
  }

  /// Turn Experiments Off. This will disable **all** active experiments.
  /// Note: This will not set the preference for individual experiments, if experiments are enabled
  /// any experiments that were active previously will become active again unless they are explicitly disabled.
  disableExperiments() {
    experimentsEnabled = false;
    notifyListeners();
  }

  /// Turn on a specific experiment.
  enableExperiment(String key) {
    experiments.update(key, (value) => true, ifAbsent: () => true);
    notifyListeners();
  }

  /// Turn off a specific experiment
  disableExperiment(String key) {
    experiments.update(key, (value) => false, ifAbsent: () => false);
    notifyListeners();
  }

  DualpaneMode get uiColumnModePortrait => _uiColumnModePortrait;
  set uiColumnModePortrait(DualpaneMode newval) {
    this._uiColumnModePortrait = newval;
    notifyListeners();
  }

  DualpaneMode get uiColumnModeLandscape => _uiColumnModeLandscape;
  set uiColumnModeLandscape(DualpaneMode newval) {
    this._uiColumnModeLandscape = newval;
    notifyListeners();
  }

  List<int> uiColumns(bool isLandscape) {
    var m = (!isLandscape || uiColumnModeLandscape == DualpaneMode.CopyPortrait) ? uiColumnModePortrait : uiColumnModeLandscape;
    switch (m) {
      case DualpaneMode.Single:
        return [1];
      case DualpaneMode.Dual1to2:
        return [1, 2];
      case DualpaneMode.Dual1to4:
        return [1, 4];
    }
    print("impossible column configuration: portrait/$uiColumnModePortrait landscape/$uiColumnModeLandscape");
    return [1];
  }

  static List<DualpaneMode> uiColumnModeOptions(bool isLandscape) {
    if (isLandscape)
      return [
        DualpaneMode.CopyPortrait,
        DualpaneMode.Single,
        DualpaneMode.Dual1to2,
        DualpaneMode.Dual1to4,
      ];
    else
      return [DualpaneMode.Single, DualpaneMode.Dual1to2, DualpaneMode.Dual1to4];
  }

  static DualpaneMode uiColumnModeFromString(String m) {
    switch (m) {
      case "DualpaneMode.Single":
        return DualpaneMode.Single;
      case "DualpaneMode.Dual1to2":
        return DualpaneMode.Dual1to2;
      case "DualpaneMode.Dual1to4":
        return DualpaneMode.Dual1to4;
      case "DualpaneMode.CopyPortrait":
        return DualpaneMode.CopyPortrait;
    }
    print("Error: ui requested translation of column mode [$m] which doesn't exist");
    return DualpaneMode.Single;
  }

  static String uiColumnModeToString(DualpaneMode m, BuildContext context) {
    switch (m) {
      case DualpaneMode.Single:
        return AppLocalizations.of(context)!.settingUIColumnSingle;
      case DualpaneMode.Dual1to2:
        return AppLocalizations.of(context)!.settingUIColumnDouble12Ratio;
      case DualpaneMode.Dual1to4:
        return AppLocalizations.of(context)!.settingUIColumnDouble14Ratio;
      case DualpaneMode.CopyPortrait:
        return AppLocalizations.of(context)!.settingUIColumnOptionSame;
    }
  }

  // checks experiment settings and file extension for image previews
  // (ignores file size; if the user manually accepts the file, assume it's okay to preview)
  bool shouldPreview(String path) {
    var lpath = path.toLowerCase();
    return isExperimentEnabled(ImagePreviewsExperiment) && (
        lpath.endsWith(".jpg") ||
        lpath.endsWith(".jpeg") ||
        lpath.endsWith(".png") ||
        lpath.endsWith(".gif") ||
        lpath.endsWith(".webp") ||
        lpath.endsWith(".bmp")
    );
  }

  String get downloadPath => _downloadPath;
  set downloadPath(String newval) {
    _downloadPath = newval;
    notifyListeners();
  }

  /// Construct a default settings object.
  Settings(this.locale, this.theme);

  /// Convert this Settings object to a JSON representation for serialization on the
  /// event bus.
  dynamic asJson() {
    var themeString = theme.identifier();

    return {
      "Locale": this.locale.languageCode,
      "Theme": themeString,
      "PreviousPid": -1,
      "BlockUnknownConnections": blockUnknownConnections,
      "StreamerMode": streamerMode,
      "ExperimentsEnabled": this.experimentsEnabled,
      "Experiments": experiments,
      "StateRootPane": 0,
      "FirstTime": false,
      "UIColumnModePortrait": uiColumnModePortrait.toString(),
      "UIColumnModeLandscape": uiColumnModeLandscape.toString(),
      "DownloadPath": _downloadPath,
    };
  }
}

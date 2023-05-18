import 'dart:collection';
import 'dart:ui';
import 'dart:core';

import 'package:cwtch/themes/cwtch.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'themes/opaque.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const TapirGroupsExperiment = "tapir-groups-experiment";
const ServerManagementExperiment = "servers-experiment";
const FileSharingExperiment = "filesharing";
const ImagePreviewsExperiment = "filesharing-images";
const ClickableLinksExperiment = "clickable-links";
const FormattingExperiment = "message-formatting";
const QRCodeExperiment = "qrcode-support";
const BlodeuweddExperiment = "blodeuwedd";

enum DualpaneMode {
  Single,
  Dual1to2,
  Dual1to4,
  CopyPortrait,
}

enum NotificationPolicy {
  Mute,
  OptIn,
  DefaultAll,
}

enum NotificationContent {
  SimpleEvent,
  ContactInfo,
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

  NotificationPolicy _notificationPolicy = NotificationPolicy.DefaultAll;
  NotificationContent _notificationContent = NotificationContent.SimpleEvent;

  bool blockUnknownConnections = false;
  bool streamerMode = false;
  String _downloadPath = "";

  bool _allowAdvancedTorConfig = false;
  bool _useCustomTorConfig = false;
  String _customTorConfig = "";
  int _socksPort = -1;
  int _controlPort = -1;
  String _customTorAuth = "";
  bool _useTorCache = false;
  String _torCacheDir = "";
  bool _useSemanticDebugger = false;
  double _fontScaling = 1.0;

  String get torCacheDir => _torCacheDir;

  // Whether to show the profiling interface, not saved
  bool _profileMode = false;

  bool get profileMode => _profileMode;
  set profileMode(bool newval) {
    this._profileMode = newval;
    notifyListeners();
  }

  set useSemanticDebugger(bool newval) {
    this._useSemanticDebugger = newval;
    notifyListeners();
  }

  bool get useSemanticDebugger => _useSemanticDebugger;

  void setTheme(String themeId, String mode) {
    theme = getTheme(themeId, mode);
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

    // allow message formatting to be turned off even when experiments are
    // disabled...
    if (experiment == FormattingExperiment) {
      if (this.experiments.containsKey(FormattingExperiment)) {
        // If message formatting has not explicitly been turned off, then
        // turn it on by default (even when experiments are disabled)
        return this.experiments[experiment]! == true;
      } else {
        return true; // enable by default
      }
    }

    return false;
  }

  /// Called by the event bus. When new settings are loaded from a file the JSON will
  /// be sent to the function and new settings will be instantiated based on the contents.
  handleUpdate(dynamic settings) {
    // Set Theme and notify listeners
    this.setTheme(settings["Theme"], settings["ThemeMode"] ?? mode_dark);

    // Set Locale and notify listeners
    switchLocaleByCode(settings["Locale"]);

    // Decide whether to enable Experiments
    _fontScaling = double.parse(settings["FontScaling"].toString()).clamp(0.5, 2.0);

    blockUnknownConnections = settings["BlockUnknownConnections"] ?? false;
    streamerMode = settings["StreamerMode"] ?? false;

    // Decide whether to enable Experiments
    experimentsEnabled = settings["ExperimentsEnabled"] ?? false;

    // Set the internal experiments map. Casting from the Map<dynamic, dynamic> that we get from JSON
    experiments = new HashMap<String, bool>.from(settings["Experiments"]);

    // single pane vs dual pane preferences
    _uiColumnModePortrait = uiColumnModeFromString(settings["UIColumnModePortrait"]);
    _uiColumnModeLandscape = uiColumnModeFromString(settings["UIColumnModeLandscape"]);
    _notificationPolicy = notificationPolicyFromString(settings["NotificationPolicy"]);

    _notificationContent = notificationContentFromString(settings["NotificationContent"]);

    // auto-download folder
    _downloadPath = settings["DownloadPath"] ?? "";
    _blodeuweddPath = settings["BlodeuweddPath"] ?? "";

    // allow a custom tor config
    _allowAdvancedTorConfig = settings["AllowAdvancedTorConfig"] ?? false;
    _useCustomTorConfig = settings["UseCustomTorrc"] ?? false;
    _customTorConfig = settings["CustomTorrc"] ?? "";
    _socksPort = settings["CustomSocksPort"] ?? -1;
    _controlPort = settings["CustomControlPort"] ?? -1;
    _useTorCache = settings["UseTorCache"] ?? false;
    _torCacheDir = settings["TorCacheDir"] ?? "";

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

  /// Switch the Locale of the App by Language Code
  switchLocaleByCode(String languageCode) {
    var code = languageCode.split("_");
    if (code.length == 1) {
      this.switchLocale(Locale(languageCode));
    } else {
      this.switchLocale(Locale(code[0], code[1]));
    }
  }

  /// Handle Font Scaling
  set fontScaling(double newFontScaling) {
    this._fontScaling = newFontScaling;
    notifyListeners();
  }

  double get fontScaling => _fontScaling;

  // a convenience function to scale fonts dynamically...
  TextStyle scaleFonts(TextStyle input) {
    return input.copyWith(fontSize: (input.fontSize ?? 12) * this.fontScaling);
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

  NotificationPolicy get notificationPolicy => _notificationPolicy;

  set notificationPolicy(NotificationPolicy newpol) {
    this._notificationPolicy = newpol;
    notifyListeners();
  }

  NotificationContent get notificationContent => _notificationContent;

  set notificationContent(NotificationContent newcon) {
    this._notificationContent = newcon;
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

  static NotificationPolicy notificationPolicyFromString(String? np) {
    switch (np) {
      case "NotificationPolicy.Mute":
        return NotificationPolicy.Mute;
      case "NotificationPolicy.OptIn":
        return NotificationPolicy.OptIn;
      case "NotificationPolicy.OptOut":
        return NotificationPolicy.DefaultAll;
    }
    return NotificationPolicy.DefaultAll;
  }

  static NotificationContent notificationContentFromString(String? nc) {
    switch (nc) {
      case "NotificationContent.SimpleEvent":
        return NotificationContent.SimpleEvent;
      case "NotificationContent.ContactInfo":
        return NotificationContent.ContactInfo;
    }
    return NotificationContent.SimpleEvent;
  }

  static String notificationPolicyToString(NotificationPolicy np, BuildContext context) {
    switch (np) {
      case NotificationPolicy.Mute:
        return AppLocalizations.of(context)!.notificationPolicyMute;
      case NotificationPolicy.OptIn:
        return AppLocalizations.of(context)!.notificationPolicyOptIn;
      case NotificationPolicy.DefaultAll:
        return AppLocalizations.of(context)!.notificationPolicyDefaultAll;
    }
  }

  static String notificationContentToString(NotificationContent nc, BuildContext context) {
    switch (nc) {
      case NotificationContent.SimpleEvent:
        return AppLocalizations.of(context)!.notificationContentSimpleEvent;
      case NotificationContent.ContactInfo:
        return AppLocalizations.of(context)!.notificationContentContactInfo;
    }
  }

  // checks experiment settings and file extension for image previews
  // (ignores file size; if the user manually accepts the file, assume it's okay to preview)
  bool shouldPreview(String path) {
    var lpath = path.toLowerCase();
    return isExperimentEnabled(ImagePreviewsExperiment) &&
        (lpath.endsWith(".jpg") || lpath.endsWith(".jpeg") || lpath.endsWith(".png") || lpath.endsWith(".gif") || lpath.endsWith(".webp") || lpath.endsWith(".bmp"));
  }

  String get downloadPath => _downloadPath;

  set downloadPath(String newval) {
    _downloadPath = newval;
    notifyListeners();
  }

  bool get allowAdvancedTorConfig => _allowAdvancedTorConfig;

  set allowAdvancedTorConfig(bool torConfig) {
    _allowAdvancedTorConfig = torConfig;
    notifyListeners();
  }

  bool get useTorCache => _useTorCache;

  set useTorCache(bool useTorCache) {
    _useTorCache = useTorCache;
    notifyListeners();
  }

  // Settings / Gettings for setting the custom tor config..
  String get torConfig => _customTorConfig;

  set torConfig(String torConfig) {
    _customTorConfig = torConfig;
    notifyListeners();
  }

  int get socksPort => _socksPort;

  set socksPort(int newSocksPort) {
    _socksPort = newSocksPort;
    notifyListeners();
  }

  int get controlPort => _controlPort;

  set controlPort(int controlPort) {
    _controlPort = controlPort;
    notifyListeners();
  }

  // Setters / Getters for toggling whether the app should use a custom tor config
  bool get useCustomTorConfig => _useCustomTorConfig;

  set useCustomTorConfig(bool useCustomTorConfig) {
    _useCustomTorConfig = useCustomTorConfig;
    notifyListeners();
  }

  /// Construct a default settings object.
  Settings(this.locale, this.theme);

  String _blodeuweddPath = "";
  String get blodeuweddPath => _blodeuweddPath;
  set blodeuweddPath(String newval) {
    _blodeuweddPath = newval;
    notifyListeners();
  }

  /// Convert this Settings object to a JSON representation for serialization on the
  /// event bus.
  dynamic asJson() {
    return {
      "Locale": this.locale.toString(),
      "Theme": theme.theme,
      "ThemeMode": theme.mode,
      "PreviousPid": -1,
      "BlockUnknownConnections": blockUnknownConnections,
      "NotificationPolicy": _notificationPolicy.toString(),
      "NotificationContent": _notificationContent.toString(),
      "StreamerMode": streamerMode,
      "ExperimentsEnabled": this.experimentsEnabled,
      "Experiments": experiments,
      "StateRootPane": 0,
      "FirstTime": false,
      "UIColumnModePortrait": uiColumnModePortrait.toString(),
      "UIColumnModeLandscape": uiColumnModeLandscape.toString(),
      "DownloadPath": _downloadPath,
      "AllowAdvancedTorConfig": _allowAdvancedTorConfig,
      "CustomTorRc": _customTorConfig,
      "UseCustomTorrc": _useCustomTorConfig,
      "CustomSocksPort": _socksPort,
      "CustomControlPort": _controlPort,
      "CustomAuth": _customTorAuth,
      "UseTorCache": _useTorCache,
      "TorCacheDir": _torCacheDir,
      "BlodeuweddPath": _blodeuweddPath,
      "FontScaling": _fontScaling
    };
  }
}

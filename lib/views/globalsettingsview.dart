import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/themes/juniper.dart';
import 'package:cwtch/widgets/folderpicker.dart';
import 'package:cwtch/themes/cwtch.dart';
import 'package:cwtch/themes/ghost.dart';
import 'package:cwtch/themes/mermaid.dart';
import 'package:cwtch/themes/midnight.dart';
import 'package:cwtch/themes/neon1.dart';
import 'package:cwtch/themes/neon2.dart';
import 'package:cwtch/themes/opaque.dart';
import 'package:cwtch/themes/pumpkin.dart';
import 'package:cwtch/themes/vampire.dart';
import 'package:cwtch/themes/witch.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../config.dart';

/// Global Settings View provides access to modify all the Globally Relevant Settings including Locale, Theme and Experiments.
class GlobalSettingsView extends StatefulWidget {
  @override
  _GlobalSettingsViewState createState() => _GlobalSettingsViewState();
}

class _GlobalSettingsViewState extends State<GlobalSettingsView> {
  static const androidSettingsChannel = const MethodChannel('androidSettings');
  static const androidSettingsChangeChannel = const MethodChannel('androidSettingsChanged');
  bool powerExempt = false;

  ScrollController settingsListScrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    androidSettingsChangeChannel.setMethodCallHandler(handleSettingsChanged);

    if (Platform.isAndroid) {
      isBatteryExempt().then((value) => setState(() {
            powerExempt = value;
          }));
    } else {
      powerExempt = false;
    }
  }

  // Handler on method channel for MainActivity/onActivityResult to report the user choice when we ask for power exemption
  Future<void> handleSettingsChanged(MethodCall call) async {
    if (call.method == "powerExemptionChange") {
      if (call.arguments) {
        setState(() {
          powerExempt = true;
        });
      }
    }
  }

  //* Android Only Requests

  Future<bool> isBatteryExempt() async {
    return await androidSettingsChannel.invokeMethod('isBatteryExempt', {}) ?? false;
  }

  Future<void> requestBatteryExemption() async {
    await androidSettingsChannel.invokeMethod('requestBatteryExemption', {});
    return Future.value();
  }

  //* End Android Only Requests

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cwtchSettingsTitle),
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return Consumer<Settings>(builder: (context, settings, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        var appIcon = Icon(Icons.info, color: settings.current().mainTextColor);
        return Scrollbar(
            key: Key("SettingsView"),
            trackVisibility: true,
            controller: settingsListScrollController,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                controller: settingsListScrollController,
                padding: EdgeInsets.all(20),
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(AppLocalizations.of(context)!.settingsGroupAppearance, style: TextStyle(fontWeight: FontWeight.bold))]),
                      ListTile(
                          title: Text(AppLocalizations.of(context)!.settingLanguage, style: TextStyle(color: settings.current().mainTextColor)),
                          leading: Icon(CwtchIcons.change_language, color: settings.current().mainTextColor),
                          trailing: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              child: DropdownButton(
                                  isExpanded: true,
                                  value: Provider.of<Settings>(context).locale.toString(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      EnvironmentConfig.debugLog("setting language: $newValue");
                                      settings.switchLocaleByCode(newValue!);
                                      saveSettings(context);
                                    });
                                  },
                                  items: AppLocalizations.supportedLocales.map<DropdownMenuItem<String>>((Locale value) {
                                    return DropdownMenuItem<String>(
                                      value: value.toString(),
                                      child: Text(getLanguageFull(context, value.languageCode, value.countryCode)),
                                    );
                                  }).toList()))),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.settingTheme, style: TextStyle(color: settings.current().mainTextColor)),
                        value: settings.current().mode == mode_light,
                        onChanged: (bool value) {
                          if (value) {
                            settings.setTheme(settings.theme.theme, mode_light);
                          } else {
                            settings.setTheme(settings.theme.theme, mode_dark);
                          }

                          // Save Settings...
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonColor,
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                        secondary: Icon(CwtchIcons.change_theme, color: settings.current().mainTextColor),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.themeColorLabel),
                        trailing: Container(
                            width: MediaQuery.of(context).size.width / 4,
                            child: DropdownButton<String>(
                                key: Key("DropdownTheme"),
                                isExpanded: true,
                                value: Provider.of<Settings>(context).theme.theme,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    settings.setTheme(newValue!, settings.theme.mode);
                                    saveSettings(context);
                                  });
                                },
                                items: themes.keys.map<DropdownMenuItem<String>>((String themeId) {
                                  return DropdownMenuItem<String>(
                                    value: themeId,
                                    child: Text(getThemeName(context, themeId)), //"ddi_$themeId", key: Key("ddi_$themeId")),
                                  );
                                }).toList())),
                        leading: Icon(Icons.palette, color: settings.current().mainTextColor),
                      ),
                      ListTile(
                          title: Text(AppLocalizations.of(context)!.settingUIColumnPortrait, style: TextStyle(color: settings.current().mainTextColor)),
                          leading: Icon(Icons.table_chart, color: settings.current().mainTextColor),
                          trailing: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              child: DropdownButton(
                                  isExpanded: true,
                                  value: settings.uiColumnModePortrait.toString(),
                                  onChanged: (String? newValue) {
                                    settings.uiColumnModePortrait = Settings.uiColumnModeFromString(newValue!);
                                    saveSettings(context);
                                  },
                                  items: Settings.uiColumnModeOptions(false).map<DropdownMenuItem<String>>((DualpaneMode value) {
                                    return DropdownMenuItem<String>(
                                      value: value.toString(),
                                      child: Text(Settings.uiColumnModeToString(value, context)),
                                    );
                                  }).toList()))),
                      ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.settingUIColumnLandscape,
                            textWidthBasis: TextWidthBasis.longestLine,
                            softWrap: true,
                            style: TextStyle(color: settings.current().mainTextColor),
                          ),
                          leading: Icon(Icons.stay_primary_landscape, color: settings.current().mainTextColor),
                          trailing: Container(
                              width: MediaQuery.of(context).size.width / 4,
                              child: Container(
                                  width: MediaQuery.of(context).size.width / 4,
                                  child: DropdownButton(
                                      isExpanded: true,
                                      value: settings.uiColumnModeLandscape.toString(),
                                      onChanged: (String? newValue) {
                                        settings.uiColumnModeLandscape = Settings.uiColumnModeFromString(newValue!);
                                        saveSettings(context);
                                      },
                                      items: Settings.uiColumnModeOptions(true).map<DropdownMenuItem<String>>((DualpaneMode value) {
                                        return DropdownMenuItem<String>(
                                          value: value.toString(),
                                          child: Text(
                                            Settings.uiColumnModeToString(value, context),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList())))),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.streamerModeLabel, style: TextStyle(color: settings.current().mainTextColor)),
                        subtitle: Text(AppLocalizations.of(context)!.descriptionStreamerMode),
                        value: settings.streamerMode,
                        onChanged: (bool value) {
                          settings.setStreamerMode(value);
                          // Save Settings...
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonColor,
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                        secondary: Icon(CwtchIcons.streamer_bunnymask, color: settings.current().mainTextColor),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.formattingExperiment, style: TextStyle(color: settings.current().mainTextColor)),
                        subtitle: Text(AppLocalizations.of(context)!.messageFormattingDescription),
                        value: settings.isExperimentEnabled(FormattingExperiment),
                        onChanged: (bool value) {
                          if (value) {
                            settings.enableExperiment(FormattingExperiment);
                          } else {
                            settings.disableExperiment(FormattingExperiment);
                          }
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonActiveColor,
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                        secondary: Icon(Icons.text_fields, color: settings.current().mainTextColor),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(AppLocalizations.of(context)!.settingGroupBehaviour, style: TextStyle(fontWeight: FontWeight.bold))]),
                      Visibility(
                        visible: Platform.isAndroid,
                        child: SwitchListTile(
                          title: Text(AppLocalizations.of(context)!.settingAndroidPowerExemption, style: TextStyle(color: settings.current().mainTextColor)),
                          subtitle: Text(AppLocalizations.of(context)!.settingAndroidPowerExemptionDescription),
                          value: powerExempt,
                          onChanged: (bool value) {
                            if (value) {
                              requestBatteryExemption();
                            } else {
                              // We can't ask for it to be turned off, show an informational popup
                              showBatteryDialog(context);
                            }
                          },
                          activeTrackColor: settings.theme.defaultButtonColor,
                          inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                          secondary: Icon(Icons.power, color: settings.current().mainTextColor),
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.notificationPolicySettingLabel),
                        subtitle: Text(AppLocalizations.of(context)!.notificationPolicySettingDescription),
                        trailing: Container(
                            width: MediaQuery.of(context).size.width / 4,
                            child: DropdownButton(
                                isExpanded: true,
                                value: settings.notificationPolicy,
                                onChanged: (NotificationPolicy? newValue) {
                                  settings.notificationPolicy = newValue!;
                                  saveSettings(context);
                                },
                                items: NotificationPolicy.values.map<DropdownMenuItem<NotificationPolicy>>((NotificationPolicy value) {
                                  return DropdownMenuItem<NotificationPolicy>(
                                    value: value,
                                    child: Text(
                                      Settings.notificationPolicyToString(value, context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList())),
                        leading: Icon(CwtchIcons.chat_bubble_empty_24px, color: settings.current().mainTextColor),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.notificationContentSettingLabel),
                        subtitle: Text(AppLocalizations.of(context)!.notificationContentSettingDescription),
                        trailing: Container(
                            width: MediaQuery.of(context).size.width / 4,
                            child: DropdownButton(
                                isExpanded: true,
                                value: settings.notificationContent,
                                onChanged: (NotificationContent? newValue) {
                                  settings.notificationContent = newValue!;
                                  saveSettings(context);
                                },
                                items: NotificationContent.values.map<DropdownMenuItem<NotificationContent>>((NotificationContent value) {
                                  return DropdownMenuItem<NotificationContent>(
                                    value: value,
                                    child: Text(
                                      Settings.notificationContentToString(value, context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList())),
                        leading: Icon(CwtchIcons.chat_bubble_empty_24px, color: settings.current().mainTextColor),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.blockUnknownLabel, style: TextStyle(color: settings.current().mainTextColor)),
                        subtitle: Text(AppLocalizations.of(context)!.descriptionBlockUnknownConnections),
                        value: settings.blockUnknownConnections,
                        onChanged: (bool value) {
                          if (value) {
                            settings.forbidUnknownConnections();
                          } else {
                            settings.allowUnknownConnections();
                          }

                          // Save Settings...
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonColor,
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                        secondary: Icon(CwtchIcons.block_unknown, color: settings.current().mainTextColor),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(AppLocalizations.of(context)!.settingsGroupExperiments, style: TextStyle(fontWeight: FontWeight.bold))]),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.experimentsEnabled, style: TextStyle(color: settings.current().mainTextColor)),
                        subtitle: Text(AppLocalizations.of(context)!.descriptionExperiments),
                        value: settings.experimentsEnabled,
                        onChanged: (bool value) {
                          if (value) {
                            settings.enableExperiments();
                          } else {
                            settings.disableExperiments();
                          }
                          // Save Settings...
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonColor,
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                        secondary: Icon(CwtchIcons.enable_experiments, color: settings.current().mainTextColor),
                      ),
                      Visibility(
                          visible: settings.experimentsEnabled,
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.enableGroups, style: TextStyle(color: settings.current().mainTextColor)),
                                subtitle: Text(AppLocalizations.of(context)!.descriptionExperimentsGroups),
                                value: settings.isExperimentEnabled(TapirGroupsExperiment),
                                onChanged: (bool value) {
                                  if (value) {
                                    settings.enableExperiment(TapirGroupsExperiment);
                                  } else {
                                    settings.disableExperiment(TapirGroupsExperiment);
                                  }
                                  // Save Settings...
                                  saveSettings(context);
                                },
                                activeTrackColor: settings.theme.defaultButtonColor,
                                inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                secondary: Icon(CwtchIcons.enable_groups, color: settings.current().mainTextColor),
                              ),
                              Visibility(
                                  visible: !Platform.isAndroid && !Platform.isIOS,
                                  child: SwitchListTile(
                                    title: Text(AppLocalizations.of(context)!.settingServers, style: TextStyle(color: settings.current().mainTextColor)),
                                    subtitle: Text(AppLocalizations.of(context)!.settingServersDescription),
                                    value: settings.isExperimentEnabled(ServerManagementExperiment),
                                    onChanged: (bool value) {
                                      Provider.of<ServerListState>(context, listen: false).clear();
                                      if (value) {
                                        settings.enableExperiment(ServerManagementExperiment);
                                      } else {
                                        settings.disableExperiment(ServerManagementExperiment);
                                      }
                                      // Save Settings...
                                      saveSettings(context);
                                    },
                                    activeTrackColor: settings.theme.defaultButtonColor,
                                    inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                    secondary: Icon(CwtchIcons.dns_24px, color: settings.current().mainTextColor),
                                  )),
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.settingFileSharing, style: TextStyle(color: settings.current().mainTextColor)),
                                subtitle: Text(AppLocalizations.of(context)!.descriptionFileSharing),
                                value: settings.isExperimentEnabled(FileSharingExperiment),
                                onChanged: (bool value) {
                                  if (value) {
                                    if (checkDownloadDirectory(context, settings)) {
                                      settings.enableExperiment(FileSharingExperiment);
                                    } else {
                                      settings.enableExperiment(FileSharingExperiment);
                                      settings.disableExperiment(ImagePreviewsExperiment);
                                    }
                                  } else {
                                    settings.disableExperiment(FileSharingExperiment);
                                    settings.disableExperiment(ImagePreviewsExperiment);
                                  }
                                  saveSettings(context);
                                },
                                activeTrackColor: settings.theme.defaultButtonColor,
                                inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                secondary: Icon(CwtchIcons.attached_file_2, color: settings.current().mainTextColor),
                              ),
                              Visibility(
                                visible: settings.isExperimentEnabled(FileSharingExperiment),
                                child: Column(children: [
                                  SwitchListTile(
                                    title: Text(AppLocalizations.of(context)!.settingImagePreviews, style: TextStyle(color: settings.current().mainTextColor)),
                                    subtitle: Text(AppLocalizations.of(context)!.settingImagePreviewsDescription),
                                    value: settings.isExperimentEnabled(ImagePreviewsExperiment),
                                    onChanged: (bool value) {
                                      if (value) {
                                        if (checkDownloadDirectory(context, settings)) {
                                          settings.enableExperiment(ImagePreviewsExperiment);
                                        } else {
                                          settings.disableExperiment(ImagePreviewsExperiment);
                                        }
                                      } else {
                                        settings.disableExperiment(ImagePreviewsExperiment);
                                      }
                                      saveSettings(context);
                                    },
                                    activeTrackColor: settings.theme.defaultButtonActiveColor,
                                    inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                    secondary: Icon(Icons.photo, color: settings.current().mainTextColor),
                                  ),
                                  Visibility(
                                    visible: settings.isExperimentEnabled(ImagePreviewsExperiment) && !Platform.isAndroid,
                                    child: CwtchFolderPicker(
                                      testKey: Key("DownloadFolderPicker"),
                                      label: AppLocalizations.of(context)!.settingDownloadFolder,
                                      initialValue: settings.downloadPath,
                                      description: AppLocalizations.of(context)!.fileSharingSettingsDownloadFolderDescription,
                                      tooltip: AppLocalizations.of(context)!.fileSharingSettingsDownloadFolderTooltip,
                                      onSave: (newVal) {
                                        settings.downloadPath = newVal;
                                        saveSettings(context);
                                      },
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          )),
                      Visibility(
                          visible: settings.experimentsEnabled,
                          child: SwitchListTile(
                            title: Text(AppLocalizations.of(context)!.enableExperimentClickableLinks, style: TextStyle(color: settings.current().mainTextColor)),
                            subtitle: Text(AppLocalizations.of(context)!.experimentClickableLinksDescription),
                            value: settings.isExperimentEnabled(ClickableLinksExperiment),
                            onChanged: (bool value) {
                              if (value) {
                                settings.enableExperiment(ClickableLinksExperiment);
                              } else {
                                settings.disableExperiment(ClickableLinksExperiment);
                              }
                              saveSettings(context);
                            },
                            activeTrackColor: settings.theme.defaultButtonActiveColor,
                            inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                            secondary: Icon(Icons.link, color: settings.current().mainTextColor),
                          )),
                      Visibility(
                          visible: settings.experimentsEnabled,
                          child: SwitchListTile(
                            title: Text(AppLocalizations.of(context)!.enableExperimentQRCode, style: TextStyle(color: settings.current().mainTextColor)),
                            subtitle: Text(AppLocalizations.of(context)!.experimentQRCodeDescription),
                            value: settings.isExperimentEnabled(QRCodeExperiment),
                            onChanged: (bool value) {
                              if (value) {
                                settings.enableExperiment(QRCodeExperiment);
                              } else {
                                settings.disableExperiment(QRCodeExperiment);
                              }
                              saveSettings(context);
                            },
                            activeTrackColor: settings.theme.defaultButtonActiveColor,
                            inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                            secondary: Icon(Icons.qr_code, color: settings.current().mainTextColor),
                          )),
                      AboutListTile(
                          icon: appIcon,
                          applicationIcon: Padding(padding: EdgeInsets.all(5), child: Icon(CwtchIcons.cwtch_knott)),
                          applicationName: "Cwtch (Flutter UI)",
                          applicationLegalese: '\u{a9} 2021 Open Privacy Research Society',
                          aboutBoxChildren: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(24.0 + 10.0 + (appIcon.size ?? 24.0), 16.0, 0.0, 0.0),
                              // About has 24 padding (ln 389) and there appears to be another 10 of padding in the widget
                              child: SelectableText(AppLocalizations.of(context)!.versionBuilddate.replaceAll("%1", EnvironmentConfig.BUILD_VER).replaceAll("%2", EnvironmentConfig.BUILD_DATE)),
                            )
                          ]),
                      Visibility(
                          visible: EnvironmentConfig.BUILD_VER == dev_version && !Platform.isAndroid,
                          child: SwitchListTile(
                            title: Text("Show Semantic Debugger", style: TextStyle(color: settings.current().mainTextColor)),
                            subtitle: Text("Show Accessibility Debugging View"),
                            value: settings.useSemanticDebugger,
                            onChanged: (bool value) {
                              if (value) {
                                settings.useSemanticDebugger = value;
                              } else {
                                settings.useSemanticDebugger = value;
                              }
                              saveSettings(context);
                            },
                            activeTrackColor: settings.theme.defaultButtonActiveColor,
                            inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                            secondary: Icon(Icons.settings_accessibility, color: settings.current().mainTextColor),
                          )),
                      Visibility(
                        visible: EnvironmentConfig.BUILD_VER == dev_version && !Platform.isAndroid,
                        child: FutureBuilder(
                          future: EnvironmentConfig.BUILD_VER != dev_version || Platform.isAndroid ? null : Provider.of<FlwtchState>(context).cwtch.GetDebugInfo(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Column(
                                children: [
                                  Text("libCwtch Debug Info: " + snapshot.data.toString()),
                                  Text("Message Cache Size (Mb): " + (Provider.of<FlwtchState>(context).profs.cacheMemUsage() / (1024 * 1024)).toString())
                                ],
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      )
                    ]))));
      });
    });
  }

  showBatteryDialog(BuildContext context) {
    Widget okButton = ElevatedButton(
      child: Text(AppLocalizations.of(context)!.okButton),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.settingsAndroidPowerReenablePopup),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

bool checkDownloadDirectory(context, settings) {
  bool showError = false;
  if (settings.downloadPath != "") {
  } else {
    // check if the default download path exists
    var path = Provider.of<FlwtchState>(context, listen: false).cwtch.defaultDownloadPath();
    if (path != null) {
      settings.downloadPath = path;
    } else {
      showError = true;
    }
  }

  if (!showError && Directory(settings.downloadPath).existsSync()) {
    return true;
  } else {
    final snackBar = SnackBar(
      content: Text(AppLocalizations.of(context)!.errorDownloadDirectoryDoesNotExist),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return false;
  }
}

/// Construct a version string from Package Info
String constructVersionString(PackageInfo pinfo) {
  if (pinfo == null) {
    return "";
  }
  return pinfo.version + "." + pinfo.buildNumber;
}

/// A slightly verbose way to extract the full language name from
/// an individual language code. There might be a more efficient way of doing this.
String getLanguageFull(context, String languageCode, String? countryCode) {
  if (languageCode == "en") {
    return AppLocalizations.of(context)!.localeEn;
  }
  if (languageCode == "es") {
    return AppLocalizations.of(context)!.localeEs;
  }
  if (languageCode == "fr") {
    return AppLocalizations.of(context)!.localeFr;
  }
  if (languageCode == "pt" && countryCode == "BR") {
    return AppLocalizations.of(context)!.localePtBr;
  }
  if (languageCode == "pt") {
    return AppLocalizations.of(context)!.localePt;
  }
  if (languageCode == "de") {
    return AppLocalizations.of(context)!.localeDe;
  }
  if (languageCode == "el") {
    return AppLocalizations.of(context)!.localeEl;
  }
  if (languageCode == "it") {
    return AppLocalizations.of(context)!.localeIt;
  }
  if (languageCode == "no") {
    return AppLocalizations.of(context)!.localeNo;
  }
  if (languageCode == "pl") {
    return AppLocalizations.of(context)!.localePl;
  }
  if (languageCode == "lb") {
    return AppLocalizations.of(context)!.localeLb;
  }
  if (languageCode == "ru") {
    return AppLocalizations.of(context)!.localeRU;
  }
  if (languageCode == "ro") {
    return AppLocalizations.of(context)!.localeRo;
  }
  if (languageCode == "cy") {
    return AppLocalizations.of(context)!.localeCy;
  }
  if (languageCode == "da") {
    return AppLocalizations.of(context)!.localeDa;
  }
  if (languageCode == "tr") {
    return AppLocalizations.of(context)!.localeTr;
  }
  if (languageCode == "nl") {
    return AppLocalizations.of(context)!.localeNl;
  }
  if (languageCode == "sk") {
    return AppLocalizations.of(context)!.localeSk;
  }
  return languageCode;
}

/// Since we don't seem to able to dynamically pull translations, this function maps themes to their names
String getThemeName(context, String theme) {
  switch (theme) {
    case cwtch_theme:
      return AppLocalizations.of(context)!.themeNameCwtch;
    case ghost_theme:
      return AppLocalizations.of(context)!.themeNameGhost;
    case mermaid_theme:
      return AppLocalizations.of(context)!.themeNameMermaid;
    case midnight_theme:
      return AppLocalizations.of(context)!.themeNameMidnight;
    case neon1_theme:
      return AppLocalizations.of(context)!.themeNameNeon1;
    case neon2_theme:
      return AppLocalizations.of(context)!.themeNameNeon2;
    case pumpkin_theme:
      return AppLocalizations.of(context)!.themeNamePumpkin;
    case vampire_theme:
      return AppLocalizations.of(context)!.themeNameVampire;
    case witch_theme:
      return AppLocalizations.of(context)!.themeNameWitch;
    case juniper_theme:
      return "Juniper"; // Juniper is a noun, and doesn't get subject to translation...
  }
  return theme;
}

/// Send an UpdateGlobalSettings to the Event Bus
saveSettings(context) {
  var settings = Provider.of<Settings>(context, listen: false);
  final updateSettingsEvent = {
    "EventType": "UpdateGlobalSettings",
    "Data": {"Data": jsonEncode(settings.asJson())},
  };
  final updateSettingsEventJson = jsonEncode(updateSettingsEvent);
  Provider.of<FlwtchState>(context, listen: false).cwtch.SendAppEvent(updateSettingsEventJson);
}

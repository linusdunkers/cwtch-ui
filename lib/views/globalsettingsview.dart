import 'dart:convert';
import 'package:cwtch/cwtch_icons_icons.dart';
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
  @override
  void dispose() {
    super.dispose();
  }

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
        var appIcon = Icon(Icons.info, color: settings.current().mainTextColor());
        return Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(children: [
                      ListTile(
                          title: Text(AppLocalizations.of(context)!.settingLanguage, style: TextStyle(color: settings.current().mainTextColor())),
                          leading: Icon(CwtchIcons.change_language, color: settings.current().mainTextColor()),
                          trailing: DropdownButton(
                              value: Provider.of<Settings>(context).locale.languageCode,
                              onChanged: (String? newValue) {
                                setState(() {
                                  settings.switchLocale(Locale(newValue!, ''));
                                  saveSettings(context);
                                });
                              },
                              items: AppLocalizations.supportedLocales.map<DropdownMenuItem<String>>((Locale value) {
                                return DropdownMenuItem<String>(
                                  value: value.languageCode,
                                  child: Text(getLanguageFull(context, value.languageCode)),
                                );
                              }).toList())),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.settingTheme, style: TextStyle(color: settings.current().mainTextColor())),
                        value: settings.current().identifier() == "light",
                        onChanged: (bool value) {
                          if (value) {
                            settings.setLight();
                          } else {
                            settings.setDark();
                          }

                          // Save Settings...
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonActiveColor(),
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                        secondary: Icon(CwtchIcons.change_theme, color: settings.current().mainTextColor()),
                      ),
                      ListTile(
                          title: Text(AppLocalizations.of(context)!.settingUIColumnPortrait, style: TextStyle(color: settings.current().mainTextColor())),
                          leading: Icon(Icons.table_chart, color: settings.current().mainTextColor()),
                          trailing: DropdownButton(
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
                              }).toList())),
                      ListTile(
                          title: Text(
                            AppLocalizations.of(context)!.settingUIColumnLandscape,
                            textWidthBasis: TextWidthBasis.longestLine,
                            softWrap: true,
                            style: TextStyle(color: settings.current().mainTextColor()),
                          ),
                          leading: Icon(Icons.table_chart, color: settings.current().mainTextColor()),
                          trailing: Container(
                              width: 200.0,
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
                                  }).toList()))),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.blockUnknownLabel, style: TextStyle(color: settings.current().mainTextColor())),
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
                        activeTrackColor: settings.theme.defaultButtonActiveColor(),
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                        secondary: Icon(CwtchIcons.block_unknown, color: settings.current().mainTextColor()),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.streamerModeLabel, style: TextStyle(color: settings.current().mainTextColor())),
                        subtitle: Text(AppLocalizations.of(context)!.descriptionStreamerMode),
                        value: settings.streamerMode,
                        onChanged: (bool value) {
                          settings.setStreamerMode(value);
                          // Save Settings...
                          saveSettings(context);
                        },
                        activeTrackColor: settings.theme.defaultButtonActiveColor(),
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                        secondary: Icon(CwtchIcons.block_unknown, color: settings.current().mainTextColor()),
                      ),
                      SwitchListTile(
                        title: Text(AppLocalizations.of(context)!.experimentsEnabled, style: TextStyle(color: settings.current().mainTextColor())),
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
                        activeTrackColor: settings.theme.defaultButtonActiveColor(),
                        inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                        secondary: Icon(CwtchIcons.enable_experiments, color: settings.current().mainTextColor()),
                      ),
                      Visibility(
                          visible: settings.experimentsEnabled,
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.enableGroups, style: TextStyle(color: settings.current().mainTextColor())),
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
                                activeTrackColor: settings.theme.defaultButtonActiveColor(),
                                inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                                secondary: Icon(CwtchIcons.enable_groups, color: settings.current().mainTextColor()),
                              ),
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.settingFileSharing, style: TextStyle(color: settings.current().mainTextColor())),
                                subtitle: Text(AppLocalizations.of(context)!.descriptionFileSharing),
                                value: settings.isExperimentEnabled(FileSharingExperiment),
                                onChanged: (bool value) {
                                  if (value) {
                                    settings.enableExperiment(FileSharingExperiment);
                                  } else {
                                    settings.disableExperiment(FileSharingExperiment);
                                  }
                                  saveSettings(context);
                                },
                                activeTrackColor: settings.theme.defaultButtonActiveColor(),
                                inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                                secondary: Icon(Icons.attach_file, color: settings.current().mainTextColor()),
                              ),
                            ],
                          )),
                      AboutListTile(
                          icon: appIcon,
                          applicationIcon: Padding(padding: EdgeInsets.all(5), child: Icon(CwtchIcons.cwtch_knott)),
                          applicationName: "Cwtch (Flutter UI)",
                          applicationLegalese: '\u{a9} 2021 Open Privacy Research Society',
                          aboutBoxChildren: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  24.0 + 10.0 + (appIcon.size ?? 24.0), 16.0, 0.0, 0.0), // About has 24 padding (ln 389) and there appears to be another 10 of padding in the widget
                              child: SelectableText(AppLocalizations.of(context)!.versionBuilddate.replaceAll("%1", EnvironmentConfig.BUILD_VER).replaceAll("%2", EnvironmentConfig.BUILD_DATE)),
                            )
                          ]),
                    ]))));
      });
    });
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
String getLanguageFull(context, String languageCode) {
  if (languageCode == "en") {
    return AppLocalizations.of(context)!.localeEn;
  }
  if (languageCode == "es") {
    return AppLocalizations.of(context)!.localeEs;
  }
  if (languageCode == "fr") {
    return AppLocalizations.of(context)!.localeFr;
  }
  if (languageCode == "pt") {
    return AppLocalizations.of(context)!.localePt;
  }
  if (languageCode == "de") {
    return AppLocalizations.of(context)!.localeDe;
  }
  if (languageCode == "it") {
    return AppLocalizations.of(context)!.localeIt;
  }
  if (languageCode == "pl") {
    return AppLocalizations.of(context)!.localePl;
  }
  return languageCode;
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

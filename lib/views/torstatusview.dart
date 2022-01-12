import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/torstatus.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import 'globalsettingsview.dart';

/// Tor Status View provides all info on Tor network state and the (future) ability to configure the network in a variety
/// of ways (restart, enable bridges, enable pluggable transports etc)
class TorStatusView extends StatefulWidget {
  @override
  _TorStatusView createState() => _TorStatusView();
}

class _TorStatusView extends State<TorStatusView> {
  TextEditingController torSocksPortController = TextEditingController();
  TextEditingController torControlPortController = TextEditingController();
  TextEditingController torConfigController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.torNetworkStatus),
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return Consumer<Settings>(builder: (
      context,
      settings,
      child,
    ) {
      // We don't want these to update on edit...only on construction...
      if (torSocksPortController.text.isEmpty) {
        torConfigController.text = settings.torConfig;
        torSocksPortController.text = settings.socksPort.toString();
        torControlPortController.text = settings.controlPort.toString();
      }
      return Consumer<TorStatus>(builder: (context, torStatus, child) {
        return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
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
                          leading: TorIcon(),
                          title: Text(AppLocalizations.of(context)!.torStatus),
                          subtitle: Text(torStatus.progress == 100 ? AppLocalizations.of(context)!.networkStatusOnline : torStatus.status),
                          trailing: ElevatedButton(
                            child: Text(AppLocalizations.of(context)!.resetTor),
                            onPressed: () {
                              Provider.of<FlwtchState>(context, listen: false).cwtch.ResetTor();
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(AppLocalizations.of(context)!.torVersion),
                          subtitle: SelectableText(torStatus.version),
                          leading: Icon(CwtchIcons.info_24px, color: settings.current().mainTextColor),
                        ),
                        SwitchListTile(
                          title: Text(AppLocalizations.of(context)!.torSettingsEnabledAdvanced),
                          subtitle: Text(AppLocalizations.of(context)!.torSettingsEnabledAdvancedDescription),
                          value: settings.allowAdvancedTorConfig,
                          onChanged: (bool value) {
                            settings.allowAdvancedTorConfig = value;
                            saveSettings(context);
                          },
                          activeTrackColor: settings.theme.defaultButtonColor,
                          inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                          secondary: Icon(CwtchIcons.settings_24px, color: settings.current().mainTextColor),
                        ),
                        Visibility(
                            visible: settings.allowAdvancedTorConfig,
                            child: Column(children: [
                              ListTile(
                                  title: Text(AppLocalizations.of(context)!.torSettingsCustomSocksPort),
                                  subtitle: Text(AppLocalizations.of(context)!.torSettingsCustomSocksPortDescription),
                                  leading: Icon(CwtchIcons.swap_horiz_24px, color: settings.current().mainTextColor),
                                  trailing: Container(
                                      width: 300,
                                      child: CwtchTextField(
                                        number: true,
                                        controller: torSocksPortController,
                                        validator: (value) {
                                          try {
                                            var port = int.parse(value);
                                            if (port > 0 && port < 65536) {
                                              return null;
                                            } else {
                                              return AppLocalizations.of(context)!.torSettingsErrorSettingPort;
                                            }
                                          } catch (e) {
                                            return AppLocalizations.of(context)!.torSettingsErrorSettingPort;
                                          }
                                        },
                                        onChanged: (String socksPort) {
                                          try {
                                            var port = int.parse(socksPort);
                                            if (port > 0 && port < 65536) {
                                              settings.socksPort = int.parse(socksPort);
                                              saveSettings(context);
                                            }
                                          } catch (e) {}
                                        },
                                      ))),
                              ListTile(
                                  title: Text(AppLocalizations.of(context)!.torSettingsCustomControlPort),
                                  subtitle: Text(AppLocalizations.of(context)!.torSettingsCustomControlPortDescription),
                                  leading: Icon(CwtchIcons.swap_horiz_24px, color: settings.current().mainTextColor),
                                  trailing: Container(
                                      width: 300,
                                      child: CwtchTextField(
                                        number: true,
                                        controller: torControlPortController,
                                        validator: (value) {
                                          try {
                                            var port = int.parse(value);
                                            if (port > 0 && port < 65536) {
                                              return null;
                                            } else {
                                              return AppLocalizations.of(context)!.torSettingsErrorSettingPort;
                                            }
                                          } catch (e) {
                                            return AppLocalizations.of(context)!.torSettingsErrorSettingPort;
                                          }
                                        },
                                        onChanged: (String controlPort) {
                                          try {
                                            var port = int.parse(controlPort);
                                            if (port > 0 && port < 65536) {
                                              settings.controlPort = int.parse(controlPort);
                                              saveSettings(context);
                                            }
                                          } catch (e) {}
                                        },
                                      ))),
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.torSettingsUseCustomTorServiceConfiguration, style: TextStyle(color: settings.current().mainTextColor)),
                                subtitle: Text(AppLocalizations.of(context)!.torSettingsUseCustomTorServiceConfigurastionDescription),
                                value: settings.useCustomTorConfig,
                                onChanged: (bool value) {
                                  settings.useCustomTorConfig = value;
                                  saveSettings(context);
                                },
                                activeTrackColor: settings.theme.defaultButtonColor,
                                inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                secondary: Icon(CwtchIcons.enable_experiments, color: settings.current().mainTextColor),
                              ),
                              Visibility(
                                  visible: settings.useCustomTorConfig,
                                  child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: CwtchTextField(
                                        controller: torConfigController,
                                        multiLine: true,
                                        onChanged: (torConfig) {
                                          settings.torConfig = torConfig;
                                          saveSettings(context);
                                        },
                                      )))
                            ]))
                      ]))));
        });
      });
    });
  }
}

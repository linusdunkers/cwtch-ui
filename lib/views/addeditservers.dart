import 'dart:convert';
import 'package:cwtch/cwtch/cwtch.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:cwtch/widgets/passwordfield.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../errorHandler.dart';
import '../main.dart';
import '../config.dart';

/// Pane to add or edit a server
class AddEditServerView extends StatefulWidget {
  const AddEditServerView();

  @override
  _AddEditServerViewState createState() => _AddEditServerViewState();
}

class _AddEditServerViewState extends State<AddEditServerView> {
  final _formKey = GlobalKey<FormState>();

  final ctrlrDesc = TextEditingController(text: "");
  final ctrlrOldPass = TextEditingController(text: "");
  final ctrlrPass = TextEditingController(text: "");
  final ctrlrPass2 = TextEditingController(text: "");
  final ctrlrOnion = TextEditingController(text: "");

  late bool usePassword;

  @override
  void initState() {
    super.initState();
    var serverInfoState = Provider.of<ServerInfoState>(context, listen: false);
    ctrlrOnion.text = serverInfoState.onion;
    usePassword = serverInfoState.isEncrypted;
    if (serverInfoState.description.isNotEmpty) {
      ctrlrDesc.text = serverInfoState.description;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ctrlrOnion.text.isEmpty ? Text(AppLocalizations.of(context)!.addServerTitle) : Text(AppLocalizations.of(context)!.editServerTitle),
      ),
      body: _buildSettingsList(),
    );
  }

  void _handleSwitchPassword(bool? value) {
    setState(() {
      usePassword = value!;
    });
  }

  Widget _buildSettingsList() {
    return Consumer2<ServerInfoState, Settings>(builder: (context, serverInfoState, settings, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Form(
                        key: _formKey,
                        child: Container(
                            margin: EdgeInsets.fromLTRB(30, 5, 30, 10),
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                              // Onion
                              Visibility(
                                  visible: serverInfoState.onion.isNotEmpty,
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [CwtchLabel(label: AppLocalizations.of(context)!.serverAddress), SelectableText(serverInfoState.onion)])),

                              // Description
                              Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                SizedBox(
                                  height: 20,
                                ),
                                CwtchLabel(label: AppLocalizations.of(context)!.serverDescriptionLabel),
                                Text(AppLocalizations.of(context)!.serverDescriptionDescription),
                                SizedBox(
                                  height: 20,
                                ),
                                CwtchTextField(
                                  controller: ctrlrDesc,
                                  hintText: AppLocalizations.of(context)!.fieldDescriptionLabel,
                                  autofocus: false,
                                )
                              ]),

                              SizedBox(
                                height: 20,
                              ),

                              // Enabled
                              Visibility(
                                  visible: serverInfoState.onion.isNotEmpty,
                                  child: SwitchListTile(
                                    title: Text(AppLocalizations.of(context)!.serverEnabled, style: TextStyle(color: settings.current().mainTextColor)),
                                    subtitle: Text(AppLocalizations.of(context)!.serverEnabledDescription),
                                    value: serverInfoState.running,
                                    onChanged: (bool value) {
                                      serverInfoState.setRunning(value);
                                      if (value) {
                                        Provider.of<FlwtchState>(context, listen: false).cwtch.LaunchServer(serverInfoState.onion);
                                      } else {
                                        Provider.of<FlwtchState>(context, listen: false).cwtch.StopServer(serverInfoState.onion);
                                      }
                                    },
                                    activeTrackColor: settings.theme.defaultButtonColor,
                                    inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                    secondary: Icon(CwtchIcons.negative_heart_24px, color: settings.current().mainTextColor),
                                  )),

                              // Auto start
                              SwitchListTile(
                                title: Text(AppLocalizations.of(context)!.serverAutostartLabel, style: TextStyle(color: settings.current().mainTextColor)),
                                subtitle: Text(AppLocalizations.of(context)!.serverAutostartDescription),
                                value: serverInfoState.autoStart,
                                onChanged: (bool value) {
                                  serverInfoState.setAutostart(value);

                                  if (!serverInfoState.onion.isEmpty) {
                                    Provider.of<FlwtchState>(context, listen: false).cwtch.SetServerAttribute(serverInfoState.onion, "autostart", value ? "true" : "false");
                                  }
                                },
                                activeTrackColor: settings.theme.defaultButtonColor,
                                inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                                secondary: Icon(CwtchIcons.favorite_24dp, color: settings.current().mainTextColor),
                              ),

                              // metrics
                              Visibility(
                                  visible: serverInfoState.onion.isNotEmpty,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(AppLocalizations.of(context)!.serverMetricsLabel, style: Provider.of<FlwtchState>(context).biggerFont),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(AppLocalizations.of(context)!.serverTotalMessagesLabel),
                                      ]),
                                      Text(serverInfoState.totalMessages.toString())
                                    ]),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(AppLocalizations.of(context)!.serverConnectionsLabel),
                                      ]),
                                      Text(serverInfoState.connections.toString())
                                    ]),
                                  ])),

                              // ***** Password *****

                              // use password toggle
                              Visibility(
                                  visible: serverInfoState.onion.isEmpty,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Checkbox(
                                      value: usePassword,
                                      fillColor: MaterialStateProperty.all(settings.current().defaultButtonColor),
                                      activeColor: settings.current().defaultButtonActiveColor,
                                      onChanged: _handleSwitchPassword,
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.radioUsePassword,
                                      style: TextStyle(color: settings.current().mainTextColor),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          usePassword ? AppLocalizations.of(context)!.encryptedServerDescription : AppLocalizations.of(context)!.plainServerDescription,
                                          textAlign: TextAlign.center,
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ])),

                              // current password
                              Visibility(
                                  visible: serverInfoState.onion.isNotEmpty && serverInfoState.isEncrypted,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                    CwtchLabel(label: AppLocalizations.of(context)!.currentPasswordLabel),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    CwtchPasswordField(
                                      controller: ctrlrOldPass,
                                      autoFillHints: [AutofillHints.newPassword],
                                      validator: (value) {
                                        // Password field can be empty when just updating the profile, not on creation
                                        if (serverInfoState.isEncrypted && serverInfoState.onion.isEmpty && value.isEmpty && usePassword) {
                                          return AppLocalizations.of(context)!.passwordErrorEmpty;
                                        }
                                        if (Provider.of<ErrorHandler>(context).deletedServerError == true) {
                                          return AppLocalizations.of(context)!.enterCurrentPasswordForDeleteServer;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ])),

                              // new passwords 1 & 2
                              Visibility(
                                // Currently we don't support password change for servers so also gate this on Add server, when ready to support changing password remove the onion.isEmpty check
                                visible: serverInfoState.onion.isEmpty && usePassword,
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  CwtchLabel(label: AppLocalizations.of(context)!.newPassword),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CwtchPasswordField(
                                    controller: ctrlrPass,
                                    validator: (value) {
                                      // Password field can be empty when just updating the profile, not on creation
                                      if (serverInfoState.onion.isEmpty && value.isEmpty && usePassword) {
                                        return AppLocalizations.of(context)!.passwordErrorEmpty;
                                      }
                                      if (value != ctrlrPass2.value.text) {
                                        return AppLocalizations.of(context)!.passwordErrorMatch;
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CwtchLabel(label: AppLocalizations.of(context)!.password2Label),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CwtchPasswordField(
                                      controller: ctrlrPass2,
                                      validator: (value) {
                                        // Password field can be empty when just updating the profile, not on creation
                                        if (serverInfoState.onion.isEmpty && value.isEmpty && usePassword) {
                                          return AppLocalizations.of(context)!.passwordErrorEmpty;
                                        }
                                        if (value != ctrlrPass.value.text) {
                                          return AppLocalizations.of(context)!.passwordErrorMatch;
                                        }
                                        return null;
                                      }),
                                ]),
                              ),

                              SizedBox(
                                height: 20,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: serverInfoState.onion.isEmpty ? _createPressed : _savePressed,
                                      child: Text(
                                        serverInfoState.onion.isEmpty ? AppLocalizations.of(context)!.addServerTitle : AppLocalizations.of(context)!.saveServerButton,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                  visible: serverInfoState.onion.isNotEmpty,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Tooltip(
                                        message: AppLocalizations.of(context)!.enterCurrentPasswordForDeleteServer,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            showAlertDialog(context);
                                          },
                                          icon: Icon(Icons.delete_forever),
                                          label: Text(AppLocalizations.of(context)!.deleteBtn),
                                        ))
                                  ]))

                              // ***** END Password *****
                            ]))))));
      });
    });
  }

  void _createPressed() {
    // This will run all the validations in the form including
    // checking that display name is not empty, and an actual check that the passwords
    // match (and are provided if the user has requested an encrypted profile).
    if (_formKey.currentState!.validate()) {
      if (usePassword) {
        Provider.of<FlwtchState>(context, listen: false).cwtch.CreateServer(ctrlrPass.value.text, ctrlrDesc.value.text, Provider.of<ServerInfoState>(context, listen: false).autoStart);
      } else {
        Provider.of<FlwtchState>(context, listen: false).cwtch.CreateServer(DefaultPassword, ctrlrDesc.value.text, Provider.of<ServerInfoState>(context, listen: false).autoStart);
      }
      Navigator.of(context).pop();
    }
  }

  void _savePressed() {
    var server = Provider.of<ServerInfoState>(context, listen: false);

    Provider.of<FlwtchState>(context, listen: false).cwtch.SetServerAttribute(server.onion, "description", ctrlrDesc.text);
    server.setDescription(ctrlrDesc.text);

    if (_formKey.currentState!.validate()) {
      // TODO support change password
    }
    Navigator.of(context).pop();
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = ElevatedButton(
        child: Text(AppLocalizations.of(context)!.deleteServerConfirmBtn),
        onPressed: () {
          var onion = Provider.of<ServerInfoState>(context, listen: false).onion;
          Provider.of<FlwtchState>(context, listen: false).cwtch.DeleteServer(onion, Provider.of<ServerInfoState>(context, listen: false).isEncrypted ? ctrlrOldPass.value.text : DefaultPassword);
          Future.delayed(
            const Duration(milliseconds: 500),
            () {
              if (globalErrorHandler.deletedServerSuccess) {
                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.deleteServerSuccess + ":" + onion));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                Navigator.of(context).popUntil((route) => route.settings.name == "servers"); // dismiss dialog
              } else {
                Navigator.of(context).pop();
              }
            },
          );
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.deleteServerConfirmBtn),
      actions: [
        cancelButton,
        continueButton,
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

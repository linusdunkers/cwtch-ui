import 'dart:convert';
import 'dart:ui';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter/services.dart';
import 'package:cwtch/widgets/buttontextfield.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

/// Peer Settings View Provides  way to Configure .
class PeerSettingsView extends StatefulWidget {
  @override
  _PeerSettingsViewState createState() => _PeerSettingsViewState();
}

class _PeerSettingsViewState extends State<PeerSettingsView> {
  @override
  void dispose() {
    super.dispose();
  }

  final ctrlrNick = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    final nickname = Provider.of<ContactInfoState>(context, listen: false).nickname;
    if (nickname.isNotEmpty) {
      ctrlrNick.text = nickname;
    }
  }

  @override
  Widget build(BuildContext context) {
    var handle = Provider.of<ContactInfoState>(context).nickname;
    if (handle.isEmpty) {
      handle = Provider.of<ContactInfoState>(context).onion;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(handle + " " + AppLocalizations.of(context)!.conversationSettings),
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return Consumer<Settings>(builder: (context, settings, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        String? acnCircuit = Provider.of<ContactInfoState>(context).acnCircuit;

        Widget path = Text(Provider.of<ContactInfoState>(context).status);

        if (acnCircuit != null) {
          var hops = acnCircuit.split(",");
          if (hops.length == 3) {
            List<Widget> paths = hops.map((String countryCodeAndIp) {
              var parts = countryCodeAndIp.split(":");
              var country = parts[0];
              var ip = parts[1];
              return RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                      text: country,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: "monospace"),
                      children: [TextSpan(text: " ($ip)", style: TextStyle(fontSize: 8, fontWeight: FontWeight.normal))]));
            }).toList(growable: true);

            paths.add(RichText(text: TextSpan(text: AppLocalizations.of(context)!.labelTorNetwork, style: TextStyle(fontWeight: FontWeight.normal, fontSize: 8, fontFamily: "monospace"))));

            path = Column(
              children: paths,
            );
          }
        }

        return Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(2),
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                            ProfileImage(
                                imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment)
                                    ? Provider.of<ContactInfoState>(context).imagePath
                                    : Provider.of<ContactInfoState>(context).defaultImagePath,
                                diameter: 120,
                                maskOut: false,
                                border: settings.theme.portraitOnlineBorderColor,
                                badgeTextColor: settings.theme.portraitContactBadgeTextColor,
                                badgeColor: settings.theme.portraitContactBadgeColor,
                                badgeEdit: false)
                          ]),

                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            CwtchLabel(label: AppLocalizations.of(context)!.displayNameLabel),
                            SizedBox(
                              height: 20,
                            ),
                            CwtchButtonTextField(
                              controller: ctrlrNick,
                              readonly: false,
                              onPressed: () {
                                var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
                                var conversation = Provider.of<ContactInfoState>(context, listen: false).identifier;
                                Provider.of<ContactInfoState>(context, listen: false).nickname = ctrlrNick.text;
                                Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profileOnion, conversation, "profile.name", ctrlrNick.text);
                                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.nickChangeSuccess));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              },
                              icon: Icon(Icons.save),
                              tooltip: AppLocalizations.of(context)!.saveBtn,
                            )
                          ]),

                          // Address Copy Button
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              height: 20,
                            ),
                            CwtchLabel(label: AppLocalizations.of(context)!.addressLabel),
                            SizedBox(
                              height: 20,
                            ),
                            CwtchButtonTextField(
                              controller: TextEditingController(text: Provider.of<ContactInfoState>(context, listen: false).onion),
                              onPressed: _copyOnion,
                              icon: Icon(Icons.copy),
                              tooltip: AppLocalizations.of(context)!.copyBtn,
                            )
                          ]),
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              height: 20,
                            ),
                            CwtchLabel(label: AppLocalizations.of(context)!.conversationSettings),
                            SizedBox(
                              height: 20,
                            ),
                            ListTile(
                              leading: Icon(CwtchIcons.onion_on, color: settings.current().mainTextColor),
                              isThreeLine: true,
                              title: Text(AppLocalizations.of(context)!.labelACNCircuitInfo),
                              subtitle: Text(AppLocalizations.of(context)!.descriptionACNCircuitInfo),
                              trailing: path,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.blockBtn, style: TextStyle(color: settings.current().mainTextColor)),
                              value: Provider.of<ContactInfoState>(context).isBlocked,
                              onChanged: (bool blocked) {
                                Provider.of<ContactInfoState>(context, listen: false).blocked = blocked;

                                var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
                                var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;

                                if (blocked) {
                                  Provider.of<FlwtchState>(context, listen: false).cwtch.BlockContact(profileOnion, identifier);
                                } else {
                                  Provider.of<FlwtchState>(context, listen: false).cwtch.UnblockContact(profileOnion, identifier);
                                }
                              },
                              activeTrackColor: settings.theme.defaultButtonColor,
                              inactiveTrackColor: settings.theme.defaultButtonDisabledColor,
                              secondary: Icon(CwtchIcons.block_peer, color: settings.current().mainTextColor),
                            ),
                            ListTile(
                                title: Text(AppLocalizations.of(context)!.savePeerHistory, style: TextStyle(color: settings.current().mainTextColor)),
                                subtitle: Text(AppLocalizations.of(context)!.savePeerHistoryDescription),
                                leading: Icon(CwtchIcons.peer_history, color: settings.current().mainTextColor),
                                trailing: DropdownButton(
                                    value: Provider.of<ContactInfoState>(context).savePeerHistory == "DefaultDeleteHistory"
                                        ? AppLocalizations.of(context)!.dontSavePeerHistory
                                        : (Provider.of<ContactInfoState>(context).savePeerHistory == "SaveHistory"
                                            ? AppLocalizations.of(context)!.savePeerHistory
                                            : AppLocalizations.of(context)!.dontSavePeerHistory),
                                    onChanged: (newValue) {
                                      setState(() {
                                        // Set whether or not to dave the Contact History...
                                        var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
                                        var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;
                                        const SaveHistoryKey = "profile.SavePeerHistory";
                                        const SaveHistory = "SaveHistory";
                                        const DelHistory = "DeleteHistoryConfirmed";

                                        if (newValue == AppLocalizations.of(context)!.savePeerHistory) {
                                          Provider.of<ContactInfoState>(context, listen: false).savePeerHistory = SaveHistory;
                                          Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profileOnion, identifier, SaveHistoryKey, SaveHistory);
                                        } else {
                                          Provider.of<ContactInfoState>(context, listen: false).savePeerHistory = DelHistory;
                                          Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profileOnion, identifier, SaveHistoryKey, DelHistory);
                                        }
                                      });
                                    },
                                    items: [AppLocalizations.of(context)!.savePeerHistory, AppLocalizations.of(context)!.dontSavePeerHistory].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList())),
                            ListTile(
                                title: Text(AppLocalizations.of(context)!.conversationNotificationPolicySettingLabel, style: TextStyle(color: settings.current().mainTextColor)),
                                subtitle: Text(AppLocalizations.of(context)!.conversationNotificationPolicySettingDescription),
                                leading: Icon(CwtchIcons.chat_bubble_empty_24px, color: settings.current().mainTextColor),
                                trailing: DropdownButton(
                                  value: Provider.of<ContactInfoState>(context).notificationsPolicy,
                                  items: ConversationNotificationPolicy.values.map<DropdownMenuItem<ConversationNotificationPolicy>>((ConversationNotificationPolicy value) {
                                    return DropdownMenuItem<ConversationNotificationPolicy>(
                                      value: value,
                                      child: Text(value.toName(context)),
                                    );
                                  }).toList(),
                                  onChanged: (ConversationNotificationPolicy? newVal) {
                                    Provider.of<ContactInfoState>(context, listen: false).notificationsPolicy = newVal!;
                                    var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
                                    var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;
                                    const NotificationPolicyKey = "profile.notification-policy";
                                    Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profileOnion, identifier, NotificationPolicyKey, newVal.toString());
                                  },
                                )),
                          ]),
                          Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                            SizedBox(
                              height: 20,
                            ),
                            Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: [
                              Tooltip(
                                  message: AppLocalizations.of(context)!.archiveConversation,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
                                      var handle = Provider.of<ContactInfoState>(context, listen: false).identifier;
                                      // locally update cache...
                                      Provider.of<ContactInfoState>(context, listen: false).isArchived = true;
                                      Provider.of<FlwtchState>(context, listen: false).cwtch.ArchiveConversation(profileOnion, handle);
                                      Future.delayed(Duration(milliseconds: 500), () {
                                        Provider.of<AppState>(context, listen: false).selectedConversation = null;
                                        Navigator.of(context).popUntil((route) => route.settings.name == "conversations"); // dismiss dialog
                                      });
                                    },
                                    icon: Icon(Icons.archive),
                                    label: Text(AppLocalizations.of(context)!.archiveConversation),
                                  ))
                            ]),
                            SizedBox(
                              height: 20,
                            ),
                            Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: [
                              Tooltip(
                                  message: AppLocalizations.of(context)!.leaveConversation,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      showAlertDialog(context);
                                    },
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Provider.of<Settings>(context).theme.backgroundPaneColor), foregroundColor: MaterialStateProperty.all(Provider.of<Settings>(context).theme.mainTextColor)),
                                    icon: Icon(CwtchIcons.leave_group),
                                    label: Text(
                                      AppLocalizations.of(context)!.leaveConversation,
                                      style: TextStyle(decoration: TextDecoration.underline),
                                    ),
                                  ))
                            ])
                          ])
                        ])))));
      });
    });
  }

  void _copyOnion() {
    Clipboard.setData(new ClipboardData(text: Provider.of<ContactInfoState>(context, listen: false).onion));
    final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboardNotification));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = ElevatedButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      child: Text(AppLocalizations.of(context)!.yesLeave),
      onPressed: () {
        var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
        var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;
        // locally update cache...
        Provider.of<ProfileInfoState>(context, listen: false).contactList.removeContact(identifier);
        Provider.of<FlwtchState>(context, listen: false).cwtch.DeleteContact(profileOnion, identifier);
        Future.delayed(Duration(milliseconds: 500), () {
          Provider.of<AppState>(context, listen: false).selectedConversation = null;
          Navigator.of(context).popUntil((route) => route.settings.name == "conversations"); // dismiss dialog
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.reallyLeaveThisGroupPrompt),
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

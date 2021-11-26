import 'dart:convert';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/services.dart';
import 'package:cwtch/model.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<ContactInfoState>(context).onion),
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return Consumer<Settings>(builder: (context, settings, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
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
                            SwitchListTile(
                              title: Text(AppLocalizations.of(context)!.blockBtn, style: TextStyle(color: settings.current().mainTextColor())),
                              value: Provider.of<ContactInfoState>(context).isBlocked,
                              onChanged: (bool blocked) {
                                // Save local blocked status
                                if (blocked) {
                                  Provider.of<ContactInfoState>(context, listen: false).authorization = ContactAuthorization.blocked;
                                } else {
                                  Provider.of<ContactInfoState>(context, listen: false).authorization = ContactAuthorization.unknown;
                                }

                                // Save New peer authorization
                                var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;

                                var onion = Provider.of<ContactInfoState>(context, listen: false).onion;
                                Provider.of<ContactInfoState>(context, listen: false).nickname = ctrlrNick.text;

                                if (blocked) {
                                  final setPeerAttribute = {
                                    "EventType": "UpdatePeerAuthorization",
                                    "Data": {"RemotePeer": onion, "Authorization": "blocked"},
                                  };
                                  final setPeerAttributeJson = jsonEncode(setPeerAttribute);
                                  Provider.of<FlwtchState>(context, listen: false).cwtch.SendProfileEvent(profileOnion, setPeerAttributeJson);
                                } else {
                                  final setPeerAttribute = {
                                    "EventType": "UpdatePeerAuthorization",
                                    "Data": {"RemotePeer": onion, "Authorization": "authorized"},
                                  };
                                  final setPeerAttributeJson = jsonEncode(setPeerAttribute);
                                  Provider.of<FlwtchState>(context, listen: false).cwtch.SendProfileEvent(profileOnion, setPeerAttributeJson);
                                }
                              },
                              activeTrackColor: settings.theme.defaultButtonActiveColor(),
                              inactiveTrackColor: settings.theme.defaultButtonDisabledColor(),
                              secondary: Icon(CwtchIcons.block_peer, color: settings.current().mainTextColor()),
                            ),
                            ListTile(
                                title: Text(AppLocalizations.of(context)!.savePeerHistory, style: TextStyle(color: settings.current().mainTextColor())),
                                subtitle: Text(AppLocalizations.of(context)!.savePeerHistoryDescription),
                                leading: Icon(CwtchIcons.peer_history, color: settings.current().mainTextColor()),
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
                                        var onion = Provider.of<ContactInfoState>(context, listen: false).onion;
                                        const SaveHistoryKey = "SavePeerHistory";

                                        if (newValue == AppLocalizations.of(context)!.savePeerHistory) {
                                          Provider.of<ContactInfoState>(context, listen: false).savePeerHistory = "SaveHistory";
                                          final setPeerAttribute = {
                                            "EventType": "SetPeerAttribute",
                                            "Data": {"RemotePeer": onion, "Key": SaveHistoryKey, "Data": "SaveHistory"},
                                          };
                                          final setPeerAttributeJson = jsonEncode(setPeerAttribute);
                                          Provider.of<FlwtchState>(context, listen: false).cwtch.SendProfileEvent(profileOnion, setPeerAttributeJson);
                                        } else {
                                          Provider.of<ContactInfoState>(context, listen: false).savePeerHistory = "DeleteHistoryConfirmed";
                                          final setPeerAttribute = {
                                            "EventType": "SetPeerAttribute",
                                            "Data": {"RemotePeer": onion, "Key": SaveHistoryKey, "Data": "DeleteHistoryConfirmed"},
                                          };

                                          final setPeerAttributeJson = jsonEncode(setPeerAttribute);
                                          Provider.of<FlwtchState>(context, listen: false).cwtch.SendProfileEvent(profileOnion, setPeerAttributeJson);
                                        }
                                      });
                                    },
                                    items: [AppLocalizations.of(context)!.savePeerHistory, AppLocalizations.of(context)!.dontSavePeerHistory].map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList())),
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
                                    icon: Icon(CwtchIcons.leave_chat),
                                    label: Text(AppLocalizations.of(context)!.archiveConversation),
                                  ))
                            ])
                          ]),
                        ])))));
      });
    });
  }

  void _copyOnion() {
    Clipboard.setData(new ClipboardData(text: Provider.of<ContactInfoState>(context, listen: false).onion));
    final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.copiedClipboardNotification));
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
        var handle = Provider.of<ContactInfoState>(context, listen: false).identifier;
        // locally update cache...
        Provider.of<ContactInfoState>(context, listen: false).isArchived = true;
        Provider.of<FlwtchState>(context, listen: false).cwtch.DeleteContact(profileOnion, handle);
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

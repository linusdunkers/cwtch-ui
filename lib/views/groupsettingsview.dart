import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/profile.dart';
import 'package:flutter/services.dart';
import 'package:cwtch/widgets/buttontextfield.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

/// Group Settings View Provides way to Configure group settings
class GroupSettingsView extends StatefulWidget {
  @override
  _GroupSettingsViewState createState() => _GroupSettingsViewState();
}

class _GroupSettingsViewState extends State<GroupSettingsView> {
  @override
  void dispose() {
    super.dispose();
  }

  final ctrlrNick = TextEditingController(text: "");
  final ctrlrGroupAddr = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    final nickname = Provider.of<ContactInfoState>(context, listen: false).nickname;
    if (nickname.isNotEmpty) {
      ctrlrNick.text = nickname;
    }
    final groupAddr = Provider.of<ContactInfoState>(context, listen: false).onion;
    if (groupAddr.isNotEmpty) {
      ctrlrGroupAddr.text = groupAddr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<ContactInfoState>(context).nickname + " " + AppLocalizations.of(context)!.conversationSettings),
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
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          // Nickname Save Button
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              height: 20,
                            ),
                            CwtchLabel(label: AppLocalizations.of(context)!.displayNameLabel),
                            SizedBox(
                              height: 20,
                            ),
                            CwtchButtonTextField(
                              controller: ctrlrNick,
                              readonly: false,
                              onPressed: () {
                                var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
                                var handle = Provider.of<ContactInfoState>(context, listen: false).identifier;
                                Provider.of<ContactInfoState>(context, listen: false).nickname = ctrlrNick.text;
                                Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profileOnion, handle, "profile.name", ctrlrNick.text);
                                // todo translations
                                final snackBar = SnackBar(content: Text("Group Nickname changed successfully"));
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
                            CwtchLabel(label: AppLocalizations.of(context)!.groupAddr),
                            SizedBox(
                              height: 20,
                            ),
                            CwtchTextField(
                              controller: ctrlrGroupAddr,
                              hintText: '',
                              validator: (value) {},
                            )
                          ]),
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(
                              height: 20,
                            ),
                            CwtchLabel(label: AppLocalizations.of(context)!.server),
                            SizedBox(
                              height: 20,
                            ),
                            CwtchTextField(
                              controller: TextEditingController(text: Provider.of<ContactInfoState>(context, listen: false).server),
                              validator: (value) {},
                              hintText: '',
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
                            // TODO
                          ]),

                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                            SizedBox(
                              height: 20,
                            ),
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
                                )),
                            SizedBox(
                              height: 20,
                            ),
                            Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.end, children: [
                              Tooltip(
                                  message: AppLocalizations.of(context)!.leaveGroup,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      showAlertDialog(context);
                                    },
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
                                    icon: Icon(CwtchIcons.leave_group),
                                    label: Text(
                                      AppLocalizations.of(context)!.leaveGroup,
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
    final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.copiedClipboardNotification));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      child: Text(AppLocalizations.of(context)!.yesLeave),
      onPressed: () {
        var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
        var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;
        // locally update cache...
        Provider.of<ContactInfoState>(context, listen: false).isArchived = true;
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

import 'dart:convert';
import 'dart:io';

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/views/peersettingsview.dart';
import 'package:cwtch/widgets/DropdownContacts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model.dart';
import '../settings.dart';
import '../widgets/messagelist.dart';
import 'groupsettingsview.dart';

class MessageView extends StatefulWidget {
  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final ctrlrCompose = TextEditingController();
  final focusNode = FocusNode();
  String selectedContact = "";

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (Provider.of<ContactInfoState>(context, listen: false).unreadMessages > 0) {
  //     Provider.of<ContactInfoState>(context, listen: false).unreadMessages = 0;
  //   }
  // }

  @override
  void dispose() {
    focusNode.dispose();
    ctrlrCompose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            // setting leading to null makes it do the default behaviour; container() hides it
            leading: Provider.of<Settings>(context).uiColumns(appState.isLandscape(context)).length > 1 ? Container() : null,
            title: Row(children: [
              ProfileImage(
                imagePath: Provider.of<ContactInfoState>(context).imagePath,
                diameter: 42,
                border: Provider.of<Settings>(context).current().portraitOnlineBorderColor(),
                badgeTextColor: Colors.red,
                badgeColor: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Text(Provider.of<ContactInfoState>(context).nickname)
            ]),
            actions: [
              //IconButton(icon: Icon(Icons.chat), onPressed: _pushContactSettings),
              //IconButton(icon: Icon(Icons.list), onPressed: _pushContactSettings),
              //IconButton(icon: Icon(Icons.push_pin), onPressed: _pushContactSettings),
              IconButton(
                  icon: Provider.of<ContactInfoState>(context, listen: false).isGroup == true ? Icon(CwtchIcons.group_settings_24px) : Icon(CwtchIcons.peer_settings_24px),
                  tooltip: AppLocalizations.of(context)!.conversationSettings,
                  onPressed: _pushContactSettings),
            ],
          ),
          body: Padding(padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 108.0), child: MessageList()),
          bottomSheet: _buildComposeBox(),
        ));
  }

  Future<bool> _onWillPop() async {
    Provider.of<ContactInfoState>(context, listen: false).unreadMessages = 0;
    return true;
  }

  void _pushContactSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext bcontext) {
        if (Provider.of<ContactInfoState>(context, listen: false).isGroup == true) {
          return MultiProvider(
            providers: [ChangeNotifierProvider.value(value: Provider.of<ContactInfoState>(context))],
            child: GroupSettingsView(),
          );
        } else {
          return MultiProvider(
            providers: [ChangeNotifierProvider.value(value: Provider.of<ContactInfoState>(context))],
            child: PeerSettingsView(),
          );
        }
      },
    ));
  }

  void _sendMessage([String? ignoredParam]) {
    ChatMessage cm = new ChatMessage(o: 1, d: ctrlrCompose.value.text);
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).onion, jsonEncode(cm));
    _sendMessageHelper();
  }

  void _sendInvitation([String? ignoredParam]) {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .SendInvitation(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).onion, this.selectedContact);
    _sendMessageHelper();
  }

  void _sendMessageHelper() {
    ctrlrCompose.clear();
    focusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 80), () {
      Provider.of<ContactInfoState>(context, listen: false).totalMessages++;
      // Resort the contact list...
      Provider.of<ProfileInfoState>(context, listen: false).contactList.updateLastMessageTime(Provider.of<ContactInfoState>(context, listen: false).onion, DateTime.now());
    });
  }

  Widget _buildComposeBox() {
    return Container(
      color: Provider.of<Settings>(context).theme.backgroundMainColor(),
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      height: 100,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Provider.of<Settings>(context).theme.defaultButtonActiveColor()))),
                child: TextFormField(
                    key: Key('txtCompose'),
                    controller: ctrlrCompose,
                    autofocus: !Platform.isAndroid,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabled: true,
                      prefixIcon: IconButton(
                          icon: Icon(CwtchIcons.send_invite, size: 24, color: Provider.of<Settings>(context).theme.mainTextColor()),
                          tooltip: AppLocalizations.of(context)!.sendInvite,
                          enableFeedback: true,
                          splashColor: Provider.of<Settings>(context).theme.defaultButtonActiveColor(),
                          hoverColor: Provider.of<Settings>(context).theme.defaultButtonActiveColor(),
                          onPressed: () => _modalSendInvitation(context)),
                      suffixIcon: IconButton(
                        icon: Icon(CwtchIcons.send_24px, size: 24, color: Provider.of<Settings>(context).theme.mainTextColor()),
                        tooltip: AppLocalizations.of(context)!.sendMessage,
                        onPressed: _sendMessage,
                      ),
                    ))),
          ),
        ],
      ),
    );
  }

  void placeHolder() => {};

  // explicitly passing BuildContext ctx here is important, change at risk to own health
  // otherwise some Providers will become inaccessible to subwidgets...?
  // https://stackoverflow.com/a/63818697
  void _modalSendInvitation(BuildContext ctx) {
    showModalBottomSheet<void>(
        context: ctx,
        builder: (BuildContext bcontext) {
          return Container(
              height: 200, // bespoke value courtesy of the [TextField] docs
              child: Center(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(AppLocalizations.of(bcontext)!.invitationLabel),
                        SizedBox(
                          height: 20,
                        ),
                        ChangeNotifierProvider.value(
                            value: Provider.of<ProfileInfoState>(ctx, listen: false),
                            child: DropdownContacts(filter: (contact) {
                              return contact.onion != Provider.of<ContactInfoState>(context).onion;
                            }, onChanged: (newVal) {
                              setState(() {
                                this.selectedContact = newVal;
                              });
                            })),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          child: Text(AppLocalizations.of(bcontext)!.inviteBtn, semanticsLabel: AppLocalizations.of(bcontext)!.inviteBtn),
                          onPressed: () {
                            if (this.selectedContact != "") {
                              this._sendInvitation();
                            }
                            Navigator.pop(bcontext);
                          },
                        ),
                      ],
                    )),
              ));
        });
  }
}

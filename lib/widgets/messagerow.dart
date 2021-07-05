import 'dart:convert';

import 'package:cwtch/widgets/quotedmessage.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model.dart';
import '../settings.dart';
import 'invitationbubble.dart';
import 'malformedbubble.dart';
import 'messagebubble.dart';
import 'messageloadingbubble.dart';

class MessageRow extends StatefulWidget {
  MessageRow({Key? key}) : super(key: key);

  @override
  _MessageRowState createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageState>(context).senderOnion == Provider.of<ProfileInfoState>(context).onion;
    var malformed = Provider.of<MessageState>(context).malformed;

    // If the message is malformed then override fromme as we can't trust it
    if (malformed) {
      fromMe = false;
    }

    Widget wdgBubble =
        Flexible(flex: 3, fit: FlexFit.loose, child: Provider.of<MessageState>(context).loaded == true ? widgetForOverlay(Provider.of<MessageState>(context).overlay) : MessageLoadingBubble());
    Widget wdgIcons = IconButton(
        onPressed: () {
          Provider.of<AppState>(context, listen: false).selectedIndex = Provider.of<MessageState>(context).messageIndex;
        },
        icon: Icon(Icons.reply, color: Provider.of<Settings>(context).theme.dropShadowColor()));
    Widget wdgSpacer = Expanded(child: SizedBox(width: 60, height: 10));
    var widgetRow = <Widget>[];

    if (fromMe) {
      widgetRow = <Widget>[
        wdgSpacer,
        wdgIcons,
        wdgBubble,
      ];
    } else {
      var contact = Provider.of<ContactInfoState>(context);
      Widget wdgPortrait = GestureDetector(
          onTap: _btnAdd,
          child: Padding(
              padding: EdgeInsets.all(4.0),
              child: ProfileImage(
                diameter: 48.0,
                imagePath: Provider.of<MessageState>(context).senderImage ?? contact.imagePath,
                //maskOut: contact.status != "Authenticated",
                border: contact.status == "Authenticated" ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor(),
                badgeTextColor: Colors.red, badgeColor: Colors.red,
              )));

      widgetRow = <Widget>[
        wdgPortrait,
        wdgBubble,
        wdgIcons,
        wdgSpacer,
      ];
    }

    return Padding(padding: EdgeInsets.all(2), child: Row(mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start, children: widgetRow));
  }

  Widget widgetForOverlay(int o) {
    switch (o) {
      case 1:
        return MessageBubble();
      case 100:
      case 101:
        return InvitationBubble();
      case 10:
        return QuotedMessageBubble();
    }
    return MalformedBubble();
  }

  void _btnAdd() {
    var sender = Provider.of<MessageState>(context, listen: false).senderOnion;
    if (sender == null || sender == "") {
      print("sender not yet loaded");
      return;
    }

    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    final setPeerAttribute = {
      "EventType": "AddContact",
      "Data": {"ImportString": sender},
    };
    final setPeerAttributeJson = jsonEncode(setPeerAttribute);
    Provider.of<FlwtchState>(context, listen: false).cwtch.SendProfileEvent(profileOnion, setPeerAttributeJson);

    final snackBar = SnackBar(
      content: Text(AppLocalizations.of(context)!.successfullAddedContact),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

import 'dart:convert';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/views/contactsview.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model.dart';
import '../settings.dart';

class MessageRow extends StatefulWidget {
  final Widget child;
  MessageRow(this.child, {Key? key}) : super(key: key);

  @override
  MessageRowState createState() => MessageRowState();
}

class MessageRowState extends State<MessageRow> {
  bool showMenu = false;

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var isContact = Provider.of<ContactListState>(context).getContact(Provider.of<MessageMetadata>(context).senderHandle) != null;

    var senderDisplayStr = "";
    if (!fromMe) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = Provider.of<MessageMetadata>(context).senderHandle;
      }
    }

    Widget wdgIcons = Visibility(
        visible: this.showMenu,
        maintainSize: true,
        child: IconButton(
            tooltip: AppLocalizations.of(context)!.tooltipReplyToThisMessage,
            onPressed: () {
              Provider.of<AppState>(context, listen: false).selectedIndex = Provider.of<MessageMetadata>(context).messageIndex;
            },
            icon: Icon(Icons.reply, color: Provider.of<Settings>(context).theme.dropShadowColor())));
    Widget wdgSpacer = Expanded(child: SizedBox(width: 60, height: 10));
    var widgetRow = <Widget>[];

    if (fromMe) {
      widgetRow = <Widget>[
        wdgSpacer,
        wdgIcons,
        Flexible(flex: 3, fit: FlexFit.loose, child: widget.child),
      ];
    } else {
      var contact = Provider.of<ContactInfoState>(context);
      Widget wdgPortrait = GestureDetector(
          onTap: isContact ? _btnGoto : _btnAdd,
          child: Padding(
              padding: EdgeInsets.all(4.0),
              child: ProfileImage(
                diameter: 48.0,
                imagePath: Provider.of<MessageMetadata>(context).senderImage ?? contact.imagePath,
                //maskOut: contact.status != "Authenticated",
                border: contact.status == "Authenticated" ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor(),
                badgeTextColor: Colors.red, badgeColor: Colors.red,
                tooltip: isContact ? AppLocalizations.of(context)!.contactGoto.replaceFirst("%1", senderDisplayStr) : AppLocalizations.of(context)!.addContact,
              )));

      widgetRow = <Widget>[
        wdgPortrait,
        Flexible(flex: 3, fit: FlexFit.loose, child: widget.child),
        wdgIcons,
        wdgSpacer,
      ];
    }

    return MouseRegion(
        // For desktop...

        onHover: (event) {
          setState(() {
            this.showMenu = true;
          });
        },
        onExit: (event) {
          setState(() {
            this.showMenu = false;
          });
        },
        child: GestureDetector(

            // Swipe to quote
            onHorizontalDragEnd: (details) {
              Provider.of<AppState>(context, listen: false).selectedIndex = Provider.of<MessageMetadata>(context, listen: false).messageIndex;
            },
            child: Padding(padding: EdgeInsets.all(2), child: Row(mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start, children: widgetRow))));
  }

  void _btnGoto() {
    selectConversation(context, Provider.of<MessageMetadata>(context, listen: false).senderHandle);
  }

  void _btnAdd() {
    var sender = Provider.of<MessageMetadata>(context, listen: false).senderHandle;
    if (sender == null || sender == "") {
      print("sender not yet loaded");
      return;
    }
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;

    showAddContactConfirmAlertDialog(context, profileOnion, sender);
  }

  showAddContactConfirmAlertDialog(BuildContext context, String profileOnion, String senderOnion) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = TextButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      child: Text(AppLocalizations.of(context)!.addContact),
      onPressed: () {
        Provider.of<FlwtchState>(context, listen: false).cwtch.ImportBundle(profileOnion, senderOnion);
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.successfullAddedContact),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.addContactConfirm.replaceFirst("%1", senderOnion)),
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

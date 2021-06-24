import 'dart:convert';

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

// Like MessageBubble but for displaying chat overlay 100/101 invitations
// Offers the user an accept/reject button if they don't have a matching contact already
class InvitationBubble extends StatefulWidget {
  @override
  InvitationBubbleState createState() => InvitationBubbleState();
}

class InvitationBubbleState extends State<InvitationBubble> {
  bool rejected = false;
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    if (Provider.of<MessageState>(context).malformed) {
      return MalformedBubble();
    }

    var fromMe = Provider.of<MessageState>(context).senderOnion == Provider.of<ProfileInfoState>(context).onion;
    var isGroup = Provider.of<MessageState>(context).overlay == 101;
    isAccepted = Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageState>(context).inviteTarget) != null;
    var prettyDate = "";
    var borderRadiousEh = 15.0;
    var showGroupInvite = Provider.of<Settings>(context).isExperimentEnabled(TapirGroupsExperiment);
    rejected = Provider.of<MessageState>(context).flags & 0x01 == 0x01;
    var myKey = Provider.of<MessageState>(context).profileOnion + "::" + Provider.of<MessageState>(context).contactHandle + "::" + Provider.of<MessageState>(context).messageIndex.toString();

    if (Provider.of<MessageState>(context).timestamp != null) {
      // user-configurable timestamps prolly ideal? #todo
      prettyDate = DateFormat.yMd().add_jm().format(Provider.of<MessageState>(context).timestamp);
    }

    // If the sender is not us, then we want to give them a nickname...
    var senderDisplayStr = "";
    if (!fromMe && Provider.of<MessageState>(context).senderOnion != null) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageState>(context).senderOnion);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = Provider.of<MessageState>(context).senderOnion;
      }
    }

    var wdgSender = Center(
        widthFactor: 1,
        child: SelectableText(senderDisplayStr + '\u202F',
            style: TextStyle(fontSize: 9.0, color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor())));

    // If we receive an invite for ourselves, treat it as a bug. The UI no longer allows this so it could have only come from
    // some kind of malfeasance.
    var selfInvite = Provider.of<MessageState>(context).inviteNick == Provider.of<ProfileInfoState>(context).onion;
    if (selfInvite) {
      return MalformedBubble();
    }

    var wdgMessage = isGroup && !showGroupInvite ?
          Text(AppLocalizations.of(context)!.groupInviteSettingsWarning) :
          fromMe
        ? senderInviteChrome(AppLocalizations.of(context)!.sendAnInvitation,
            isGroup ? Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageState>(context).inviteTarget)!.nickname : Provider.of<MessageState>(context).message, myKey)
        : (inviteChrome(isGroup ? AppLocalizations.of(context)!.inviteToGroup : AppLocalizations.of(context)!.contactSuggestion, Provider.of<MessageState>(context).inviteNick,
            Provider.of<MessageState>(context).inviteTarget, myKey));

    Widget wdgDecorations;
    if (isGroup && !showGroupInvite) {
      wdgDecorations = Text('\u202F');
    } else  if (fromMe) {
      wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageState>(context).ackd, errored: Provider.of<MessageState>(context).error, fromMe: fromMe, prettyDate: prettyDate);
    } else if (isAccepted) {
      wdgDecorations = Text(AppLocalizations.of(context)!.accepted + '\u202F');
    } else if (this.rejected) {
      wdgDecorations = Text(AppLocalizations.of(context)!.rejected + '\u202F');
    } else {
      wdgDecorations = Center(
          widthFactor: 1,
          child: Wrap(children: [
            Padding(padding: EdgeInsets.all(5), child: TextButton(child: Text(AppLocalizations.of(context)!.rejectGroupBtn + '\u202F'), onPressed: _btnReject)),
            Padding(padding: EdgeInsets.all(5), child: TextButton(child: Text(AppLocalizations.of(context)!.acceptGroupBtn + '\u202F'), onPressed: _btnAccept)),
          ]));
    }

    return LayoutBuilder(builder: (context, constraints) {
      //print(constraints.toString()+", "+constraints.maxWidth.toString());
      return Center(
          widthFactor: 1.0,
          child: Container(
              decoration: BoxDecoration(
                color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor() : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor(),
                border:
                    Border.all(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor() : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor(), width: 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadiousEh),
                  topRight: Radius.circular(borderRadiousEh),
                  bottomLeft: fromMe ? Radius.circular(borderRadiousEh) : Radius.zero,
                  bottomRight: fromMe ? Radius.zero : Radius.circular(borderRadiousEh),
                ),
              ),
              child: Center(
                  widthFactor: 1.0,
                  child: Padding(
                      padding: EdgeInsets.all(9.0),
                      child: Wrap(runAlignment: WrapAlignment.spaceEvenly, alignment: WrapAlignment.spaceEvenly, runSpacing: 1.0, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        Center(widthFactor: 1, child: Padding(padding: EdgeInsets.all(10.0), child: Icon(isGroup && !showGroupInvite ? CwtchIcons.enable_experiments :  CwtchIcons.send_invite, size: 32))),
                        Center(
                          widthFactor: 1.0,
                          child: Column(
                              crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: fromMe ? [wdgMessage, wdgDecorations] : [wdgSender, wdgMessage, wdgDecorations]),
                        )
                      ])))));
    });
  }

  void _btnReject() {
    setState(() {
      var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
      var contact = Provider.of<ContactInfoState>(context, listen: false).onion;
      var idx = Provider.of<MessageState>(context, listen: false).messageIndex;
      Provider.of<FlwtchState>(context, listen: false).cwtch.UpdateMessageFlags(profileOnion, contact, idx, Provider.of<MessageState>(context, listen: false).flags | 0x01);
      Provider.of<MessageState>(context).flags |= 0x01;
    });
  }

  void _btnAccept() {
    setState(() {
      var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
      Provider.of<FlwtchState>(context, listen: false).cwtch.ImportBundle(profileOnion, Provider.of<MessageState>(context, listen: false).message);
      isAccepted = true;
    });
  }

  // Construct an invite chrome for the sender
  Widget senderInviteChrome(String chrome, String targetName, String myKey) {
    return Wrap(children: [
      SelectableText(
        chrome + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        targetName + '\u202F',
        key: Key(myKey),
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor(),
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      )
    ]);
  }

  // Construct an invite chrome
  Widget inviteChrome(String chrome, String targetName, String targetId, String myKey) {
    return Wrap(children: [
      SelectableText(
        chrome + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
        ),
        textAlign: TextAlign.left,
        textWidthBasis: TextWidthBasis.longestLine,
        maxLines: 2,
      ),
      SelectableText(
        targetName + '\u202F',
        key: Key(myKey),
        style: TextStyle(color: Provider.of<Settings>(context).theme.messageFromOtherTextColor()),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      )
    ]);
  }
}

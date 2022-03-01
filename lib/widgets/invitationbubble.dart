import 'dart:convert';
import 'dart:io';

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

// Like MessageBubble but for displaying chat overlay 100/101 invitations
// Offers the user an accept/reject button if they don't have a matching contact already
class InvitationBubble extends StatefulWidget {
  final int overlay;
  final String inviteTarget;
  final String inviteNick;
  final String invite;

  InvitationBubble(this.overlay, this.inviteTarget, this.inviteNick, this.invite);

  @override
  InvitationBubbleState createState() => InvitationBubbleState();
}

class InvitationBubbleState extends State<InvitationBubble> {
  bool rejected = false;
  bool isAccepted = false;

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var isGroup = widget.overlay == InviteGroupOverlay;
    isAccepted = Provider.of<ProfileInfoState>(context).contactList.findContact(widget.inviteTarget) != null;
    var borderRadiousEh = 15.0;
    var showGroupInvite = Provider.of<Settings>(context).isExperimentEnabled(TapirGroupsExperiment);
    rejected = Provider.of<MessageMetadata>(context).attributes["rejected-invite"] == "true";
    DateTime messageDate = Provider.of<MessageMetadata>(context).timestamp;

    // If the sender is not us, then we want to give them a nickname...
    var senderDisplayStr = "";
    if (!fromMe) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = Provider.of<MessageMetadata>(context).senderHandle;
      }
    }

    var wdgSender = Center(
        widthFactor: 1,
        child: SelectableText(senderDisplayStr + '\u202F',
            style: TextStyle(fontSize: 9.0, color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor)));

    // If we receive an invite for ourselves, treat it as a bug. The UI no longer allows this so it could have only come from
    // some kind of malfeasance.
    var selfInvite = widget.inviteNick == Provider.of<ProfileInfoState>(context).onion;
    if (selfInvite) {
      return MalformedBubble();
    }

    var wdgMessage = isGroup && !showGroupInvite
        ? Text(AppLocalizations.of(context)!.groupInviteSettingsWarning)
        : fromMe
            ? senderInviteChrome(
                AppLocalizations.of(context)!.sendAnInvitation, isGroup ? Provider.of<ProfileInfoState>(context).contactList.findContact(widget.inviteTarget)!.nickname : widget.inviteTarget)
            : (inviteChrome(isGroup ? AppLocalizations.of(context)!.inviteToGroup : AppLocalizations.of(context)!.contactSuggestion, widget.inviteNick, widget.inviteTarget));

    Widget wdgDecorations;
    if (isGroup && !showGroupInvite) {
      wdgDecorations = Text('\u202F');
    } else if (fromMe) {
      wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, messageDate: messageDate);
    } else if (isAccepted) {
      wdgDecorations = Text(AppLocalizations.of(context)!.accepted + '\u202F');
    } else if (this.rejected) {
      wdgDecorations = Text(AppLocalizations.of(context)!.rejected + '\u202F');
    } else {
      wdgDecorations = Center(
          widthFactor: 1,
          child: Wrap(children: [
            Padding(padding: EdgeInsets.all(5), child: ElevatedButton(child: Text(AppLocalizations.of(context)!.rejectGroupBtn + '\u202F'), onPressed: _btnReject)),
            Padding(padding: EdgeInsets.all(5), child: ElevatedButton(child: Text(AppLocalizations.of(context)!.acceptGroupBtn + '\u202F'), onPressed: _btnAccept)),
          ]));
    }

    return LayoutBuilder(builder: (context, constraints) {
      //print(constraints.toString()+", "+constraints.maxWidth.toString());
      return Center(
          widthFactor: 1.0,
          child: Container(
              decoration: BoxDecoration(
                color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor,
                border: Border.all(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor, width: 1),
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
                        Center(
                            widthFactor: 1, child: Padding(padding: EdgeInsets.all(10.0), child: Icon(isGroup && !showGroupInvite ? CwtchIcons.enable_experiments : CwtchIcons.send_invite, size: 32))),
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
      var conversation = Provider.of<ContactInfoState>(context, listen: false).identifier;
      var idx = Provider.of<MessageMetadata>(context, listen: false).messageID;
      Provider.of<FlwtchState>(context, listen: false).cwtch.SetMessageAttribute(profileOnion, conversation, 0, idx, "rejected-invite", "true");
      //Provider.of<MessageMetadata>(context, listen: false).flags |= 0x01;
    });
  }

  void _btnAccept() {
    setState(() {
      var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
      Provider.of<FlwtchState>(context, listen: false).cwtch.ImportBundle(profileOnion, widget.invite);
      isAccepted = true;
    });
  }

  // Construct an invite chrome for the sender
  Widget senderInviteChrome(String chrome, String targetName) {
    return Wrap(children: [
      SelectableText(
        chrome + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
      SelectableText(
        targetName + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
        ),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      )
    ]);
  }

  // Construct an invite chrome
  Widget inviteChrome(String chrome, String targetName, String targetId) {
    return Wrap(children: [
      SelectableText(
        chrome + '\u202F',
        style: TextStyle(
          color: Provider.of<Settings>(context).theme.messageFromOtherTextColor,
        ),
        textAlign: TextAlign.left,
        textWidthBasis: TextWidthBasis.longestLine,
        maxLines: 2,
      ),
      SelectableText(
        targetName + '\u202F',
        style: TextStyle(color: Provider.of<Settings>(context).theme.messageFromOtherTextColor),
        textAlign: TextAlign.left,
        maxLines: 2,
        textWidthBasis: TextWidthBasis.longestLine,
      )
    ]);
  }
}

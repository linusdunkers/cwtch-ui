import 'dart:convert';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/invitationbubble.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messagerow.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../model.dart';

class InviteMessage extends Message {
  final MessageMetadata metadata;
  final String content;
  final int overlay;

  InviteMessage(this.overlay, this.metadata, this.content);

  @override
  Widget getWidget(BuildContext context, Key key) {
    return ChangeNotifierProvider.value(
        key: key,
        value: this.metadata,
        builder: (bcontext, child) {
          String inviteTarget;
          String inviteNick;
          String invite = this.content;

          if (this.content.length == TorV3ContactHandleLength) {
            inviteTarget = this.content;
            var targetContact = Provider.of<ProfileInfoState>(context).contactList.findContact(inviteTarget);
            inviteNick = targetContact == null ? this.content : targetContact.nickname;
          } else {
            var parts = this.content.toString().split("||");
            if (parts.length == 2) {
              var jsonObj = jsonDecode(utf8.fuse(base64).decode(parts[1].substring(5)));
              inviteTarget = jsonObj['GroupID'];
              inviteNick = jsonObj['GroupName'];
            } else {
              return MessageRow(MalformedBubble());
            }
          }
          var lrt = Provider.of<ContactInfoState>(bcontext).lastMessageTime;
          return MessageRow(InvitationBubble(overlay, inviteTarget, inviteNick, invite));
        });
  }

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          String inviteTarget;
          String inviteNick;
          String invite = this.content;
          if (this.content.length == TorV3ContactHandleLength) {
            inviteTarget = this.content;
            var targetContact = Provider.of<ProfileInfoState>(context).contactList.findContact(inviteTarget);
            inviteNick = targetContact == null ? this.content : targetContact.nickname;
          } else {
            var parts = this.content.toString().split("||");
            if (parts.length == 2) {
              var jsonObj = jsonDecode(utf8.fuse(base64).decode(parts[1].substring(5)));
              inviteTarget = jsonObj['GroupID'];
              inviteNick = jsonObj['GroupName'];
            } else {
              return MalformedBubble();
            }
          }
          return InvitationBubble(overlay, inviteTarget, inviteNick, invite);
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }
}

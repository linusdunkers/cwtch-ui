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
  Widget getWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          String idx = Provider.of<ContactInfoState>(context).isGroup == true && this.metadata.signature != null ? this.metadata.signature! : this.metadata.messageIndex.toString();

          String inviteTarget;
          String inviteNick;

          if (this.content.length == TorV3ContactHandleLength) {
            inviteTarget = this.content;
            var targetContact = Provider.of<ProfileInfoState>(context).contactList.getContact(inviteTarget);
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
          return MessageRow(InvitationBubble(overlay, inviteTarget, inviteNick), key: Provider.of<ContactInfoState>(bcontext).getMessageKey(idx));
        });
  }

  @override
  Widget getPreviewWidget(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: this.metadata,
        builder: (bcontext, child) {
          String inviteTarget;
          String inviteNick;

          if (this.content.length == TorV3ContactHandleLength) {
            inviteTarget = this.content;
            var targetContact = Provider.of<ProfileInfoState>(context).contactList.getContact(inviteTarget);
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
          return InvitationBubble(overlay, inviteTarget, inviteNick);
        });
  }

  @override
  MessageMetadata getMetadata() {
    return this.metadata;
  }
}

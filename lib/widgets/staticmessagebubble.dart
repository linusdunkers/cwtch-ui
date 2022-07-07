import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

class StaticMessageBubble extends StatefulWidget {
  final ProfileInfoState profile;
  final Settings settings;
  final MessageMetadata metadata;
  final Widget child;

  StaticMessageBubble(this.profile, this.settings, this.metadata, this.child);

  @override
  StaticMessageBubbleState createState() => StaticMessageBubbleState();
}

class StaticMessageBubbleState extends State<StaticMessageBubble> {
  @override
  Widget build(BuildContext context) {
    var fromMe = widget.metadata.senderHandle == widget.profile.onion;
    var borderRadiousEh = 15.0;
    DateTime messageDate = widget.metadata.timestamp;

    // If the sender is not us, then we want to give them a nickname...
    var senderDisplayStr = "";
    if (!fromMe) {
      ContactInfoState? contact = widget.profile.contactList.findContact(widget.metadata.senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = widget.metadata.senderHandle;
      }
    } else {
      senderDisplayStr = widget.profile.nickname;
    }

    var wdgSender = SelectableText(senderDisplayStr, style: TextStyle(fontSize: 9.0, color: fromMe ? widget.settings.theme.messageFromMeTextColor : widget.settings.theme.messageFromOtherTextColor));

    var wdgDecorations = MessageBubbleDecoration(ackd: widget.metadata.ackd, errored: widget.metadata.error, fromMe: fromMe, messageDate: messageDate);

    var error = widget.metadata.error;

    return LayoutBuilder(builder: (context, constraints) {
      //print(constraints.toString()+", "+constraints.maxWidth.toString());
      return RepaintBoundary(
          child: Container(
              child: Container(
                  decoration: BoxDecoration(
                    color: error ? malformedColor : (fromMe ? widget.settings.theme.messageFromMeBackgroundColor : widget.settings.theme.messageFromOtherBackgroundColor),
                    border: Border.all(color: error ? malformedColor : (fromMe ? widget.settings.theme.messageFromMeBackgroundColor : widget.settings.theme.messageFromOtherBackgroundColor), width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadiousEh),
                      topRight: Radius.circular(borderRadiousEh),
                      bottomLeft:  Radius.zero,
                      bottomRight: Radius.circular(borderRadiousEh),
                    ),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(9.0),
                      child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [wdgSender, widget.child, wdgDecorations])))));
    });
  }
}

import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model.dart';
import 'package:intl/intl.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

class MessageBubble extends StatefulWidget {
  final String content;

  MessageBubble(this.content);

  @override
  MessageBubbleState createState() => MessageBubbleState();
}

class MessageBubbleState extends State<MessageBubble> {
  FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var prettyDate = "";
    var borderRadiousEh = 15.0;
    // var myKey = Provider.of<MessageState>(context).profileOnion + "::" + Provider.of<MessageState>(context).contactHandle + "::" + Provider.of<MessageState>(context).messageIndex.toString();

    DateTime messageDate = Provider.of<MessageMetadata>(context).timestamp;
    prettyDate = DateFormat.yMd().add_jm().format(messageDate.toLocal());

    // If the sender is not us, then we want to give them a nickname...
    var senderDisplayStr = "";
    if (!fromMe) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = Provider.of<MessageMetadata>(context).senderHandle;
      }
    }
    var wdgSender = SelectableText(senderDisplayStr,
        style: TextStyle(fontSize: 9.0, color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor()));

    var wdgMessage = SelectableText(
      widget.content + '\u202F',
      //key: Key(myKey),
      focusNode: _focus,
      style: TextStyle(
        color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
      ),
      textAlign: TextAlign.left,
      textWidthBasis: TextWidthBasis.longestLine,
    );

    var wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, prettyDate: prettyDate);

    var error = Provider.of<MessageMetadata>(context).error;

    return LayoutBuilder(builder: (context, constraints) {
      //print(constraints.toString()+", "+constraints.maxWidth.toString());
      return RepaintBoundary(
          child: Container(
              child: Container(
                  decoration: BoxDecoration(
                    color: error
                        ? malformedColor
                        : (fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor() : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor()),
                    border: Border.all(
                        color: error
                            ? malformedColor
                            : (fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor() : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor()),
                        width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(borderRadiousEh),
                      topRight: Radius.circular(borderRadiousEh),
                      bottomLeft: fromMe ? Radius.circular(borderRadiousEh) : Radius.zero,
                      bottomRight: fromMe ? Radius.zero : Radius.circular(borderRadiousEh),
                    ),
                  ),
                  child: Padding(
                      padding: EdgeInsets.all(9.0),
                      child: Column(
                          crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: fromMe ? [wdgMessage, wdgDecorations] : [wdgSender, wdgMessage, wdgDecorations])))));
    });
  }
}

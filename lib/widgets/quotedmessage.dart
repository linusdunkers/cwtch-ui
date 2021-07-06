import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model.dart';
import 'package:intl/intl.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

class QuotedMessageBubble extends StatefulWidget {
  final Future<Message> quotedMessage;
  final String body;

  QuotedMessageBubble(this.body, this.quotedMessage);

  @override
  QuotedMessageBubbleState createState() => QuotedMessageBubbleState();
}

class QuotedMessageBubbleState extends State<QuotedMessageBubble> {
  FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var prettyDate = "";
    var borderRadiousEh = 15.0;

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
      widget.body + '\u202F',
      focusNode: _focus,
      style: TextStyle(
        color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
      ),
      textAlign: TextAlign.left,
      textWidthBasis: TextWidthBasis.longestLine,
    );

    var wdgQuote = FutureBuilder(
      future: widget.quotedMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var qMessage = (snapshot.data! as Message);
          // Swap the background color for quoted tweets..
          return Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              color: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor() : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor(),
              child: qMessage.getPreviewWidget(context));
        } else {
          // This should be almost instantly resolved, any failure likely means an issue in decoding...
          return MessageLoadingBubble();
        }
      },
    );

    var wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, prettyDate: prettyDate);

    var error = Provider.of<MessageMetadata>(context).error;

    return LayoutBuilder(builder: (context, constraints) {
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
                          children: fromMe ? [wdgQuote, wdgMessage, wdgDecorations] : [wdgSender, wdgQuote, wdgMessage, wdgDecorations])))));
    });
  }
}

import 'dart:io';

import 'package:cwtch/controllers/open_link_modal.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/third_party/linkify/flutter_linkify.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    var borderRadiousEh = 15.0;
    var showClickableLinks = Provider.of<Settings>(context).isExperimentEnabled(ClickableLinksExperiment);
    var formatMessages = Provider.of<Settings>(context).isExperimentEnabled(FormattingExperiment);
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
    var wdgSender = Container(
        height: 11,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(),
        child: SelectableText(senderDisplayStr,
            maxLines: 1,
            style: TextStyle(
              fontSize: 9.0,
              overflow: TextOverflow.clip,
              color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor,
            )));

    var wdgMessage = SelectableLinkify(
      text: widget.content + '\u202F',
      // TODO: onOpen breaks the "selectable" functionality. Maybe something to do with gesture handler?
      options: LinkifyOptions(messageFormatting: formatMessages, parseLinks: showClickableLinks, looseUrl: true, defaultToHttps: true),
      linkifiers: [UrlLinkifier()],
      onOpen: showClickableLinks
          ? (link) {
              modalOpenLink(context, link);
            }
          : null,
      //key: Key(myKey),
      focusNode: _focus,
      style: TextStyle(
        color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor,
      ),
      linkStyle: TextStyle(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor),
      codeStyle: TextStyle(
          // note: these colors are flipped
          color: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherTextColor : Provider.of<Settings>(context).theme.messageFromMeTextColor,
          backgroundColor: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor),
      textAlign: TextAlign.left,
      textWidthBasis: TextWidthBasis.longestLine,
    );

    var wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, messageDate: messageDate);

    var error = Provider.of<MessageMetadata>(context).error;

    return LayoutBuilder(builder: (context, constraints) {
      //print(constraints.toString()+", "+constraints.maxWidth.toString());
      return RepaintBoundary(
          child: Container(
              child: Container(
                  decoration: BoxDecoration(
                    color: error ? malformedColor : (fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor),
                    border: Border.all(
                        color: error
                            ? malformedColor
                            : (fromMe ? Provider.of<Settings>(context).theme.messageFromMeBackgroundColor : Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor),
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

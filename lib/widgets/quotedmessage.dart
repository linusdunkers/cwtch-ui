import 'dart:convert';

import 'package:cwtch/main.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model.dart';
import 'package:intl/intl.dart';

import '../settings.dart';
import 'messagebubbledecorations.dart';

class LocallyIndexedMessage {
  final dynamic message;
  final int index;

  LocallyIndexedMessage(this.message, this.index);

  LocallyIndexedMessage.fromJson(Map<String, dynamic> json)
      : message = json['Message'],
        index = json['LocalIndex'];

  Map<String, dynamic> toJson() => {
        'Message': message,
        'LocalIndex': index,
      };
}

class QuotedMessageBubble extends StatefulWidget {
  @override
  QuotedMessageBubbleState createState() => QuotedMessageBubbleState();
}

class QuotedMessageBubbleState extends State<QuotedMessageBubble> {
  FocusNode _focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageState>(context).senderOnion == Provider.of<ProfileInfoState>(context).onion;
    var prettyDate = "";
    var borderRadiousEh = 15.0;
    var myKey = Provider.of<MessageState>(context).profileOnion + "::" + Provider.of<MessageState>(context).contactHandle + "::" + Provider.of<MessageState>(context).messageIndex.toString();

    try {
      dynamic message = jsonDecode(Provider.of<MessageState>(context).message);

      var quotedMessagePotentials =
          Provider.of<FlwtchState>(context).cwtch.GetMessageByContentHash(Provider.of<MessageState>(context).profileOnion, Provider.of<MessageState>(context).contactHandle, message["quotedHash"]);
      int messageIndex = Provider.of<MessageState>(context).messageIndex;
      var quotedMessage = quotedMessagePotentials.then((matchingMessages) {
        // reverse order the messages from newest to oldest and return the
        // first matching message where it's index is less than the index of this
        // message
        try {
          var list = (jsonDecode(matchingMessages) as List<dynamic>).map((data) => LocallyIndexedMessage.fromJson(data)).toList();
          LocallyIndexedMessage candidate = list.reversed.firstWhere((element) => messageIndex < element.index, orElse: () {
            return list.firstWhere((element) => messageIndex > element.index);
          });
          return candidate;
        } catch (e) {
          // Malformed Message will be returned...
        }
      });

      if (Provider.of<MessageState>(context).timestamp != null) {
        // user-configurable timestamps prolly ideal? #todo
        DateTime messageDate = Provider.of<MessageState>(context).timestamp;
        prettyDate = DateFormat.yMd().add_jm().format(messageDate.toLocal());
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
      var wdgSender = SelectableText(senderDisplayStr,
          style: TextStyle(fontSize: 9.0, color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor()));

      var wdgMessage = SelectableText(
        (message["body"] ?? "") + '\u202F',
        key: Key(myKey),
        focusNode: _focus,
        style: TextStyle(
          color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
        ),
        textAlign: TextAlign.left,
        textWidthBasis: TextWidthBasis.longestLine,
      );

      var wdgQuote = FutureBuilder(
        future: quotedMessage,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var lim = (snapshot.data! as LocallyIndexedMessage);
            var limmessage = lim.message;
            // Swap the background color for quoted tweets..
            return Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                color: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor() : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor(),
                child: Text(jsonDecode(limmessage)["d"]));
          } else {
            // This should be almost instantly resolved, any failure likely means an issue in decoding...
            return MalformedBubble();
          }
        },
      );

      var wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageState>(context).ackd, errored: Provider.of<MessageState>(context).error, fromMe: fromMe, prettyDate: prettyDate);

      var error = Provider.of<MessageState>(context).error;

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
    } catch (e) {
      return MalformedBubble();
    }
  }
}

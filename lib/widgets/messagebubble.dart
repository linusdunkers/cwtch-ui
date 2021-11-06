import 'dart:io';

import 'package:cwtch/models/message.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

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
    var showClickableLinks = Provider.of<Settings>(context).isExperimentEnabled(ClickableLinksExperiment);

    DateTime messageDate = Provider.of<MessageMetadata>(context).timestamp;
    prettyDate = DateFormat.yMd(Platform.localeName).add_jm().format(messageDate.toLocal());

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

    var wdgMessage;

    if (!showClickableLinks) {   
      wdgMessage = SelectableText(
        widget.content + '\u202F',
        //key: Key(myKey),
        focusNode: _focus,
        style: TextStyle(
          color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
        ),
        textAlign: TextAlign.left,
        textWidthBasis: TextWidthBasis.longestLine,
      );
    } else {
      wdgMessage = SelectableLinkify(
        text: widget.content + '\u202F',
        // TODO: onOpen breaks the "selectable" functionality. Maybe something to do with gesture handler?
        options: LinkifyOptions(humanize: false),
        linkifiers: [UrlLinkifier()],
        onOpen: (link) {
          _modalOpenLink(context, link);
        },
        //key: Key(myKey),
        focusNode: _focus,
        style: TextStyle(
          color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor(),
        ),
        textAlign: TextAlign.left,
        textWidthBasis: TextWidthBasis.longestLine,
      );
    }

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

  void _modalOpenLink(BuildContext ctx, LinkableElement link) {
    showModalBottomSheet<void>(
        context: ctx,
        builder: (BuildContext bcontext) {
          return Container(
              height: 200, // bespoke value courtesy of the [TextField] docs
              child: Center(
                child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Opening this link will launch an application outside of Cwtch and may reveal metadata or otherwise compromise the security of Cwtch. Only open links from people you trust. Are you sure you want to continue?"
                        ),
                        Flex(direction: Axis.horizontal, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            child: ElevatedButton(
                              child: Text("Copy link", semanticsLabel: "Copy link"),
                              onPressed: () {
                                Clipboard.setData(new ClipboardData(text: link.url));

                                final snackBar = SnackBar(
                                  content: Text(AppLocalizations.of(context)!.copiedClipboardNotification),
                                );

                                Navigator.pop(bcontext);
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                            child: ElevatedButton(
                              child: Text("Open link", semanticsLabel: "Open link"),
                              onPressed: () async {
                                if (await canLaunch(link.url)) {
                                  await launch(link.url);
                                } else {
                                  throw 'Could not launch $link';
                                }
                              },
                            ),
                          ),
                        ]),
                      ],
                    )),
              ));
      });
  }
}

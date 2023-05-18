import 'package:cwtch/controllers/open_link_modal.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/third_party/linkify/flutter_linkify.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../settings.dart';
import 'messageBubbleWidgetHelpers.dart';
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
    var borderRadiousEh = 15.0;

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

    var wdgSender = compileSenderWidget(context, fromMe, senderDisplayStr);

    var showClickableLinks = Provider.of<Settings>(context).isExperimentEnabled(ClickableLinksExperiment);
    var formatMessages = Provider.of<Settings>(context).isExperimentEnabled(FormattingExperiment);
    var wdgMessage = compileMessageContentWidget(context, fromMe, widget.body, _focus, formatMessages, showClickableLinks);

    var wdgQuote = FutureBuilder(
      future: widget.quotedMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          try {
            var qMessage = (snapshot.data! as Message);

            // If the sender is not us, then we want to give them a nickname...
            String qMessageSender;

            // if we sent the quoted message then display our nickname
            if (qMessage.getMetadata().senderHandle == Provider.of<ProfileInfoState>(context).onion) {
              qMessageSender = Provider.of<ProfileInfoState>(context).nickname;
            } else {
              // default to handle
              qMessageSender = qMessage.getMetadata().senderHandle;
              // if we have the handle as a contact then replace with the nickname...
              ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.findContact(qMessageSender);
              if (contact != null) {
                qMessageSender = contact.nickname;
              }
            }

            var qTextColor = fromMe ? Provider.of<Settings>(context).theme.messageFromOtherTextColor : Provider.of<Settings>(context).theme.messageFromMeTextColor;

            var wdgReplyingTo = SelectableText(
              AppLocalizations.of(context)!.replyingTo.replaceAll("%1", qMessageSender),
              style: Provider.of<Settings>(context).scaleFonts(TextStyle(fontSize: 10, color: qTextColor.withOpacity(0.8))),
            );
            // Swap the background color for quoted tweets..
            return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                    onTap: () {
                      var messageInfo = Provider.of<ContactInfoState>(context, listen: false).messageCache.getByContentHash(qMessage.getMetadata().contenthash);
                      if (messageInfo != null) {
                        var index = Provider.of<ContactInfoState>(context, listen: false).messageCache.findIndex(messageInfo.metadata.messageID);
                        if (index != null) {
                          Provider.of<ContactInfoState>(context, listen: false).messageScrollController.scrollTo(index: index, duration: Duration(milliseconds: 100));
                        }
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(5),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor,
                        ),
                        height: 75,
                        child: Column(children: [
                          Align(alignment: Alignment.centerLeft, child: wdgReplyingTo),
                          Flexible(
                              child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), child: Icon(Icons.reply, size: 32, color: qTextColor)),
                            Flexible(child: qMessage.getPreviewWidget(context)),
                          ]))
                        ]))));
          } catch (e) {
            return MalformedBubble();
          }
        } else {
          // This should be almost instantly resolved, any failure likely means an issue in decoding...
          return MessageLoadingBubble();
        }
      },
    );

    var wdgDecorations = MessageBubbleDecoration(ackd: Provider.of<MessageMetadata>(context).ackd, errored: Provider.of<MessageMetadata>(context).error, fromMe: fromMe, messageDate: messageDate);

    var error = Provider.of<MessageMetadata>(context).error;

    return LayoutBuilder(builder: (context, constraints) {
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
                          children: fromMe ? [wdgQuote, wdgMessage, wdgDecorations] : [wdgSender, wdgQuote, wdgMessage, wdgDecorations])))));
    });
  }
}

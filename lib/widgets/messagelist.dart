import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/malformedmessage.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../model.dart';
import '../settings.dart';
import 'messagerow.dart';

class MessageList extends StatefulWidget {
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  ScrollController ctrlr1 = ScrollController();

  @override
  Widget build(BuildContext outerContext) {
    bool isP2P = !Provider.of<ContactInfoState>(context).isGroup;
    bool isGroupAndSyncing = Provider.of<ContactInfoState>(context).isGroup == true && Provider.of<ContactInfoState>(context).status == "Authenticated";
    bool isGroupAndSynced = Provider.of<ContactInfoState>(context).isGroup && Provider.of<ContactInfoState>(context).status == "Synced";
    bool isGroupAndNotAuthenticated = Provider.of<ContactInfoState>(context).isGroup && Provider.of<ContactInfoState>(context).status != "Authenticated";

    bool showEphemeralWarning = (isP2P && Provider.of<ContactInfoState>(context).savePeerHistory != "SaveHistory");
    bool showOfflineWarning = Provider.of<ContactInfoState>(context).isOnline() == false;
    bool showSyncing = isGroupAndSyncing;
    bool showMessageWarning = showEphemeralWarning || showOfflineWarning || showSyncing;
    // Only load historical messages when the conversation is with a p2p contact OR the conversation is a server and *not* syncing.
    bool loadMessages = isP2P || (isGroupAndSynced || isGroupAndNotAuthenticated);

    return RepaintBoundary(
        child: Container(
            child: Column(children: [
      Visibility(
          visible: showMessageWarning,
          child: Container(
              padding: EdgeInsets.all(5.0),
              color: Provider.of<Settings>(context).theme.defaultButtonActiveColor(),
              child: DefaultTextStyle(
                style: TextStyle(color: Provider.of<Settings>(context).theme.defaultButtonTextColor()),
                child: showSyncing
                    ? Text(AppLocalizations.of(context)!.serverNotSynced, textAlign: TextAlign.center)
                    : showOfflineWarning
                        ? Text(Provider.of<ContactInfoState>(context).isGroup ? AppLocalizations.of(context)!.serverConnectivityDisconnected : AppLocalizations.of(context)!.peerOfflineMessage,
                            textAlign: TextAlign.center)
                        // Only show the ephemeral status for peer conversations, not for groups...
                        : (showEphemeralWarning
                            ? Text(AppLocalizations.of(context)!.chatHistoryDefault, textAlign: TextAlign.center)
                            :
                            // We are not allowed to put null here, so put an empty text widge
                            Text("")),
              ))),
      Expanded(
          child: Scrollbar(
              controller: ctrlr1,
              child: Container(
                  // Only show broken heart is the contact is offline...
                  decoration: BoxDecoration(
                      image: Provider.of<ContactInfoState>(outerContext).isOnline()
                          ? null
                          : DecorationImage(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              image: AssetImage("assets/core/negative_heart_512px.png"),
                              colorFilter: ColorFilter.mode(Provider.of<Settings>(context).theme.hilightElementTextColor(), BlendMode.srcIn))),
                  // Don't load messages for syncing server...
                  child: loadMessages
                      ? ListView.builder(
                          controller: ctrlr1,
                          itemCount: Provider.of<ContactInfoState>(outerContext).totalMessages,
                          reverse: true, // NOTE: There seems to be a bug in flutter that corrects the mouse wheel scroll, but not the drag direction...
                          itemBuilder: (itemBuilderContext, index) {
                            var profileOnion = Provider.of<ProfileInfoState>(outerContext, listen: false).onion;
                            var contactHandle = Provider.of<ContactInfoState>(outerContext, listen: false).onion;
                            var messageIndex = Provider.of<ContactInfoState>(outerContext).totalMessages - index - 1;

                            return FutureBuilder(
                              future: messageHandler(outerContext, profileOnion, contactHandle, messageIndex),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  var message = snapshot.data as Message;
                                  // Already includes MessageRow,,
                                  return message.getWidget(context);
                                } else {
                                  return MessageLoadingBubble();
                                }
                              },
                            );
                          },
                        )
                      : null)))
    ])));
  }
}

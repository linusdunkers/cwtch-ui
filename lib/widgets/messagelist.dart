import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messagecache.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../settings.dart';

class MessageList extends StatefulWidget {
  ItemPositionsListener scrollListener;
  MessageList(this.scrollListener);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext outerContext) {
    // On Android we can have unsynced messages at the front of the index from when the UI was asleep, if there are some, kick off sync of those first
    if (Provider.of<ContactInfoState>(context).messageCache.indexUnsynced != 0) {
      var conversationId = Provider.of<AppState>(outerContext, listen: false).selectedConversation!;
      MessageCache? cache = Provider.of<ProfileInfoState>(outerContext, listen: false).contactList.getContact(conversationId)?.messageCache;
      ByIndex(0).loadUnsynced(Provider.of<FlwtchState>(context, listen: false).cwtch, Provider.of<AppState>(outerContext, listen: false).selectedProfile!, conversationId, cache!);
    }
    var initi = Provider.of<AppState>(outerContext, listen: false).initialScrollIndex;
    bool isP2P = !Provider.of<ContactInfoState>(context).isGroup;
    bool isGroupAndSyncing = Provider.of<ContactInfoState>(context).isGroup == true && Provider.of<ContactInfoState>(context).status == "Authenticated";

    // Older checks, no longer used, kept for reference.
    //bool isGroupAndSynced = Provider.of<ContactInfoState>(context).isGroup && Provider.of<ContactInfoState>(context).status == "Synced";
    //bool isGroupAndNotAuthenticated = Provider.of<ContactInfoState>(context).isGroup && Provider.of<ContactInfoState>(context).status != "Authenticated";

    bool showEphemeralWarning = (isP2P && Provider.of<ContactInfoState>(context).savePeerHistory != "SaveHistory");
    bool showOfflineWarning = Provider.of<ContactInfoState>(context).isOnline() == false;
    bool showSyncing = isGroupAndSyncing;
    bool showMessageWarning = showEphemeralWarning || showOfflineWarning || showSyncing;
    // We used to only load historical messages when the conversation is with a p2p contact OR the conversation is a server and *not* syncing.
    // With the message cache in place this is no longer necessary
    bool loadMessages = true;

    return RepaintBoundary(
        child: Container(
            color: Provider.of<Settings>(context).theme.backgroundMainColor,
            child: Column(children: [
              Visibility(
                  visible: showMessageWarning,
                  child: Container(
                      padding: EdgeInsets.all(5.0),
                      color: Provider.of<Settings>(context).theme.defaultButtonActiveColor,
                      child: DefaultTextStyle(
                        style: TextStyle(color: Provider.of<Settings>(context).theme.defaultButtonTextColor),
                        child: showSyncing
                            ? Text(AppLocalizations.of(context)!.serverNotSynced, textAlign: TextAlign.center)
                            : showOfflineWarning
                                ? Text(Provider.of<ContactInfoState>(context).isGroup ? AppLocalizations.of(context)!.serverConnectivityDisconnected : AppLocalizations.of(context)!.peerOfflineMessage,
                                    textAlign: TextAlign.center)
                                // Only show the ephemeral status for peer conversations, not for groups...
                                : (showEphemeralWarning
                                    ? Text(AppLocalizations.of(context)!.chatHistoryDefault, textAlign: TextAlign.center)
                                    :
                                    // We are not allowed to put null here, so put an empty text widget
                                    Text("")),
                      ))),
              Expanded(
                  child: Container(
                      // Only show broken heart is the contact is offline...
                      decoration: BoxDecoration(
                          image: Provider.of<ContactInfoState>(outerContext).isOnline()
                              ? null
                              : DecorationImage(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  image: AssetImage("assets/core/negative_heart_512px.png"),
                                  colorFilter: ColorFilter.mode(Provider.of<Settings>(context).theme.hilightElementColor, BlendMode.srcIn))),
                      // Don't load messages for syncing server...
                      child: loadMessages
                          ? ScrollablePositionedList.builder(
                              itemPositionsListener: widget.scrollListener,
                              itemScrollController: Provider.of<ContactInfoState>(outerContext).messageScrollController,
                              initialScrollIndex: initi > 4 ? initi - 4 : 0,
                              itemCount: Provider.of<ContactInfoState>(outerContext).totalMessages,
                              reverse: true, // NOTE: There seems to be a bug in flutter that corrects the mouse wheel scroll, but not the drag direction...
                              itemBuilder: (itemBuilderContext, index) {
                                var profileOnion = Provider.of<ProfileInfoState>(itemBuilderContext, listen: false).onion;
                                var contactHandle = Provider.of<ContactInfoState>(itemBuilderContext, listen: false).identifier;
                                var messageIndex = index;

                                return FutureBuilder(
                                  future: messageHandler(itemBuilderContext, profileOnion, contactHandle, ByIndex(messageIndex)),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      var message = snapshot.data as Message;
                                      // here we create an index key for the contact and assign it to the row. Indexes are unique so we can
                                      // reliably use this without running into duplicate keys...it isn't ideal as it means keys need to be re-built
                                      // when new messages are added...however it is better than the alternative of not having widget keys at all.
                                      var key = Provider.of<ContactInfoState>(itemBuilderContext, listen: false).getMessageKey(contactHandle, messageIndex);
                                      return message.getWidget(context, key, messageIndex);
                                    } else {
                                      return MessageLoadingBubble();
                                    }
                                  },
                                );
                              },
                            )
                          : null))
            ])));
  }
}

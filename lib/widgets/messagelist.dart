import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    bool showEphemeralWarning = (Provider.of<ContactInfoState>(context).isGroup == false && Provider.of<ContactInfoState>(context).savePeerHistory != "SaveHistory");
    bool showOfflineWarning = Provider.of<ContactInfoState>(context).isOnline() == false;
    bool showMessageWarning = showEphemeralWarning || showOfflineWarning;
    bool showSyncing = Provider.of<ContactInfoState>(context).isGroup == true && Provider.of<ContactInfoState>(context).status != "Synced";

    return RepaintBoundary(
        child: Container(
            child: Column(children: [
      Visibility(
          visible: showMessageWarning,
          child: Container(
            padding: EdgeInsets.all(5.0),
            color: Provider.of<Settings>(context).theme.defaultButtonActiveColor(),
            child: showSyncing ?
                    Text(AppLocalizations.of(context)!.serverNotSynced,
                    textAlign: TextAlign.center)
                    : showOfflineWarning
                ? Text(Provider.of<ContactInfoState>(context).isGroup ? AppLocalizations.of(context)!.serverConnectivityDisconnected : AppLocalizations.of(context)!.peerOfflineMessage,
                    textAlign: TextAlign.center)
                // Only show the ephemeral status for peer conversations, not for groups...
                : (showEphemeralWarning
                    ? Text(AppLocalizations.of(context)!.chatHistoryDefault, textAlign: TextAlign.center)
                    :
                    // We are not allowed to put null here, so put an empty text widge
                    Text("")),
          )),
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
                  child: ListView.builder(
                    controller: ctrlr1,
                    itemCount: Provider.of<ContactInfoState>(outerContext).totalMessages,
                    reverse: true, // NOTE: There seems to be a bug in flutter that corrects the mouse wheel scroll, but not the drag direction...
                    itemBuilder: (itemBuilderContext, index) {
                      var trueIndex = Provider.of<ContactInfoState>(outerContext).totalMessages - index - 1;
                      return ChangeNotifierProvider(
                          key: ValueKey(trueIndex),
                          create: (x) => MessageState(
                                context: itemBuilderContext,
                                profileOnion: Provider.of<ProfileInfoState>(outerContext, listen: false).onion,
                                // We don't want to listen for updates to the contact handle...
                                contactHandle: Provider.of<ContactInfoState>(x, listen: false).onion,
                                messageIndex: trueIndex,
                              ),
                          builder: (bcontext, child) {
                            String idx = Provider.of<ContactInfoState>(outerContext).isGroup == true && Provider.of<MessageState>(bcontext).signature.isEmpty == false
                                ? Provider.of<MessageState>(bcontext).signature
                                : trueIndex.toString();
                            return RepaintBoundary(child: MessageRow(key: Provider.of<ContactInfoState>(bcontext).getMessageKey(idx)));
                          });
                    },
                  ))))
    ])));
  }
}

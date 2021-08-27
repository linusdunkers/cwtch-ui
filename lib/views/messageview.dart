import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/quotedmessage.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/views/peersettingsview.dart';
import 'package:cwtch/widgets/DropdownContacts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../main.dart';
import '../model.dart';
import '../settings.dart';
import '../widgets/messagelist.dart';
import 'groupsettingsview.dart';

class MessageView extends StatefulWidget {
  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final ctrlrCompose = TextEditingController();
  final focusNode = FocusNode();
  String selectedContact = "";
  ItemPositionsListener scrollListener = ItemPositionsListener.create();
  ItemScrollController scrollController = ItemScrollController();

  @override
  void initState() {
    scrollListener.itemPositions.addListener(() {
      var first = scrollListener.itemPositions.value.first.index;
      var last = scrollListener.itemPositions.value.last.index;
      // sometimes these go hi->lo and sometimes they go lo->hi because [who tf knows]
      if ((first == 0 || last == 0) && Provider.of<AppState>(context, listen: false).unreadMessagesBelow == true) {
        Provider.of<AppState>(context, listen: false).initialScrollIndex = 0;
        Provider.of<AppState>(context, listen: false).unreadMessagesBelow = false;
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var appState = Provider.of<AppState>(context, listen: false);

    // using "8" because "# of messages that fit on one screen" isnt trivial to calculate at this point
    if (appState.initialScrollIndex > 8 && appState.unreadMessagesBelow == false) {
      WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
        appState.unreadMessagesBelow = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    focusNode.dispose();
    ctrlrCompose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // After leaving a conversation the selected conversation is set to null...
    if (Provider.of<ContactInfoState>(context).profileOnion == "") {
      return Card(child: Center(child: Text(AppLocalizations.of(context)!.addContactFirst)));
    }

    var appState = Provider.of<AppState>(context);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          floatingActionButton: appState.unreadMessagesBelow
              ? FloatingActionButton(
                  child: Icon(Icons.arrow_downward),
                  onPressed: () {
                    scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 600));
                  })
              : null,
          appBar: AppBar(
            // setting leading to null makes it do the default behaviour; container() hides it
            leading: Provider.of<Settings>(context).uiColumns(appState.isLandscape(context)).length > 1 ? Container() : null,
            title: Row(children: [
              ProfileImage(
                imagePath: Provider.of<ContactInfoState>(context).imagePath,
                diameter: 42,
                border: Provider.of<Settings>(context).current().portraitOnlineBorderColor(),
                badgeTextColor: Colors.red,
                badgeColor: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(
                Provider.of<ContactInfoState>(context).nickname,
                overflow: TextOverflow.ellipsis,
              ))
            ]),
            actions: [
              //IconButton(icon: Icon(Icons.chat), onPressed: _pushContactSettings),
              //IconButton(icon: Icon(Icons.list), onPressed: _pushContactSettings),
              //IconButton(icon: Icon(Icons.push_pin), onPressed: _pushContactSettings),
              IconButton(
                  icon: Icon(CwtchIcons.send_invite, size: 24),
                  tooltip: AppLocalizations.of(context)!.sendInvite,
                  onPressed: () {
                    _modalSendInvitation(context);
                  }),
              IconButton(
                  icon: Provider.of<ContactInfoState>(context, listen: false).isGroup == true ? Icon(CwtchIcons.group_settings_24px) : Icon(CwtchIcons.peer_settings_24px),
                  tooltip: AppLocalizations.of(context)!.conversationSettings,
                  onPressed: _pushContactSettings),
            ],
          ),
          body: Padding(padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 108.0), child: MessageList(scrollController, scrollListener)),
          bottomSheet: _buildComposeBox(),
        ));
  }

  Future<bool> _onWillPop() async {
    Provider.of<ContactInfoState>(context, listen: false).unreadMessages = 0;
    Provider.of<AppState>(context, listen: false).selectedConversation = null;
    return true;
  }

  void _pushContactSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext bcontext) {
        if (Provider.of<ContactInfoState>(context, listen: false).isGroup == true) {
          return MultiProvider(
            providers: [ChangeNotifierProvider.value(value: Provider.of<ContactInfoState>(context))],
            child: GroupSettingsView(),
          );
        } else {
          return MultiProvider(
            providers: [ChangeNotifierProvider.value(value: Provider.of<ContactInfoState>(context))],
            child: PeerSettingsView(),
          );
        }
      },
    ));
  }

  void _sendMessage([String? ignoredParam]) {
    if (ctrlrCompose.value.text.isNotEmpty) {
      if (Provider.of<AppState>(context, listen: false).selectedConversation != null && Provider.of<AppState>(context, listen: false).selectedIndex != null) {
        Provider.of<FlwtchState>(context, listen: false)
            .cwtch
            .GetMessage(Provider.of<AppState>(context, listen: false).selectedProfile!, Provider.of<AppState>(context, listen: false).selectedConversation!,
                Provider.of<AppState>(context, listen: false).selectedIndex!)
            .then((data) {
          try {
            var messageWrapper = jsonDecode(data! as String);
            var bytes1 = utf8.encode(messageWrapper["PeerID"] + messageWrapper['Message']);
            var digest1 = sha256.convert(bytes1);
            var contentHash = base64Encode(digest1.bytes);
            var quotedMessage = jsonEncode(QuotedMessageStructure(contentHash, ctrlrCompose.value.text));
            ChatMessage cm = new ChatMessage(o: QuotedMessageOverlay, d: quotedMessage);
            Provider.of<FlwtchState>(context, listen: false)
                .cwtch
                .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).onion, jsonEncode(cm));
          } catch (e) {}
          Provider.of<AppState>(context, listen: false).selectedIndex = null;
          _sendMessageHelper();
        });
      } else {
        ChatMessage cm = new ChatMessage(o: TextMessageOverlay, d: ctrlrCompose.value.text);
        Provider.of<FlwtchState>(context, listen: false)
            .cwtch
            .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).onion, jsonEncode(cm));
        _sendMessageHelper();
      }
    }
  }

  void _sendInvitation([String? ignoredParam]) {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .SendInvitation(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).onion, this.selectedContact);
    _sendMessageHelper();
  }

  void _sendMessageHelper() {
    ctrlrCompose.clear();
    focusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 80), () {
      Provider.of<ContactInfoState>(context, listen: false).totalMessages++;
      // Resort the contact list...
      Provider.of<ProfileInfoState>(context, listen: false).contactList.updateLastMessageTime(Provider.of<ContactInfoState>(context, listen: false).onion, DateTime.now());
    });
  }

  Widget _buildComposeBox() {
    bool isOffline = Provider.of<ContactInfoState>(context).isOnline() == false;

    var composeBox = Container(
      color: Provider.of<Settings>(context).theme.backgroundMainColor(),
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      height: 100,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Provider.of<Settings>(context).theme.defaultButtonActiveColor()))),
                  child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: handleKeyPress,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: TextFormField(
                            key: Key('txtCompose'),
                            controller: ctrlrCompose,
                            focusNode: focusNode,
                            autofocus: !Platform.isAndroid,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,
                            enableIMEPersonalizedLearning: false,
                            minLines: 1,
                            maxLines: null,
                            onFieldSubmitted: _sendMessage,
                            enabled: !isOffline,
                            decoration: InputDecoration(
                                hintText: isOffline ? "" : AppLocalizations.of(context)!.placeholderEnterMessage,
                                hintStyle: TextStyle(color: Provider.of<Settings>(context).theme.altTextColor()),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabled: true,
                                suffixIcon: ElevatedButton(
                                  child: Icon(CwtchIcons.send_24px, size: 24, color: Provider.of<Settings>(context).theme.mainTextColor()),
                                  onPressed: isOffline ? null : _sendMessage,
                                ))),
                      )))),
        ],
      ),
    );

    var children;
    if (Provider.of<AppState>(context).selectedConversation != null && Provider.of<AppState>(context).selectedIndex != null) {
      var quoted = FutureBuilder(
        future: messageHandler(context, Provider.of<AppState>(context).selectedProfile!, Provider.of<AppState>(context).selectedConversation!, Provider.of<AppState>(context).selectedIndex!),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var message = snapshot.data! as Message;
            return Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                color: message.getMetadata().senderHandle != Provider.of<AppState>(context).selectedProfile
                    ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor()
                    : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor(),
                child: Wrap(runAlignment: WrapAlignment.spaceEvenly, alignment: WrapAlignment.spaceEvenly, runSpacing: 1.0, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Center(widthFactor: 1, child: Padding(padding: EdgeInsets.all(10.0), child: Icon(Icons.reply, size: 32))),
                  Center(widthFactor: 1.0, child: message.getPreviewWidget(context)),
                  Center(
                      widthFactor: 1.0,
                      child: IconButton(
                        icon: Icon(Icons.highlight_remove),
                        tooltip: AppLocalizations.of(context)!.tooltipRemoveThisQuotedMessage,
                        onPressed: () {
                          Provider.of<AppState>(context, listen: false).selectedIndex = null;
                        },
                      ))
                ]));
          } else {
            return MessageLoadingBubble();
          }
        },
      );

      children = [quoted, composeBox];
    } else {
      children = [composeBox];
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  // Send the message if enter is pressed without the shift key...
  void handleKeyPress(event) {
    var data = event.data as RawKeyEventData;
    if (data.logicalKey == LogicalKeyboardKey.enter && !event.isShiftPressed) {
      final messageWithoutNewLine = ctrlrCompose.value.text.trimRight();
      ctrlrCompose.value = TextEditingValue(text: messageWithoutNewLine);
      _sendMessage();
    }
  }

  void placeHolder() => {};

  // explicitly passing BuildContext ctx here is important, change at risk to own health
  // otherwise some Providers will become inaccessible to subwidgets...?
  // https://stackoverflow.com/a/63818697
  void _modalSendInvitation(BuildContext ctx) {
    showModalBottomSheet<void>(
        context: ctx,
        builder: (BuildContext bcontext) {
          return Container(
              height: 200, // bespoke value courtesy of the [TextField] docs
              child: Center(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(AppLocalizations.of(bcontext)!.invitationLabel),
                        SizedBox(
                          height: 20,
                        ),
                        ChangeNotifierProvider.value(
                            value: Provider.of<ProfileInfoState>(ctx, listen: false),
                            child: DropdownContacts(filter: (contact) {
                              return contact.onion != Provider.of<ContactInfoState>(context).onion;
                            }, onChanged: (newVal) {
                              setState(() {
                                this.selectedContact = newVal;
                              });
                            })),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          child: Text(AppLocalizations.of(bcontext)!.inviteBtn, semanticsLabel: AppLocalizations.of(bcontext)!.inviteBtn),
                          onPressed: () {
                            if (this.selectedContact != "") {
                              this._sendInvitation();
                            }
                            Navigator.pop(bcontext);
                          },
                        ),
                      ],
                    )),
              ));
        });
  }
}

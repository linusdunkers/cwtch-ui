import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/chatmessage.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/messages/quotedmessage.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/widgets/malformedbubble.dart';
import 'package:cwtch/widgets/messageloadingbubble.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:cwtch/controllers/filesharing.dart' as filesharing;
import 'package:file_picker/file_picker.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/views/peersettingsview.dart';
import 'package:cwtch/widgets/DropdownContacts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../constants.dart';
import '../main.dart';
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
  int selectedContact = -1;
  ItemPositionsListener scrollListener = ItemPositionsListener.create();
  ItemScrollController scrollController = ItemScrollController();
  File? imagePreview;

  @override
  void initState() {
    scrollListener.itemPositions.addListener(() {
      if (scrollListener.itemPositions.value.length != 0 &&
          Provider.of<AppState>(context, listen: false).unreadMessagesBelow == true &&
          scrollListener.itemPositions.value.any((element) => element.index == 0)) {
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
    if (appState.initialScrollIndex > 4 && appState.unreadMessagesBelow == false) {
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

    var showFileSharing = Provider.of<Settings>(context).isExperimentEnabled(FileSharingExperiment);
    var appBarButtons = <Widget>[];
    if (Provider.of<ContactInfoState>(context).isOnline()) {
      if (showFileSharing) {
        appBarButtons.add(IconButton(
          splashRadius: Material.defaultSplashRadius / 2,
          icon: Icon(Icons.attach_file, size: 24, color: Provider.of<Settings>(context).theme.mainTextColor),
          tooltip: AppLocalizations.of(context)!.tooltipSendFile,
          onPressed: Provider.of<AppState>(context).disableFilePicker
              ? null
              : () {
                  imagePreview = null;
                  filesharing.showFilePicker(context, MaxGeneralFileSharingSize, (File file) {
                    _confirmFileSend(context, file.path);
                  }, () {
                    final snackBar = SnackBar(
                      content: Text(AppLocalizations.of(context)!.msgFileTooBig),
                      duration: Duration(seconds: 4),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }, () {});
                },
        ));
      }
      appBarButtons.add(IconButton(
          splashRadius: Material.defaultSplashRadius / 2,
          icon: Icon(CwtchIcons.send_invite, size: 24),
          tooltip: AppLocalizations.of(context)!.sendInvite,
          onPressed: () {
            _modalSendInvitation(context);
          }));
    }
    appBarButtons.add(IconButton(
        splashRadius: Material.defaultSplashRadius / 2,
        icon: Provider.of<ContactInfoState>(context, listen: false).isGroup == true ? Icon(CwtchIcons.group_settings_24px) : Icon(CwtchIcons.peer_settings_24px),
        tooltip: AppLocalizations.of(context)!.conversationSettings,
        onPressed: _pushContactSettings));

    var appState = Provider.of<AppState>(context);
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Provider.of<Settings>(context).theme.backgroundMainColor,
          floatingActionButton: appState.unreadMessagesBelow
              ? FloatingActionButton(
                  child: Icon(Icons.arrow_downward),
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false).initialScrollIndex = 0;
                    Provider.of<AppState>(context, listen: false).unreadMessagesBelow = false;
                    scrollController.scrollTo(index: 0, duration: Duration(milliseconds: 600));
                  })
              : null,
          appBar: AppBar(
            // setting leading to null makes it do the default behaviour; container() hides it
            leading: Provider.of<Settings>(context).uiColumns(appState.isLandscape(context)).length > 1 ? Container() : null,
            title: Row(children: [
              ProfileImage(
                imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment)
                    ? Provider.of<ContactInfoState>(context).imagePath
                    : Provider.of<ContactInfoState>(context).defaultImagePath,
                diameter: 42,
                border: Provider.of<Settings>(context).current().portraitOnlineBorderColor,
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
            actions: appBarButtons,
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
    var profileInfoState = Provider.of<ProfileInfoState>(context, listen: false);
    var contactInfoState = Provider.of<ContactInfoState>(context, listen: false);

    if (Provider.of<ContactInfoState>(context, listen: false).isGroup == true) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext bcontext) {
        return MultiProvider(
          providers: [ChangeNotifierProvider.value(value: profileInfoState), ChangeNotifierProvider.value(value: contactInfoState)],
          child: GroupSettingsView(),
        );
      }));
    } else {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (BuildContext bcontext) {
        return MultiProvider(
          providers: [ChangeNotifierProvider.value(value: profileInfoState), ChangeNotifierProvider.value(value: contactInfoState)],
          child: PeerSettingsView(),
        );
      }));
    }
  }

  // todo: legacy groups currently have restricted message
  // size because of the additional wrapping end encoding
  // hybrid groups should allow these numbers to be the same.
  static const P2PMessageLengthMax = 7000;
  static const GroupMessageLengthMax = 1600;

  void _sendMessage([String? ignoredParam]) {

    // Trim message
    final messageWithoutNewLine = ctrlrCompose.value.text.trimRight();
    ctrlrCompose.value = TextEditingValue(text: messageWithoutNewLine);

    var isGroup = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(Provider.of<AppState>(context, listen: false).selectedConversation!)!.isGroup;

    // peers and groups currently have different length constraints (servers can store less)...
    var actualMessageLength = ctrlrCompose.value.text.length;
    var lengthOk = (isGroup && actualMessageLength < GroupMessageLengthMax) || actualMessageLength <= P2PMessageLengthMax;

    if (ctrlrCompose.value.text.isNotEmpty && lengthOk) {
      if (Provider.of<AppState>(context, listen: false).selectedConversation != null && Provider.of<AppState>(context, listen: false).selectedIndex != null) {
        Provider.of<FlwtchState>(context, listen: false)
            .cwtch
            .GetMessageByID(Provider.of<AppState>(context, listen: false).selectedProfile!, Provider.of<AppState>(context, listen: false).selectedConversation!,
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
                .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, jsonEncode(cm));
          } catch (e) {}
          Provider.of<AppState>(context, listen: false).selectedIndex = null;
          _sendMessageHelper();
        });
      } else {
        ChatMessage cm = new ChatMessage(o: TextMessageOverlay, d: ctrlrCompose.value.text);
        Provider.of<FlwtchState>(context, listen: false)
            .cwtch
            .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, jsonEncode(cm));
        _sendMessageHelper();
      }
    }
  }

  void _sendInvitation([String? ignoredParam]) {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .SendInvitation(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, this.selectedContact);
    _sendMessageHelper();
  }

  void _sendFile(String filePath) {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .ShareFile(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, filePath);
    _sendMessageHelper();
  }

  void _sendMessageHelper() {
    ctrlrCompose.clear();
    focusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 80), () {
      var profile = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
      var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;
      fetchAndCacheMessageInfo(context, profile, identifier, ByIndex(0));
      Provider.of<ContactInfoState>(context, listen: false).newMarker++;
      Provider.of<ContactInfoState>(context, listen: false).totalMessages += 1;
      // Resort the contact list...
      Provider.of<ProfileInfoState>(context, listen: false).contactList.updateLastMessageTime(Provider.of<ContactInfoState>(context, listen: false).identifier, DateTime.now());
    });
  }

  Widget _buildComposeBox() {
    bool isOffline = Provider.of<ContactInfoState>(context).isOnline() == false;
    bool isGroup = Provider.of<ContactInfoState>(context).isGroup;

    var charLength = ctrlrCompose.value.text.characters.length;
    var expectedLength = ctrlrCompose.value.text.length;
    var numberOfBytesMoreThanChar = (expectedLength - charLength);

    var composeBox = Container(
      color: Provider.of<Settings>(context).theme.backgroundMainColor,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),
      height: 100,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  decoration: BoxDecoration(border: Border(top: BorderSide(color: Provider.of<Settings>(context).theme.defaultButtonActiveColor))),
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
                            maxLength: (isGroup ? GroupMessageLengthMax : P2PMessageLengthMax) - numberOfBytesMoreThanChar,
                            maxLengthEnforcement: MaxLengthEnforcement.enforced,
                            maxLines: null,
                            onFieldSubmitted: _sendMessage,
                            enabled: !isOffline,
                            onChanged: (String x) {
                              setState(() {
                                // we need to force a rerender here to update the max length count
                              });
                            },
                            decoration: InputDecoration(
                                hintText: isOffline ? "" : AppLocalizations.of(context)!.placeholderEnterMessage,
                                hintStyle: TextStyle(color: Provider.of<Settings>(context).theme.sendHintTextColor),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabled: true,
                                suffixIcon: ElevatedButton(
                                  key: Key("btnSend"),
                                  style: ElevatedButton.styleFrom(padding: EdgeInsets.all(0.0), shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(45.0))),
                                  child: Icon(CwtchIcons.send_24px, size: 24, color: Provider.of<Settings>(context).theme.defaultButtonTextColor),
                                  onPressed: isOffline ? null : _sendMessage,
                                ))),
                      )))),
        ],
      ),
    );

    var children;
    if (Provider.of<AppState>(context).selectedConversation != null && Provider.of<AppState>(context).selectedIndex != null) {
      var quoted = FutureBuilder(
        future: messageHandler(context, Provider.of<AppState>(context).selectedProfile!, Provider.of<AppState>(context).selectedConversation!, ById(Provider.of<AppState>(context).selectedIndex!)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var message = snapshot.data! as Message;
            return Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                color: message.getMetadata().senderHandle != Provider.of<AppState>(context).selectedProfile
                    ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor
                    : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.highlight_remove),
                          splashRadius: Material.defaultSplashRadius / 2,
                          tooltip: AppLocalizations.of(context)!.tooltipRemoveThisQuotedMessage,
                          onPressed: () {
                            Provider.of<AppState>(context, listen: false).selectedIndex = null;
                          },
                        )),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(padding: EdgeInsets.all(2.0), child: Icon(Icons.reply)),
                    )
                  ]),
                  Wrap(
                      runAlignment: WrapAlignment.spaceEvenly,
                      alignment: WrapAlignment.center,
                      runSpacing: 1.0,
                      children: [Center(widthFactor: 1.0, child: Padding(padding: EdgeInsets.all(10.0), child: message.getPreviewWidget(context)))]),
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

    return Container(color: Provider.of<Settings>(context).theme.backgroundMainColor, child: Column(mainAxisSize: MainAxisSize.min, children: children));
  }

  // Send the message if enter is pressed without the shift key...
  void handleKeyPress(event) {
    var data = event.data as RawKeyEventData;
    if (data.logicalKey == LogicalKeyboardKey.enter && !event.isShiftPressed) {
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
                                this.selectedContact = Provider.of<ProfileInfoState>(context, listen: false).contactList.findContact(newVal)!.identifier;
                              });
                            })),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          child: Text(AppLocalizations.of(bcontext)!.inviteBtn, semanticsLabel: AppLocalizations.of(bcontext)!.inviteBtn),
                          onPressed: () {
                            if (this.selectedContact != -1) {
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

  void _confirmFileSend(BuildContext ctx, String path) async {
    showModalBottomSheet<void>(
        context: ctx,
        builder: (BuildContext bcontext) {
          var showPreview = false;
          if (Provider.of<Settings>(context, listen: false).shouldPreview(path)) {
            showPreview = true;
            if (imagePreview == null) {
              imagePreview = new File(path);
            }
          }
          return Container(
              height: 300, // bespoke value courtesy of the [TextField] docs
              child: Center(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.msgConfirmSend + " $path?"),
                        SizedBox(
                          height: 20,
                        ),
                        Visibility(
                            visible: showPreview,
                            child: showPreview
                                ? Image.file(
                                    imagePreview!,
                                    cacheHeight: 150, // limit the amount of space the image can decode too, we keep this high-ish to allow quality previews...
                                    filterQuality: FilterQuality.medium,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.center,
                                    height: 150,
                                    isAntiAlias: false,
                                    errorBuilder: (context, error, stackTrace) {
                                      return MalformedBubble();
                                    },
                                  )
                                : Container()),
                        Visibility(
                            visible: showPreview,
                            child: SizedBox(
                              height: 10,
                            )),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          ElevatedButton(
                            child: Text(AppLocalizations.of(context)!.cancel, semanticsLabel: AppLocalizations.of(context)!.cancel),
                            onPressed: () {
                              Navigator.pop(bcontext);
                            },
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            child: Text(AppLocalizations.of(context)!.btnSendFile, semanticsLabel: AppLocalizations.of(context)!.btnSendFile),
                            onPressed: () {
                              _sendFile(path);
                              Navigator.pop(bcontext);
                            },
                          ),
                        ]),
                      ],
                    )),
              ));
        });
  }
}

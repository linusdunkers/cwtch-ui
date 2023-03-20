import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:crypto/crypto.dart';
import 'package:cwtch/cwtch/cwtch.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/chatmessage.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/message_draft.dart';
import 'package:cwtch/models/messagecache.dart';
import 'package:cwtch/models/messages/quotedmessage.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/third_party/linkify/flutter_linkify.dart';
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

import '../config.dart';
import '../constants.dart';
import '../main.dart';
import '../settings.dart';
import '../widgets/messagelist.dart';
import 'filesharingview.dart';
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
  File? imagePreview;
  bool showDown = false;
  bool showPreview = false;

  @override
  void initState() {
    scrollListener.itemPositions.addListener(() {
      if (scrollListener.itemPositions.value.length != 0 &&
          Provider.of<AppState>(context, listen: false).unreadMessagesBelow == true &&
          scrollListener.itemPositions.value.any((element) => element.index == 0)) {
        Provider.of<AppState>(context, listen: false).initialScrollIndex = 0;
        Provider.of<AppState>(context, listen: false).unreadMessagesBelow = false;
      }

      if (scrollListener.itemPositions.value.length != 0 && !scrollListener.itemPositions.value.any((element) => element.index == 0)) {
        showDown = true;
      } else {
        showDown = false;
      }
    });
    ctrlrCompose.text = Provider.of<ContactInfoState>(context, listen: false).messageDraft.messageText ?? "";
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
    if (Provider.of<ContactInfoState>(context, listen: false).profileOnion == "") {
      return Card(child: Center(child: Text(AppLocalizations.of(context)!.addContactFirst)));
    }

    var showMessageFormattingPreview = Provider.of<Settings>(context).isExperimentEnabled(FormattingExperiment);
    var showFileSharing = Provider.of<Settings>(context).isExperimentEnabled(FileSharingExperiment);
    var appBarButtons = <Widget>[];

    if (showFileSharing) {
      appBarButtons.add(IconButton(
          splashRadius: Material.defaultSplashRadius / 2, icon: Icon(CwtchIcons.manage_files), tooltip: AppLocalizations.of(context)!.manageSharedFiles, onPressed: _pushFileSharingSettings));
    }

    if (Provider.of<ContactInfoState>(context).isOnline()) {
      if (showFileSharing) {
        appBarButtons.add(IconButton(
          splashRadius: Material.defaultSplashRadius / 2,
          icon: Icon(CwtchIcons.attached_file_2, size: 26, color: Provider.of<Settings>(context).theme.mainTextColor),
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
          floatingActionButton: showDown
              ? FloatingActionButton(
                  // heroTags need to be unique per screen (important when we pop up and down)...
                  heroTag: "popDown" + Provider.of<ContactInfoState>(context, listen: false).onion,
                  child: Icon(Icons.arrow_downward, color: Provider.of<Settings>(context).current().defaultButtonTextColor),
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false).initialScrollIndex = 0;
                    Provider.of<AppState>(context, listen: false).unreadMessagesBelow = false;
                    Provider.of<ContactInfoState>(context, listen: false).messageScrollController.scrollTo(index: 0, duration: Duration(milliseconds: 600));
                  })
              : null,
          appBar: AppBar(
            // setting leading(Width) to null makes it do the default behaviour; container() hides it
            leadingWidth: Provider.of<Settings>(context).uiColumns(appState.isLandscape(context)).length > 1 ? 0 : null,
            leading: Provider.of<Settings>(context).uiColumns(appState.isLandscape(context)).length > 1
                ? Container(
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    width: 0,
                    height: 0,
                  )
                : null,
            title: Row(children: [
              ProfileImage(
                  imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment)
                      ? Provider.of<ContactInfoState>(context).imagePath
                      : Provider.of<ContactInfoState>(context).defaultImagePath,
                  diameter: 42,
                  border: Provider.of<Settings>(context).current().portraitOnlineBorderColor,
                  badgeTextColor: Colors.red,
                  badgeColor: Provider.of<Settings>(context).theme.portraitContactBadgeColor,
                  badgeIcon: Provider.of<ContactInfoState>(context).isGroup
                      ? (Tooltip(
                          message: Provider.of<ContactInfoState>(context).isOnline()
                              ? Provider.of<ContactInfoState>(context).antispamTickets == 0
                                  ? AppLocalizations.of(context)!.acquiringTicketsFromServer
                                  : AppLocalizations.of(context)!.acquiredTicketsFromServer
                              : AppLocalizations.of(context)!.serverConnectivityDisconnected,
                          child: Provider.of<ContactInfoState>(context).isOnline()
                              ? Provider.of<ContactInfoState>(context).antispamTickets == 0
                                  ? Icon(
                                      CwtchIcons.anti_spam_3,
                                      size: 14.0,
                                      semanticLabel: AppLocalizations.of(context)!.acquiringTicketsFromServer,
                                      color: Provider.of<Settings>(context).theme.portraitContactBadgeTextColor,
                                    )
                                  : Icon(
                                      CwtchIcons.anti_spam_2,
                                      color: Provider.of<Settings>(context).theme.portraitContactBadgeTextColor,
                                      size: 14.0,
                                    )
                              : Icon(
                                  CwtchIcons.onion_off,
                                  color: Provider.of<Settings>(context).theme.portraitContactBadgeTextColor,
                                  size: 14.0,
                                )))
                      : null),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Container(
                      height: 24,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(),
                      child: Text(
                        Provider.of<ContactInfoState>(context).nickname,
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      )))
            ]),
            actions: appBarButtons,
          ),
          body: Padding(
              padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 182.0),
              child: MessageList(
                scrollListener,
              )),
          bottomSheet: showPreview && showMessageFormattingPreview ? _buildPreviewBox() : _buildComposeBox(context),
        ));
  }

  Future<bool> _onWillPop() async {
    Provider.of<ContactInfoState>(context, listen: false).unreadMessages = 0;

    var previouslySelected = Provider.of<AppState>(context, listen: false).selectedConversation;
    if (previouslySelected != null) {
      Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(previouslySelected)!.unselected();
    }

    Provider.of<AppState>(context, listen: false).selectedConversation = null;
    return true;
  }

  void _pushFileSharingSettings() {
    var profileInfoState = Provider.of<ProfileInfoState>(context, listen: false);
    var contactInfoState = Provider.of<ContactInfoState>(context, listen: false);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (builderContext, a1, a2) {
          return MultiProvider(
            providers: [ChangeNotifierProvider.value(value: profileInfoState), ChangeNotifierProvider.value(value: contactInfoState)],
            child: FileSharingView(),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _pushContactSettings() {
    var profileInfoState = Provider.of<ProfileInfoState>(context, listen: false);
    var contactInfoState = Provider.of<ContactInfoState>(context, listen: false);

    if (Provider.of<ContactInfoState>(context, listen: false).isGroup == true) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (builderContext, a1, a2) {
            return MultiProvider(
              providers: [ChangeNotifierProvider.value(value: profileInfoState), ChangeNotifierProvider.value(value: contactInfoState)],
              child: GroupSettingsView(),
            );
          },
          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 200),
        ),
      );
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (builderContext, a1, a2) {
            return MultiProvider(
              providers: [ChangeNotifierProvider.value(value: profileInfoState), ChangeNotifierProvider.value(value: contactInfoState)],
              child: PeerSettingsView(),
            );
          },
          transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: Duration(milliseconds: 200),
        ),
      );
    }
  }

  // todo: legacy groups currently have restricted message
  // size because of the additional wrapping end encoding
  // hybrid groups should allow these numbers to be the same.
  static const P2PMessageLengthMax = 7000;
  static const GroupMessageLengthMax = 1600;

  void _sendMessage([String? ignoredParam]) {
    // Do this after we trim to preserve enter-behaviour...
    bool isOffline = Provider.of<ContactInfoState>(context, listen: false).isOnline() == false;
    bool performingAntiSpam = Provider.of<ContactInfoState>(context, listen: false).antispamTickets == 0;
    bool isGroup = Provider.of<ContactInfoState>(context, listen: false).isGroup;
    if (isOffline || (isGroup && performingAntiSpam)) {
      return;
    }

    // Trim message
    final messageWithoutNewLine = ctrlrCompose.value.text.trimRight();
    ctrlrCompose.value = TextEditingValue(text: messageWithoutNewLine, selection: TextSelection.fromPosition(TextPosition(offset: messageWithoutNewLine.length)));

    // peers and groups currently have different length constraints (servers can store less)...
    var actualMessageLength = ctrlrCompose.value.text.length;
    var lengthOk = (isGroup && actualMessageLength < GroupMessageLengthMax) || actualMessageLength <= P2PMessageLengthMax;

    if (ctrlrCompose.value.text.isNotEmpty && lengthOk) {
      if (Provider.of<AppState>(context, listen: false).selectedConversation != null && Provider.of<ContactInfoState>(context, listen: false).messageDraft.getQuotedMessage() != null) {
        var conversationId = Provider.of<AppState>(context, listen: false).selectedConversation!;
        MessageCache? cache = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(conversationId)?.messageCache;
        ById(Provider.of<ContactInfoState>(context, listen: false).messageDraft.getQuotedMessage()!.index)
            .get(Provider.of<FlwtchState>(context, listen: false).cwtch, Provider.of<AppState>(context, listen: false).selectedProfile!, conversationId, cache!)
            .then((MessageInfo? data) {
          try {
            var bytes1 = utf8.encode(data!.metadata.senderHandle + data.wrapper);
            var digest1 = sha256.convert(bytes1);
            var contentHash = base64Encode(digest1.bytes);
            var quotedMessage = jsonEncode(QuotedMessageStructure(contentHash, ctrlrCompose.value.text));
            ChatMessage cm = new ChatMessage(o: QuotedMessageOverlay, d: quotedMessage);
            Provider.of<FlwtchState>(context, listen: false)
                .cwtch
                .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, jsonEncode(cm))
                .then(_sendMessageHandler);
          } catch (e) {
            EnvironmentConfig.debugLog("Exception: reply to message could not be found: " + e.toString());
          }
          Provider.of<ContactInfoState>(context, listen: false).messageDraft.clearQuotedReference();
        });
      } else {
        ChatMessage cm = new ChatMessage(o: TextMessageOverlay, d: ctrlrCompose.value.text);
        Provider.of<FlwtchState>(context, listen: false)
            .cwtch
            .SendMessage(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, jsonEncode(cm))
            .then(_sendMessageHandler);
      }
    }
  }

  void _sendInvitation([String? ignoredParam]) {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .SendInvitation(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, this.selectedContact)
        .then(_sendMessageHandler);
  }

  void _sendFile(String filePath) {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .ShareFile(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier, filePath)
        .then(_sendMessageHandler);
  }

  void _sendMessageHandler(dynamic messageJson) {
    if (Provider.of<ContactInfoState>(context, listen: false).isGroup && Provider.of<ContactInfoState>(context, listen: false).antispamTickets == 0) {
      final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.acquiringTicketsFromServer));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // At this point we have decided to send the text to the backend, failure is still possible
    // but it will show as an error-ed message, as such the draft can be purged.
    Provider.of<ContactInfoState>(context, listen: false).messageDraft = MessageDraft.empty();
    ctrlrCompose.clear();

    var profileOnion = Provider.of<ContactInfoState>(context, listen: false).profileOnion;
    var identifier = Provider.of<ContactInfoState>(context, listen: false).identifier;
    var profile = Provider.of<ProfileInfoState>(context, listen: false);

    var messageInfo = messageJsonToInfo(profileOnion, identifier, messageJson);
    if (messageInfo != null) {
      profile.newMessage(
        messageInfo.metadata.conversationIdentifier,
        messageInfo.metadata.messageID,
        messageInfo.metadata.timestamp,
        messageInfo.metadata.senderHandle,
        messageInfo.metadata.senderImage ?? "",
        messageInfo.metadata.isAuto,
        messageInfo.wrapper,
        messageInfo.metadata.contenthash,
        true,
        true,
      );
    }

    Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profileOnion, identifier, LastMessageSeenTimeKey, DateTime.now().toIso8601String());
    focusNode.requestFocus();
  }

  Widget _buildPreviewBox() {
    var showClickableLinks = Provider.of<Settings>(context).isExperimentEnabled(ClickableLinksExperiment);

    var wdgMessage = Padding(
        padding: EdgeInsets.all(8),
        child: SelectableLinkify(
          text: ctrlrCompose.text + '\n',
          options: LinkifyOptions(messageFormatting: true, parseLinks: showClickableLinks, looseUrl: true, defaultToHttps: true),
          linkifiers: [UrlLinkifier()],
          onOpen: showClickableLinks ? null : null,
          style: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
            fontSize: 16,
          ),
          linkStyle: TextStyle(
            color: Provider.of<Settings>(context).theme.messageFromMeTextColor,
            fontSize: 16,
          ),
          codeStyle: TextStyle(
              // note: these colors are flipped
              fontSize: 16,
              color: Provider.of<Settings>(context).theme.messageFromOtherTextColor,
              backgroundColor: Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor),
          textAlign: TextAlign.left,
          textWidthBasis: TextWidthBasis.longestLine,
        ));

    var showMessageFormattingPreview = Provider.of<Settings>(context).isExperimentEnabled(FormattingExperiment);
    var preview = showMessageFormattingPreview
        ? IconButton(
            tooltip: AppLocalizations.of(context)!.tooltipBackToMessageEditing,
            icon: Icon(Icons.text_fields),
            onPressed: () {
              setState(() {
                showPreview = false;
              });
            })
        : Container();

    var composeBox = Container(
      color: Provider.of<Settings>(context).theme.backgroundMainColor,
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.all(2),

      // 164 minimum height + 16px for every line of text so the entire message is displayed when previewed.
      height: 164 + ((ctrlrCompose.text.split("\n").length - 1) * 16),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.max, children: [preview]),
          Container(
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Provider.of<Settings>(context).theme.defaultButtonActiveColor))),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [wdgMessage])),
        ],
      ),
    );
    return Container(
        color: Provider.of<Settings>(context).theme.backgroundMainColor, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [composeBox]));
  }

  Widget _buildComposeBox(BuildContext context) {
    bool isOffline = Provider.of<ContactInfoState>(context).isOnline() == false;
    bool isGroup = Provider.of<ContactInfoState>(context).isGroup;
    var showToolbar = Provider.of<Settings>(context).isExperimentEnabled(FormattingExperiment);
    var charLength = ctrlrCompose.value.text.characters.length;
    var expectedLength = ctrlrCompose.value.text.length;
    var numberOfBytesMoreThanChar = (expectedLength - charLength);

    var bold = IconButton(
        icon: Icon(Icons.format_bold),
        tooltip: AppLocalizations.of(context)!.tooltipBoldText,
        onPressed: () {
          setState(() {
            var selected = ctrlrCompose.selection.textInside(ctrlrCompose.text);
            var selection = ctrlrCompose.selection;
            var start = ctrlrCompose.selection.start;
            var end = ctrlrCompose.selection.end;
            ctrlrCompose.text = ctrlrCompose.text.replaceRange(start, end, "**" + selected + "**");
            ctrlrCompose.selection = selection.copyWith(baseOffset: selection.start + 2, extentOffset: selection.start + 2);
          });
        });

    var italic = IconButton(
        icon: Icon(Icons.format_italic),
        tooltip: AppLocalizations.of(context)!.tooltipItalicize,
        onPressed: () {
          setState(() {
            var selected = ctrlrCompose.selection.textInside(ctrlrCompose.text);
            var selection = ctrlrCompose.selection;
            var start = ctrlrCompose.selection.start;
            var end = ctrlrCompose.selection.end;
            ctrlrCompose.text = ctrlrCompose.text.replaceRange(start, end, "*" + selected + "*");
            ctrlrCompose.selection = selection.copyWith(baseOffset: selection.start + 1, extentOffset: selection.start + 1);
          });
        });

    var code = IconButton(
        icon: Icon(Icons.code),
        tooltip: AppLocalizations.of(context)!.tooltipCode,
        onPressed: () {
          setState(() {
            var selected = ctrlrCompose.selection.textInside(ctrlrCompose.text);
            var selection = ctrlrCompose.selection;
            var start = ctrlrCompose.selection.start;
            var end = ctrlrCompose.selection.end;
            ctrlrCompose.text = ctrlrCompose.text.replaceRange(start, end, "`" + selected + "`");
            ctrlrCompose.selection = selection.copyWith(baseOffset: selection.start + 1, extentOffset: selection.start + 1);
          });
        });

    var superscript = IconButton(
        icon: Icon(Icons.superscript),
        tooltip: AppLocalizations.of(context)!.tooltipSuperscript,
        onPressed: () {
          setState(() {
            var selected = ctrlrCompose.selection.textInside(ctrlrCompose.text);
            var selection = ctrlrCompose.selection;
            var start = ctrlrCompose.selection.start;
            var end = ctrlrCompose.selection.end;
            ctrlrCompose.text = ctrlrCompose.text.replaceRange(start, end, "^" + selected + "^");
            ctrlrCompose.selection = selection.copyWith(baseOffset: selection.start + 1, extentOffset: selection.start + 1);
          });
        });

    var subscript = IconButton(
        icon: Icon(Icons.subscript),
        tooltip: AppLocalizations.of(context)!.tooltipSubscript,
        onPressed: () {
          setState(() {
            var selected = ctrlrCompose.selection.textInside(ctrlrCompose.text);
            var selection = ctrlrCompose.selection;
            var start = ctrlrCompose.selection.start;
            var end = ctrlrCompose.selection.end;
            ctrlrCompose.text = ctrlrCompose.text.replaceRange(start, end, "_" + selected + "_");
            ctrlrCompose.selection = selection.copyWith(baseOffset: selection.start + 1, extentOffset: selection.start + 1);
          });
        });

    var strikethrough = IconButton(
        icon: Icon(Icons.format_strikethrough),
        tooltip: AppLocalizations.of(context)!.tooltipStrikethrough,
        onPressed: () {
          setState(() {
            var selected = ctrlrCompose.selection.textInside(ctrlrCompose.text);
            var selection = ctrlrCompose.selection;
            var start = ctrlrCompose.selection.start;
            var end = ctrlrCompose.selection.end;
            ctrlrCompose.text = ctrlrCompose.text.replaceRange(start, end, "~~" + selected + "~~");
            ctrlrCompose.selection = selection.copyWith(baseOffset: selection.start + 2, extentOffset: selection.start + 2);
          });
        });

    var preview = IconButton(
        icon: Icon(Icons.text_format),
        tooltip: AppLocalizations.of(context)!.tooltipPreviewFormatting,
        onPressed: () {
          setState(() {
            showPreview = true;
          });
        });

    var vline = Padding(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 2),
        child: Container(height: 16, width: 1, decoration: BoxDecoration(color: Provider.of<Settings>(context).theme.messageFromMeTextColor)));

    var formattingToolbar = Container(
        decoration: BoxDecoration(color: Provider.of<Settings>(context).theme.defaultButtonActiveColor),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [bold, italic, code, superscript, subscript, strikethrough, vline, preview]));

    var textField = Container(
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
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  enableIMEPersonalizedLearning: false,
                  minLines: 1,
                  maxLength: max(1, (isGroup ? GroupMessageLengthMax : P2PMessageLengthMax) - numberOfBytesMoreThanChar),
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  maxLines: 3,
                  onFieldSubmitted: _sendMessage,
                  enabled: true, // always allow editing...

                  onChanged: (String x) {
                    Provider.of<ContactInfoState>(context, listen: false).messageDraft.messageText = x;
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
                        child: Tooltip(
                            message: isOffline
                                ? (isGroup ? AppLocalizations.of(context)!.serverNotSynced : AppLocalizations.of(context)!.peerOfflineMessage)
                                : (isGroup && Provider.of<ContactInfoState>(context, listen: false).antispamTickets == 0)
                                    ? AppLocalizations.of(context)!.acquiringTicketsFromServer
                                    : AppLocalizations.of(context)!.sendMessage,
                            child: Icon(CwtchIcons.send_24px, size: 24, color: Provider.of<Settings>(context).theme.defaultButtonTextColor)),
                        onPressed: isOffline || (isGroup && Provider.of<ContactInfoState>(context, listen: false).antispamTickets == 0) ? null : _sendMessage,
                      ))),
            )));

    var textEditChildren;
    if (showToolbar) {
      textEditChildren = [formattingToolbar, textField];
    } else {
      textEditChildren = [textField];
    }

    var composeBox =
        Container(color: Provider.of<Settings>(context).theme.backgroundMainColor, padding: EdgeInsets.all(2), margin: EdgeInsets.all(2), height: 164, child: Column(children: textEditChildren));

    var children;
    if (Provider.of<AppState>(context).selectedConversation != null && Provider.of<ContactInfoState>(context).messageDraft.getQuotedMessage() != null) {
      var quoted = FutureBuilder(
        future: messageHandler(context, Provider.of<AppState>(context).selectedProfile!, Provider.of<AppState>(context).selectedConversation!,
            ById(Provider.of<ContactInfoState>(context).messageDraft.getQuotedMessage()!.index)),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var message = snapshot.data! as Message;
            var qTextColor = message.getMetadata().senderHandle != Provider.of<AppState>(context).selectedProfile
                ? Provider.of<Settings>(context).theme.messageFromOtherTextColor
                : Provider.of<Settings>(context).theme.messageFromMeTextColor;
            return Container(
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(5),
                color: message.getMetadata().senderHandle != Provider.of<AppState>(context).selectedProfile
                    ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor
                    : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(5),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: message.getMetadata().senderHandle != Provider.of<AppState>(context).selectedProfile
                              ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor
                              : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor,
                        ),
                        height: 75,
                        child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, children: [
                          Padding(padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0), child: Icon(Icons.reply, size: 32, color: qTextColor)),
                          Flexible(
                              child: DefaultTextStyle(
                            textWidthBasis: TextWidthBasis.parent,
                            child: message.getPreviewWidget(context),
                            style: TextStyle(color: qTextColor),
                            overflow: TextOverflow.fade,
                          ))
                        ])),
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.highlight_remove),
                          splashRadius: Material.defaultSplashRadius / 2,
                          tooltip: AppLocalizations.of(context)!.tooltipRemoveThisQuotedMessage,
                          onPressed: () {
                            Provider.of<ContactInfoState>(context, listen: false).messageDraft.clearQuotedReference();
                            setState(() {});
                          },
                        )),
                  ]),
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

    return Container(color: Provider.of<Settings>(context).theme.backgroundMainColor, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children));
  }

  // Send the message if enter is pressed without the shift key...
  void handleKeyPress(RawKeyEvent event) {
    var data = event.data;
    if (event is RawKeyUpEvent) {
      if ((data.logicalKey == LogicalKeyboardKey.enter && !event.isShiftPressed) || data.logicalKey == LogicalKeyboardKey.numpadEnter && !event.isShiftPressed) {
        // Don't send when inserting a new line that is not at the end of the message
        if (ctrlrCompose.selection.baseOffset != ctrlrCompose.text.length) {
          return;
        }
        _sendMessage();
      }
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(AppLocalizations.of(bcontext)!.invitationLabel),
                        SizedBox(
                          height: 20,
                        ),
                        ChangeNotifierProvider.value(
                            value: Provider.of<ProfileInfoState>(ctx, listen: false),
                            child: DropdownContacts(filter: (contact) {
                              return contact.onion != Provider.of<ContactInfoState>(ctx).onion;
                            }, onChanged: (newVal) {
                              setState(() {
                                this.selectedContact = Provider.of<ProfileInfoState>(ctx, listen: false).contactList.findContact(newVal)!.identifier;
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

import 'dart:io';

import 'package:cwtch/config.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/views/contactsview.dart';
import 'package:cwtch/widgets/staticmessagebubble.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../main.dart';
import '../models/messagecache.dart';
import '../settings.dart';

class MessageRow extends StatefulWidget {
  final Widget child;
  final int index;

  MessageRow(this.child, this.index, {Key? key}) : super(key: key);

  @override
  MessageRowState createState() => MessageRowState();
}

class MessageRowState extends State<MessageRow> with SingleTickerProviderStateMixin {
  bool showBlockedMessage = false;
  late AnimationController _controller;
  late Animation<Alignment> _animation;
  late Alignment _dragAlignment = Alignment.center;
  Alignment _dragAffinity = Alignment.center;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() {
        _dragAlignment = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var fromMe = Provider.of<MessageMetadata>(context).senderHandle == Provider.of<ProfileInfoState>(context).onion;
    var isContact = Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle) != null;
    var isGroup = Provider.of<ProfileInfoState>(context).contactList.getContact(Provider.of<MessageMetadata>(context, listen: false).conversationIdentifier)!.isGroup;
    var isBlocked = isContact ? Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle)!.isBlocked : false;
    var actualMessage = Flexible(flex: Platform.isAndroid ? 10 : 3, fit: FlexFit.loose, child: widget.child);

    _dragAffinity = fromMe ? Alignment.centerRight : Alignment.centerLeft;
    _dragAlignment = fromMe ? Alignment.centerRight : Alignment.centerLeft;

    var senderDisplayStr = "";
    if (!fromMe) {
      ContactInfoState? contact = Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle);
      if (contact != null) {
        senderDisplayStr = contact.nickname;
      } else {
        senderDisplayStr = Provider.of<MessageMetadata>(context).senderHandle;
      }
    }

    Widget wdgReply = Platform.isAndroid
        ? SizedBox.shrink()
        : Visibility(
            visible: EnvironmentConfig.TEST_MODE || Provider.of<AppState>(context).hoveredIndex == Provider.of<MessageMetadata>(context).messageID,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            maintainInteractivity: false,
            child: IconButton(
                tooltip: AppLocalizations.of(context)!.tooltipReplyToThisMessage,
                splashRadius: Material.defaultSplashRadius / 2,
                onPressed: () {
                  Provider.of<AppState>(context, listen: false).selectedIndex = Provider.of<MessageMetadata>(context, listen: false).messageID;
                },
                icon: Icon(Icons.reply, color: Provider.of<Settings>(context).theme.dropShadowColor)));

    var settings = Provider.of<Settings>(context);
    var pis = Provider.of<ProfileInfoState>(context);
    var cis = Provider.of<ContactInfoState>(context);
    var borderColor = Provider.of<Settings>(context).theme.portraitOnlineBorderColor;
    var messageID = Provider.of<MessageMetadata>(context).messageID;
    var cache = Provider.of<ContactInfoState>(context).messageCache;

    Widget wdgSeeReplies = Platform.isAndroid
        ? SizedBox.shrink()
        : Visibility(
            visible: EnvironmentConfig.TEST_MODE || Provider.of<AppState>(context).hoveredIndex == Provider.of<MessageMetadata>(context).messageID,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            maintainInteractivity: false,
            child: IconButton(
                tooltip: AppLocalizations.of(context)!.viewReplies,
                splashRadius: Material.defaultSplashRadius / 2,
                onPressed: () {
                  modalShowReplies(context, AppLocalizations.of(context)!.headingReplies, settings, pis, cis, borderColor, cache, messageID);
                },
                icon: Icon(Icons.message_rounded, color: Provider.of<Settings>(context).theme.dropShadowColor)));

    Widget wdgSpacer = Flexible(flex: 1, child: SizedBox(width: Platform.isAndroid ? 20 : 60, height: 10));
    var widgetRow = <Widget>[];

    if (fromMe) {
      widgetRow = <Widget>[
        wdgSpacer,
        wdgSeeReplies,
        wdgReply,
        actualMessage,
      ];
    } else if (isBlocked && !showBlockedMessage) {
      Color blockedMessageBackground = Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor;
      Widget wdgPortrait = Padding(padding: EdgeInsets.all(4.0), child: Icon(CwtchIcons.account_blocked));
      widgetRow = <Widget>[
        wdgPortrait,
        Container(
            padding: EdgeInsets.all(2.0),
            decoration: BoxDecoration(
                color: blockedMessageBackground,
                border: Border.all(color: blockedMessageBackground, width: 2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                )),
            child: Padding(
                padding: EdgeInsets.all(9.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                  SelectableText(
                    AppLocalizations.of(context)!.blockedMessageMessage,
                    //key: Key(myKey),
                    style: TextStyle(
                      color: Provider.of<Settings>(context).theme.messageFromOtherTextColor,
                    ),
                    textAlign: TextAlign.center,
                    textWidthBasis: TextWidthBasis.longestLine,
                  ),
                  Padding(
                      padding: EdgeInsets.all(1.0),
                      child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(blockedMessageBackground),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.showMessageButton + '\u202F',
                            style: TextStyle(decoration: TextDecoration.underline),
                          ),
                          onPressed: () {
                            setState(() {
                              this.showBlockedMessage = true;
                            });
                          })),
                ]))),
        wdgReply,
        wdgSeeReplies,
        wdgSpacer,
      ];
    } else {
      var contact = Provider.of<ContactInfoState>(context);
      ContactInfoState? sender = Provider.of<ProfileInfoState>(context).contactList.findContact(Provider.of<MessageMetadata>(context).senderHandle);

      String imagePath = Provider.of<MessageMetadata>(context).senderImage!;
      if (sender != null) {
        imagePath = Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment) ? sender.imagePath : sender.defaultImagePath;
      }
      Widget wdgPortrait = GestureDetector(
          onTap: !isGroup
              ? null
              : isContact
                  ? _btnGoto
                  : _btnAdd,
          child: Padding(
              padding: EdgeInsets.all(4.0),
              child: ProfileImage(
                diameter: 48.0,
                // default to the contact image...otherwise use a derived sender image...
                imagePath: imagePath,
                border: contact.status == "Authenticated" ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor,
                badgeTextColor: Colors.red,
                badgeColor: Colors.red,
                tooltip: !isGroup
                    ? ""
                    : isContact
                        ? AppLocalizations.of(context)!.contactGoto.replaceFirst("%1", senderDisplayStr)
                        : AppLocalizations.of(context)!.addContact,
              )));

      widgetRow = <Widget>[
        wdgPortrait,
        actualMessage,
        wdgReply,
        wdgSeeReplies,
        wdgSpacer,
      ];
    }
    var size = MediaQuery.of(context).size;
    var mr = MouseRegion(
        // For desktop...
        onHover: (event) {
          setState(() {
            Provider.of<AppState>(context, listen: false).hoveredIndex = Provider.of<MessageMetadata>(context, listen: false).messageID;
          });
        },
        onExit: (event) {
          setState(() {
            Provider.of<AppState>(context, listen: false).hoveredIndex = -1;
          });
        },
        child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dragAlignment += Alignment(
                  details.delta.dx / (size.width * 0.5),
                  0,
                );
              });
            },
            onPanDown: (details) {
              _controller.stop();
            },
            onPanEnd: (details) {
              _runAnimation(details.velocity.pixelsPerSecond, size);
              Provider.of<AppState>(context, listen: false).selectedIndex = Provider.of<MessageMetadata>(context, listen: false).messageID;
            },
            onLongPress: () async {
              modalShowReplies(context, AppLocalizations.of(context)!.headingReplies, settings, pis, cis, borderColor, cache, messageID);
            },
            child: Padding(
                padding: EdgeInsets.all(2),
                child: Align(
                    widthFactor: 1,
                    alignment: _dragAlignment,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widgetRow,
                    )))));

    if (Provider.of<ContactInfoState>(context).newMarkerMsgIndex == widget.index) {
      return Column(crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [Align(alignment: Alignment.center, child: _bubbleNew()), mr]);
    } else {
      return mr;
    }
  }

  Widget _bubbleNew() {
    return Container(
        decoration: BoxDecoration(
          color: Provider.of<Settings>(context).theme.messageFromMeBackgroundColor,
          border: Border.all(color: Provider.of<Settings>(context).theme.messageFromMeBackgroundColor, width: 1),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        child: Padding(padding: EdgeInsets.all(9.0), child: Text(AppLocalizations.of(context)!.newMessagesLabel)));
  }

  void _runAnimation(Offset pixelsPerSecond, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: _dragAffinity,
      ),
    );
    // Calculate the velocity relative to the unit interval, [0,1],
    // used by the animation controller.
    final unitsPerSecondX = pixelsPerSecond.dx / size.width;
    final unitsPerSecondY = pixelsPerSecond.dy / size.height;
    final unitsPerSecond = Offset(unitsPerSecondX, unitsPerSecondY);
    final unitVelocity = unitsPerSecond.distance;

    const spring = SpringDescription(
      mass: 30,
      stiffness: 1,
      damping: 1,
    );

    final simulation = SpringSimulation(spring, 0, 1, -unitVelocity);
    _controller.animateWith(simulation);
  }

  void _btnGoto() {
    var id = Provider.of<ProfileInfoState>(context, listen: false).contactList.findContact(Provider.of<MessageMetadata>(context, listen: false).senderHandle)?.identifier;
    if (id == null) {
      // Can't happen
    } else {
      selectConversation(context, id);
      var contactIndex = Provider.of<ProfileInfoState>(context, listen: false).contactList.filteredList().indexWhere((element) => element.identifier == id);
      Provider.of<ProfileInfoState>(context, listen: false).contactListScrollController.jumpTo(index: contactIndex);
    }
  }

  void _btnAdd() {
    var sender = Provider.of<MessageMetadata>(context, listen: false).senderHandle;
    if (sender == "") {
      print("sender not yet loaded");
      return;
    }
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;

    showAddContactConfirmAlertDialog(context, profileOnion, sender);
  }

  showAddContactConfirmAlertDialog(BuildContext context, String profileOnion, String senderOnion) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = ElevatedButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(20))),
      child: Text(AppLocalizations.of(context)!.addContact),
      onPressed: () {
        Provider.of<FlwtchState>(context, listen: false).cwtch.ImportBundle(profileOnion, senderOnion);
        final snackBar = SnackBar(
          content: Text(AppLocalizations.of(context)!.successfullAddedContact),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop(); // dismiss dialog
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.addContactConfirm.replaceFirst("%1", senderOnion)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

void modalShowReplies(BuildContext ctx, String replyHeader, Settings settings, ProfileInfoState profile, ContactInfoState cis, Color borderColor, MessageCache cache, int messageID,
    {bool showImage = true}) {
  showModalBottomSheet<void>(
      context: ctx,
      builder: (BuildContext bcontext) {
        List<Message> replies = getReplies(cache, messageID);

        return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          var replyWidgets = replies.map((e) {
            var fromMe = e.getMetadata().senderHandle == profile.onion;

            var bubble = StaticMessageBubble(profile, settings, e.getMetadata(), Row(children: [Flexible(child: e.getPreviewWidget(context))]));

            String imagePath = e.getMetadata().senderImage!;
            var sender = profile.contactList.findContact(e.getMetadata().senderHandle);
            if (sender != null) {
              imagePath = showImage ? sender.imagePath : sender.defaultImagePath;
            }

            if (fromMe) {
              imagePath = profile.imagePath;
            }

            var image = Padding(
                padding: EdgeInsets.all(4.0),
                child: ProfileImage(
                  imagePath: imagePath,
                  diameter: 48.0,
                  border: borderColor,
                  badgeTextColor: Colors.red,
                  badgeColor: Colors.red,
                ));

            return Padding(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [image, Flexible(child: bubble)],
                ));
          }).toList();

          var withHeader = replyWidgets;

          var original = StaticMessageBubble(profile, settings, cache.cache[messageID]!.metadata, Row(children: [Flexible(child: compileOverlay(cache.cache[messageID]!).getPreviewWidget(context))]));

          withHeader.insert(0, Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 2.0, 15.0), child: Center(child: original)));

          withHeader.insert(
              1,
              Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 2.0, 15.0),
                  child: Divider(
                    color: settings.theme.mainTextColor,
                  )));

          withHeader.insert(2, Padding(padding: EdgeInsets.fromLTRB(10.0, 10.0, 2.0, 15.0), child: Text(replyHeader, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))));

          return Scrollbar(
              isAlwaysShown: true,
              child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: withHeader,
                      ))));
        });
      });
}

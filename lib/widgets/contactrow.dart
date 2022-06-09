import 'dart:io';

import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/views/contactsview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:cwtch/views/messageview.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../settings.dart';
import 'package:intl/intl.dart';

class ContactRow extends StatefulWidget {
  @override
  _ContactRowState createState() => _ContactRowState();
}

class _ContactRowState extends State<ContactRow> {
  @override
  Widget build(BuildContext context) {
    var contact = Provider.of<ContactInfoState>(context);

    // Only groups have a sync status
    Widget? syncStatus;
    if (contact.isGroup) {
      syncStatus = Visibility(
          visible: contact.isGroup && contact.status == "Authenticated",
          child: LinearProgressIndicator(
            color: Provider.of<Settings>(context).theme.defaultButtonActiveColor,
            backgroundColor: Provider.of<Settings>(context).theme.defaultButtonDisabledColor,
            value: Provider.of<ProfileInfoState>(context).serverList.getServer(contact.server ?? "")?.syncProgress,
          ));
    }

    return Card(
        clipBehavior: Clip.antiAlias,
        color: Provider.of<AppState>(context).selectedConversation == contact.identifier ? Provider.of<Settings>(context).theme.backgroundHilightElementColor : null,
        borderOnForeground: true,
        margin: EdgeInsets.all(0.0),
        child: InkWell(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.all(6.0), //border size
              child: ProfileImage(
                  badgeCount: contact.unreadMessages,
                  badgeColor: Provider.of<Settings>(context).theme.portraitContactBadgeColor,
                  badgeTextColor: Provider.of<Settings>(context).theme.portraitContactBadgeTextColor,
                  diameter: 64.0,
                  imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment) ? contact.imagePath : contact.defaultImagePath,
                  maskOut: !contact.isOnline(),
                  border: contact.isOnline()
                      ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor
                      : contact.isBlocked
                          ? Provider.of<Settings>(context).theme.portraitBlockedBorderColor
                          : Provider.of<Settings>(context).theme.portraitOfflineBorderColor),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.nickname, //(contact.isInvitation ? "invite " : "non-invite ") + (contact.isBlocked ? "blokt" : "nonblokt"),//

                          style: TextStyle(
                              fontSize: Provider.of<Settings>(context).theme.contactOnionTextSize(),
                              color: contact.isBlocked
                                  ? Provider.of<Settings>(context).theme.portraitBlockedTextColor
                                  : Provider.of<Settings>(context).theme.mainTextColor), //Provider.of<FlwtchState>(context).biggerFont,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        syncStatus ?? Container(),
                        Visibility(
                          visible: !Provider.of<Settings>(context).streamerMode,
                          child: Text(contact.onion,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: contact.isBlocked ? Provider.of<Settings>(context).theme.portraitBlockedTextColor : Provider.of<Settings>(context).theme.mainTextColor)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: contact.isInvitation == true
                              ? Wrap(direction: Axis.vertical, children: <Widget>[
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    splashRadius: Material.defaultSplashRadius / 2,
                                    iconSize: 16,
                                    icon: Icon(
                                      Icons.favorite,
                                      color: Provider.of<Settings>(context).theme.mainTextColor,
                                    ),
                                    tooltip: AppLocalizations.of(context)!.tooltipAcceptContactRequest,
                                    onPressed: _btnApprove,
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    splashRadius: Material.defaultSplashRadius / 2,
                                    iconSize: 16,
                                    icon: Icon(Icons.delete, color: Provider.of<Settings>(context).theme.mainTextColor),
                                    tooltip: AppLocalizations.of(context)!.tooltipRejectContactRequest,
                                    onPressed: _btnReject,
                                  )
                                ])
                              : (contact.isBlocked != null && contact.isBlocked
                                  ? IconButton(
                                      padding: EdgeInsets.zero,
                                      splashRadius: Material.defaultSplashRadius / 2,
                                      iconSize: 16,
                                      icon: Icon(Icons.block, color: Provider.of<Settings>(context).theme.mainTextColor),
                                      onPressed: () {},
                                    )
                                  : Text(dateToNiceString(contact.lastMessageTime))),
                        ),
                      ],
                    ))),
          ]),
          onTap: () {
            selectConversation(context, contact.identifier);
          },
        ));
  }

  void _btnApprove() {
    Provider.of<ContactInfoState>(context, listen: false).accepted = true;
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .AcceptContact(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).identifier);
  }

  void _btnReject() {
    Provider.of<ContactInfoState>(context, listen: false).blocked = true;
    ContactInfoState contact = Provider.of<ContactInfoState>(context, listen: false);
    if (contact.isGroup == true) {
      // FIXME This flow is incorrect. Groups never just show up on the contact list anymore
      Provider.of<ProfileInfoState>(context, listen: false).removeContact(contact.onion);
    } else {
      Provider.of<FlwtchState>(context, listen: false).cwtch.BlockContact(Provider.of<ContactInfoState>(context, listen: false).profileOnion, contact.identifier);
    }
  }

  String dateToNiceString(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return AppLocalizations.of(context)!.conversationNotificationPolicyNever;
    }
    // If the last message was over a day ago, just state the date
    if (DateTime.now().difference(date).inDays > 1) {
      return DateFormat.yMd(Platform.localeName).format(date.toLocal());
    }
    // Otherwise just state the time.
    return DateFormat.Hm(Platform.localeName).format(date.toLocal());
  }
}

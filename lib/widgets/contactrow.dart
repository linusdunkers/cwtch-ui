import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:cwtch/views/messageview.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../model.dart';
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
    return Card(
        clipBehavior: Clip.antiAlias,
        color: Provider.of<AppState>(context).selectedConversation == contact.onion ? Provider.of<Settings>(context).theme.backgroundHilightElementColor() : null,
        borderOnForeground: false,
        child: InkWell(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Padding(
              padding: const EdgeInsets.all(2.0), //border size
              child: ProfileImage(
                  badgeCount: contact.unreadMessages,
                  badgeColor: Provider.of<Settings>(context).theme.portraitContactBadgeColor(),
                  badgeTextColor: Provider.of<Settings>(context).theme.portraitContactBadgeTextColor(),
                  diameter: 64.0,
                  imagePath: contact.imagePath,
                  maskOut: !contact.isOnline(),
                  border: contact.isOnline() ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : contact.isBlocked ? Provider.of<Settings>(context).theme.portraitBlockedBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor()),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.nickname, //(contact.isInvitation ? "invite " : "non-invite ") + (contact.isBlocked ? "blokt" : "nonblokt"),//

                          style: TextStyle(fontSize: Provider.of<Settings>(context).theme.contactOnionTextSize(),
                              color: contact.isBlocked ? Provider.of<Settings>(context).theme.portraitBlockedTextColor() : Provider.of<Settings>(context).theme.mainTextColor()), //Provider.of<FlwtchState>(context).biggerFont,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                        Text(contact.onion,
                          style: TextStyle(color: contact.isBlocked ? Provider.of<Settings>(context).theme.portraitBlockedTextColor() : Provider.of<Settings>(context).theme.mainTextColor())),
                      ],
                    ))),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: contact.isInvitation == true
                  ? Wrap(direction: Axis.vertical, children: <Widget>[
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: Icon(Icons.favorite, color: Provider.of<Settings>(context).theme.mainTextColor()),
                        onPressed: _btnApprove,
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: Icon(Icons.delete, color: Provider.of<Settings>(context).theme.mainTextColor()),
                        onPressed: _btnReject,
                      )
                    ])
                  : (contact.isBlocked != null && contact.isBlocked
                      ? IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 16,
                          icon: Icon(Icons.block, color: Provider.of<Settings>(context).theme.mainTextColor()),
                          onPressed: () {},
                        )
                      : Text(dateToNiceString(contact.lastMessageTime))),
            ),
          ]),
          onTap: () {
            setState(() {
              // requery instead of using contactinfostate directly because sometimes listview gets confused about data that resorts
              Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(contact.onion)!.unreadMessages = 0;
              // triggers update in Double/TripleColumnView
              Provider.of<AppState>(context, listen: false).selectedConversation = contact.onion;
              // if in singlepane mode, push to the stack
              var isLandscape = Provider.of<AppState>(context, listen: false).isLandscape(context);
              if (Provider.of<Settings>(context, listen: false).uiColumns(isLandscape).length == 1) _pushMessageView(contact.onion);
            });
          },
        ));
  }

  void _pushMessageView(String handle) {
    var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext builderContext) {
          // assert we have an actual profile...
          // We need to listen for updates to the profile in order to update things like invitation message bubbles.
          var profile = Provider.of<FlwtchState>(builderContext).profs.getProfile(profileOnion)!;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: profile),
              ChangeNotifierProvider.value(value: profile.contactList.getContact(handle)!),
            ],
            builder: (context, child) => MessageView(),
          );
        },
      ),
    );
  }

  void _btnApprove() {
    Provider.of<FlwtchState>(context, listen: false)
        .cwtch
        .AcceptContact(Provider.of<ContactInfoState>(context, listen: false).profileOnion, Provider.of<ContactInfoState>(context, listen: false).onion);
  }

  void _btnReject() {
    ContactInfoState contact = Provider.of<ContactInfoState>(context, listen: false);
    if (contact.isGroup == true) {
      Provider.of<FlwtchState>(context, listen: false).cwtch.RejectInvite(Provider.of<ContactInfoState>(context, listen: false).profileOnion, contact.onion);
      Provider.of<ProfileInfoState>(context, listen: false).removeContact(contact.onion);
    } else {
      Provider.of<FlwtchState>(context, listen: false).cwtch.BlockContact(Provider.of<ContactInfoState>(context, listen: false).profileOnion, contact.onion);
    }
  }

  String dateToNiceString(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return AppLocalizations.of(context)!.dateNever;
    }
    // If the last message was over a day ago, just state the date
    if (DateTime.now().difference(date).inDays > 1) {
      return DateFormat.yMd().format(date.toLocal());
    }
    // Otherwise just state the time.
    return DateFormat.Hm().format(date.toLocal());
  }
}

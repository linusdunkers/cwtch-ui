import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cwtch/views/addeditprofileview.dart';
import 'package:cwtch/views/contactsview.dart';
import 'package:cwtch/views/doublecolview.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../model.dart';
import '../settings.dart';

class ProfileRow extends StatefulWidget {
  @override
  _ProfileRowState createState() => _ProfileRowState();
}

class _ProfileRowState extends State<ProfileRow> {
  @override
  Widget build(BuildContext context) {
    var profile = Provider.of<ProfileInfoState>(context);
    return Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(0.0),
        child: InkWell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.all(6.0), //border size
                  child: ProfileImage(
                      badgeCount: 0,
                      badgeColor: Provider.of<Settings>(context).theme.portraitProfileBadgeColor(),
                      badgeTextColor: Provider.of<Settings>(context).theme.portraitProfileBadgeTextColor(),
                      diameter: 64.0,
                      imagePath: profile.imagePath,
                      border: profile.isOnline ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor())),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    profile.nickname,
                    semanticsLabel: profile.nickname,
                    style: Provider.of<FlwtchState>(context).biggerFont,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Visibility(
                      visible: !Provider.of<Settings>(context).streamerMode,
                      child: ExcludeSemantics(
                          child: Text(
                        profile.onion,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      )))
                ],
              )),
              IconButton(
                enableFeedback: true,
                tooltip: AppLocalizations.of(context)!.editProfile + " " + profile.nickname,
                icon: Icon(Icons.create, color: Provider.of<Settings>(context).current().mainTextColor()),
                onPressed: () {
                  _pushEditProfile(onion: profile.onion, displayName: profile.nickname, profileImage: profile.imagePath, encrypted: profile.isEncrypted);
                },
              )
            ],
          ),
          onTap: () {
            setState(() {
              var appState = Provider.of<AppState>(context, listen: false);
              appState.selectedProfile = profile.onion;
              appState.selectedConversation = null;

              _pushContactList(profile, appState.isLandscape(context)); //orientation == Orientation.landscape);
            });
          },
        ));
  }

  void _pushContactList(ProfileInfoState profile, bool isLandscape) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: "conversations"),
        builder: (BuildContext buildcontext) {
          return OrientationBuilder(builder: (orientationBuilderContext, orientation) {
            return MultiProvider(
                providers: [
                  ChangeNotifierProvider<ProfileInfoState>.value(value: profile),
                  ChangeNotifierProvider<ContactListState>.value(value: profile.contactList),
                ],
                builder: (innercontext, widget) {
                  var appState = Provider.of<AppState>(context);
                  var settings = Provider.of<Settings>(context);
                  return settings.uiColumns(appState.isLandscape(innercontext)).length > 1 ? DoubleColumnView() : ContactsView();
                });
          });
        },
      ),
    );
  }

  void _pushEditProfile({onion: "", displayName: "", profileImage: "", encrypted: true}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileInfoState>(
              create: (_) => ProfileInfoState(onion: onion, nickname: displayName, imagePath: profileImage, encrypted: encrypted),
            ),
          ],
          builder: (context, widget) => AddEditProfileView(),
        );
      },
    ));
  }
}

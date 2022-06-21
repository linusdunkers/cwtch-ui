import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contactlist.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/profilelist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cwtch/views/addeditprofileview.dart';
import 'package:cwtch/views/contactsview.dart';
import 'package:cwtch/views/doublecolview.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../errorHandler.dart';
import '../main.dart';
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
                      badgeCount: profile.unreadMessages,
                      badgeColor: Provider.of<Settings>(context).theme.portraitProfileBadgeColor,
                      badgeTextColor: Provider.of<Settings>(context).theme.portraitProfileBadgeTextColor,
                      diameter: 64.0,
                      imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment) ? profile.imagePath : profile.defaultImagePath,
                      border: profile.isOnline ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor)),
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
                splashRadius: Material.defaultSplashRadius / 2,
                tooltip: AppLocalizations.of(context)!.editProfile + " " + profile.nickname,
                icon: Icon(Icons.create, color: Provider.of<Settings>(context).current().mainTextColor),
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
      PageRouteBuilder(
        settings: RouteSettings(name: "conversations"),
        pageBuilder: (c, a1, a2) {
          return OrientationBuilder(builder: (orientationBuilderContext, orientation) {
            return MultiProvider(
                providers: [ChangeNotifierProvider<ProfileInfoState>.value(value: profile), ChangeNotifierProvider<ContactListState>.value(value: profile.contactList)],
                builder: (innercontext, widget) {
                  var appState = Provider.of<AppState>(context);
                  var settings = Provider.of<Settings>(context);
                  return settings.uiColumns(appState.isLandscape(innercontext)).length > 1 ? DoubleColumnView() : ContactsView();
                });
          });
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _pushEditProfile({onion: "", displayName: "", profileImage: "", encrypted: true}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (bcontext, a1, a2) {
          var profile = Provider.of<FlwtchState>(bcontext).profs.getProfile(onion)!;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ProfileInfoState>.value(
                value: profile,
              ),
            ],
            builder: (context, widget) => AddEditProfileView(),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }
}

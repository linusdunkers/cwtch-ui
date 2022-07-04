import 'dart:convert';
import 'dart:io';

import 'package:cwtch/constants.dart';
import 'package:cwtch/controllers/enter_password.dart';
import 'package:cwtch/controllers/filesharing.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/profilelist.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/views/torstatusview.dart';
import 'package:cwtch/widgets/passwordfield.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cwtch/widgets/profilerow.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../main.dart';
import '../torstatus.dart';
import 'addeditprofileview.dart';
import 'globalsettingsview.dart';
import 'serversview.dart';

class ProfileMgrView extends StatefulWidget {
  ProfileMgrView();

  @override
  _ProfileMgrViewState createState() => _ProfileMgrViewState();
}

class _ProfileMgrViewState extends State<ProfileMgrView> {
  final ctrlrPassword = TextEditingController();

  @override
  void dispose() {
    ctrlrPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(
      // Prevents Android back button from closing the app on the profile manager screen
      // (which would shutdown connections and all kinds of other expensive to generate things)
      builder: (context, settings, child) => WillPopScope(
          onWillPop: () async {
            _modalShutdown();
            return Provider.of<AppState>(context, listen: false).cwtchIsClosing;
          },
          child: Scaffold(
            key: Key("ProfileManagerView"),
            backgroundColor: settings.theme.backgroundMainColor,
            appBar: AppBar(
              title: Row(children: [
                Icon(
                  CwtchIcons.cwtch_knott,
                  size: 36,
                  color: settings.theme.mainTextColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Text(MediaQuery.of(context).size.width > 600 ? AppLocalizations.of(context)!.titleManageProfiles : AppLocalizations.of(context)!.titleManageProfilesShort,
                        style: TextStyle(color: settings.current().mainTextColor)))
              ]),
              actions: getActions(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _modalAddImportProfiles,
              tooltip: AppLocalizations.of(context)!.addNewProfileBtn,
              child: Icon(
                Icons.add,
                semanticLabel: AppLocalizations.of(context)!.addNewProfileBtn,
                color: Provider.of<Settings>(context).theme.defaultButtonTextColor,
              ),
            ),
            body: _buildProfileManager(),
          )),
    );
  }

  List<Widget> getActions() {
    List<Widget> actions = new List<Widget>.empty(growable: true);

    // Tor Status
    actions.add(IconButton(
      icon: TorIcon(),
      onPressed: _pushTorStatus,
      splashRadius: Material.defaultSplashRadius / 2,
      tooltip: Provider.of<TorStatus>(context).progress == 100
          ? AppLocalizations.of(context)!.networkStatusOnline
          : (Provider.of<TorStatus>(context).progress == 0 ? AppLocalizations.of(context)!.networkStatusDisconnected : AppLocalizations.of(context)!.networkStatusAttemptingTor),
    ));

    // Unlock Profiles
    actions.add(IconButton(
      icon: Icon(CwtchIcons.lock_open_24px),
      splashRadius: Material.defaultSplashRadius / 2,
      color: Provider.of<ProfileListState>(context).profiles.isEmpty ? Provider.of<Settings>(context).theme.defaultButtonColor : Provider.of<Settings>(context).theme.mainTextColor,
      tooltip: AppLocalizations.of(context)!.tooltipUnlockProfiles,
      onPressed: _modalUnlockProfiles,
    ));

    // Servers
    if (Provider.of<Settings>(context).isExperimentEnabled(ServerManagementExperiment) && !Platform.isAndroid && !Platform.isIOS) {
      actions.add(
          IconButton(icon: Icon(CwtchIcons.dns_black_24dp), splashRadius: Material.defaultSplashRadius / 2, tooltip: AppLocalizations.of(context)!.serversManagerTitleShort, onPressed: _pushServers));
    }

    // Global Settings
    actions.add(IconButton(
        key: Key("OpenSettingsView"),
        icon: Icon(Icons.settings),
        tooltip: AppLocalizations.of(context)!.tooltipOpenSettings,
        splashRadius: Material.defaultSplashRadius / 2,
        onPressed: _pushGlobalSettings));

    // shutdown cwtch
    actions.add(IconButton(icon: Icon(Icons.close), tooltip: AppLocalizations.of(context)!.shutdownCwtchTooltip, splashRadius: Material.defaultSplashRadius / 2, onPressed: _modalShutdown));

    return actions;
  }

  void _modalShutdown() {
    Provider.of<FlwtchState>(context, listen: false).modalShutdown(MethodCall(""));
  }

  void _pushGlobalSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (bcontext, a1, a2) {
          return Provider(
            create: (_) => Provider.of<FlwtchState>(bcontext, listen: false),
            child: GlobalSettingsView(),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _pushServers() {
    Navigator.of(context).push(
      PageRouteBuilder(
        settings: RouteSettings(name: "servers"),
        pageBuilder: (bcontext, a1, a2) {
          return MultiProvider(
            providers: [Provider.value(value: Provider.of<FlwtchState>(context))],
            child: ServersView(),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _pushTorStatus() {
    Navigator.of(context).push(
      PageRouteBuilder(
        settings: RouteSettings(name: "torconfig"),
        pageBuilder: (bcontext, a1, a2) {
          return MultiProvider(
            providers: [Provider.value(value: Provider.of<FlwtchState>(context))],
            child: TorStatusView(),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _pushAddProfile(bcontext, {onion: ""}) {
    Navigator.popUntil(bcontext, (route) => route.isFirst);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (bcontext, a1, a2) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ProfileInfoState>(
                create: (_) => ProfileInfoState(onion: onion),
              ),
            ],
            builder: (context, widget) => AddEditProfileView(key: Key('addprofile')),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _modalAddImportProfiles() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: RepaintBoundary(
                  child: Container(
                height: Platform.isAndroid ? 250 : 200, // bespoke value courtesy of the [TextField] docs
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                                child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(399, 20),
                                maximumSize: Size(400, 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(180), right: Radius.circular(180))),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.addProfileTitle,
                                semanticsLabel: AppLocalizations.of(context)!.addProfileTitle,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                _pushAddProfile(context);
                              },
                            )),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                                child: Tooltip(
                                    message: AppLocalizations.of(context)!.importProfileTooltip,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(399, 20),
                                        maximumSize: Size(400, 20),
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(color: Provider.of<Settings>(context).theme.defaultButtonActiveColor, width: 2.0),
                                            borderRadius: BorderRadius.horizontal(left: Radius.circular(180), right: Radius.circular(180))),
                                        primary: Provider.of<Settings>(context).theme.backgroundMainColor,
                                      ),
                                      child:
                                          Text(AppLocalizations.of(context)!.importProfile, semanticsLabel: AppLocalizations.of(context)!.importProfile, style: TextStyle(color: Provider.of<Settings>(context).theme.mainTextColor, fontWeight: FontWeight.bold)),
                                      onPressed: () {
                                        // 10GB profiles should be enough for anyone?
                                        showFilePicker(context, MaxGeneralFileSharingSize, (file) {
                                          showPasswordDialog(context, AppLocalizations.of(context)!.importProfile, AppLocalizations.of(context)!.importProfile, (password) {
                                            Navigator.popUntil(context, (route) => route.isFirst);
                                            Provider.of<FlwtchState>(context, listen: false).cwtch.ImportProfile(file.path, password).then((value) {
                                              if (value == "") {
                                                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.successfullyImportedProfile.replaceFirst("%profile", file.path)));
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              } else {
                                                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.failedToImportProfile));
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              }
                                            });
                                          });
                                        }, () {}, () {});
                                      },
                                    ))),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ))),
              )));
        });
  }

  void _modalUnlockProfiles() {
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: RepaintBoundary(
                  child: Container(
                height: Platform.isAndroid ? 250 : 200, // bespoke value courtesy of the [TextField] docs
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(AppLocalizations.of(context)!.enterProfilePassword),
                            SizedBox(
                              height: 20,
                            ),
                            CwtchPasswordField(
                              key: Key("unlockPasswordProfileElement"),
                              autofocus: true,
                              controller: ctrlrPassword,
                              action: unlock,
                              validator: (value) {},
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              Spacer(),
                              Expanded(
                                  child: ElevatedButton(
                                child: Text(AppLocalizations.of(context)!.unlock, semanticsLabel: AppLocalizations.of(context)!.unlock),
                                onPressed: () {
                                  unlock(ctrlrPassword.value.text);
                                },
                              )),
                              Spacer()
                            ]),
                          ],
                        ))),
              )));
        });
  }

  void unlock(String password) {
    Provider.of<FlwtchState>(context, listen: false).cwtch.LoadProfiles(password);
    ctrlrPassword.text = "";
    Navigator.pop(context);
  }

  Widget _buildProfileManager() {
    return Consumer<ProfileListState>(
      builder: (context, pls, child) {
        final tiles = pls.profiles.map(
          (ProfileInfoState profile) {
            return ChangeNotifierProvider<ProfileInfoState>.value(
              value: profile,
              builder: (context, child) => RepaintBoundary(child: ProfileRow()),
            );
          },
        );

        final divided = ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList();

        if (tiles.isEmpty) {
          return Center(
              child: Text(
            AppLocalizations.of(context)!.unlockProfileTip,
            textAlign: TextAlign.center,
          ));
        }

        return ListView(children: divided);
      },
    );
  }
}

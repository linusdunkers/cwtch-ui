import 'dart:convert';
import 'dart:io';

import 'package:cwtch/cwtch_icons_icons.dart';
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
import '../model.dart';
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
            backgroundColor: settings.theme.backgroundMainColor(),
            appBar: AppBar(
              title: Row(children: [
                Icon(
                  CwtchIcons.cwtch_knott,
                  size: 36,
                  color: settings.theme.mainTextColor(),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(child: Text(MediaQuery.of(context).size.width > 600 ?
                    AppLocalizations.of(context)!.titleManageProfiles : AppLocalizations.of(context)!.titleManageProfilesShort,
                    style: TextStyle(color: settings.current().mainTextColor())))
              ]),
              actions: getActions(),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: _pushAddProfile,
              tooltip: AppLocalizations.of(context)!.addNewProfileBtn,
              child: Icon(
                Icons.add,
                semanticLabel: AppLocalizations.of(context)!.addNewProfileBtn,
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
      tooltip: Provider.of<TorStatus>(context).progress == 100
          ? AppLocalizations.of(context)!.networkStatusOnline
          : (Provider.of<TorStatus>(context).progress == 0 ? AppLocalizations.of(context)!.networkStatusDisconnected : AppLocalizations.of(context)!.networkStatusAttemptingTor),
    ));

    // Only show debug button on development builds

    // Unlock Profiles
    actions.add(IconButton(
      icon: Icon(CwtchIcons.lock_open_24px),
      color: Provider.of<ProfileListState>(context).profiles.isEmpty ? Provider.of<Settings>(context).theme.defaultButtonColor() : Provider.of<Settings>(context).theme.mainTextColor(),
      tooltip: AppLocalizations.of(context)!.tooltipUnlockProfiles,
      onPressed: _modalUnlockProfiles,
    ));

    // Servers
    if (Provider.of<Settings>(context).isExperimentEnabled(ServerManagementExperiment) && !Platform.isAndroid && !Platform.isIOS) {
      actions.add(IconButton(icon: Icon(CwtchIcons.dns_black_24dp), tooltip: AppLocalizations.of(context)!.serversManagerTitleShort, onPressed: _pushServers));
    }

    // Global Settings
    actions.add(IconButton(icon: Icon(Icons.settings), tooltip: AppLocalizations.of(context)!.tooltipOpenSettings, onPressed: _pushGlobalSettings));

    // shutdown cwtch
    actions.add(IconButton(icon: Icon(Icons.close), tooltip: AppLocalizations.of(context)!.shutdownCwtchTooltip, onPressed: _modalShutdown));

    return actions;
  }

  void _modalShutdown() {
    Provider.of<FlwtchState>(context, listen: false).modalShutdown(MethodCall(""));
  }

  void _pushGlobalSettings() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return Provider(
          create: (_) => Provider.of<FlwtchState>(context, listen: false),
          child: GlobalSettingsView(),
        );
      },
    ));
  }

  void _pushServers() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: "servers"),
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [Provider.value(value: Provider.of<FlwtchState>(context))],
          child: ServersView(),
        );
      },
    ));
  }

  void _pushTorStatus() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [Provider.value(value: Provider.of<FlwtchState>(context))],
          child: TorStatusView(),
        );
      },
    ));
  }

  void _pushAddProfile({onion: ""}) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileInfoState>(
              create: (_) => ProfileInfoState(onion: onion),
            ),
          ],
          builder: (context, widget) => AddEditProfileView(key: Key('addprofile')),
        );
      },
    ));
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
                height: 200, // bespoke value courtesy of the [TextField] docs
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

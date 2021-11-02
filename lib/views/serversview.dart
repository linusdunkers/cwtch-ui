import 'package:cwtch/models/servers.dart';
import 'package:cwtch/views/addeditservers.dart';
import 'package:cwtch/widgets/passwordfield.dart';
import 'package:cwtch/widgets/serverrow.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/torstatus.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cwtch_icons_icons.dart';
import '../main.dart';
import '../settings.dart';

///
class ServersView extends StatefulWidget {
  @override
  _ServersView createState() => _ServersView();
}

class _ServersView extends State<ServersView> {
  final ctrlrPassword = TextEditingController();

  @override
  void dispose() {
    ctrlrPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( MediaQuery.of(context).size.width > 600 ? AppLocalizations.of(context)!.serversManagerTitleLong : AppLocalizations.of(context)!.serversManagerTitleShort),
        actions: getActions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddServer,
        tooltip: AppLocalizations.of(context)!.addServerTooltip,
        child: Icon(
          Icons.add,
          semanticLabel: AppLocalizations.of(context)!.addServerTooltip,
        ),
      ),
      body: Consumer<ServerListState>(
        builder: (context, svrs, child) {
          final tiles = svrs.servers.map((ServerInfoState server) {
            return ChangeNotifierProvider<ServerInfoState>.value(
              value: server,
              builder: (context, child) => RepaintBoundary(child: ServerRow()),
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
              AppLocalizations.of(context)!.unlockServerTip,
            textAlign: TextAlign.center,
          ));
        }

        return ListView(children: divided);
      },
    ));
  }

  List<Widget> getActions() {
    List<Widget> actions = new List<Widget>.empty(growable: true);

    // Unlock Profiles
    actions.add(IconButton(
      icon: Icon(CwtchIcons.lock_open_24px),
      color: Provider.of<ServerListState>(context).servers.isEmpty ? Provider.of<Settings>(context).theme.defaultButtonColor() : Provider.of<Settings>(context).theme.mainTextColor(),
      tooltip: AppLocalizations.of(context)!.tooltipUnlockProfiles,
      onPressed: _modalUnlockServers,
    ));

    return actions;
  }

  void _modalUnlockServers() {
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
                                Text(AppLocalizations.of(context)!.enterServerPassword),
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
    Provider.of<FlwtchState>(context, listen: false).cwtch.LoadServers(password);
    ctrlrPassword.text = "";
    Navigator.pop(context);
  }

  void _pushAddServer() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [ChangeNotifierProvider<ServerInfoState>(
        create: (_) => ServerInfoState(onion: "", serverBundle: "", description: "", autoStart: true, running: false, isEncrypted: true),
        )],
            //ChangeNotifierProvider.value(value: Provider.of<ServerInfoState>(context))],
          child: AddEditServerView(),
        );
      },
    ));
  }
}

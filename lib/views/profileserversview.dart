import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/widgets/remoteserverrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../model.dart';


class ProfileServersView extends StatefulWidget {
  @override
  _ProfileServersView createState() => _ProfileServersView();
}

class _ProfileServersView extends State<ProfileServersView> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(MediaQuery
              .of(context)
              .size
              .width > 600 ? AppLocalizations.of(context)!.serversManagerTitleLong : AppLocalizations.of(context)!.serversManagerTitleShort),
          //actions: getActions(),
        ),
        body: Consumer<ProfileServerListState>(
          builder: (context, servers, child) {
            final tiles = servers.servers.map((RemoteServerInfoState server) {
              return ChangeNotifierProvider<RemoteServerInfoState>.value(
                value: server,
                builder: (context, child) => RepaintBoundary(child: RemoteServerRow()),
              );
            },
            );

            final divided = ListTile.divideTiles(
              context: context,
              tiles: tiles,
            ).toList();

            // TODO: add import row from global servers
            divided.insert(0, Row( children: [Text("Import server from global list if any")]));

            return ListView(children: divided);
          },
        ));
  }



}
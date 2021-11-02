import 'package:cwtch/models/servers.dart';
import 'package:cwtch/views/addeditservers.dart';
import 'package:cwtch/widgets/serverrow.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/torstatus.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

///
class ServersView extends StatefulWidget {
  @override
  _ServersView createState() => _ServersView();
}

class _ServersView extends State<ServersView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Servers you host"), //AppLocalizations.of(context)!.torNetworkStatus),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pushAddServer,
        tooltip: "Add new Server", //AppLocalizations.of(context)!.addNewProfileBtn,
        child: Icon(
          Icons.add,
          semanticLabel: "Add new Server", //AppLocalizations.of(context)!.addNewProfileBtn,
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
          return const Center(
            child: const Text(
              "Please create or unlock a server to begin!",
            textAlign: TextAlign.center,
          ));
        }

        return ListView(children: divided);
      },
    ));
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

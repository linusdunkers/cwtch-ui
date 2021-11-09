import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
          title: Text( MediaQuery.of(context).size.width > 600 ? AppLocalizations.of(context)!.serversManagerTitleLong : AppLocalizations.of(context)!.serversManagerTitleShort),
          //actions: getActions(),
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
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/models/remoteserver.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/widgets/remoteserverrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../cwtch_icons_icons.dart';
import '../main.dart';
import '../settings.dart';

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
    var knownServers = Provider.of<ProfileInfoState>(context).serverList.servers.map<String>((RemoteServerInfoState remoteServer) {
      return remoteServer.onion + ".onion";
    }).toSet();
    var importServerList = Provider.of<ServerListState>(context).servers.where((server) => !knownServers.contains(server.onion)).map<DropdownMenuItem<String>>((ServerInfoState serverInfo) {
      return DropdownMenuItem<String>(
        value: serverInfo.onion,
        child: Text(
          serverInfo.description.isNotEmpty ? serverInfo.description : serverInfo.onion,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList();

    importServerList.insert(0, DropdownMenuItem<String>(value: "", child: Text(AppLocalizations.of(context)!.importLocalServerSelectText)));

    return Scaffold(
        appBar: AppBar(
          title: Text(MediaQuery.of(context).size.width > 600 ? AppLocalizations.of(context)!.manageKnownServersLong : AppLocalizations.of(context)!.manageKnownServersShort),
        ),
        body: Consumer<ProfileInfoState>(
          builder: (context, profile, child) {
            ProfileServerListState servers = profile.serverList;
            final tiles = servers.servers.map(
              (RemoteServerInfoState server) {
                return ChangeNotifierProvider<RemoteServerInfoState>.value(
                  value: server,
                  builder: (context, child) => RemoteServerRow(),
                );
              },
            );

            final divided = ListTile.divideTiles(
              context: context,
              tiles: tiles,
            ).toList();

            final importCard = Card(
                child: ListTile(
                    title: Text(AppLocalizations.of(context)!.importLocalServerLabel),
                    leading: Icon(CwtchIcons.add_circle_24px, color: Provider.of<Settings>(context).current().mainTextColor),
                    trailing: DropdownButton(
                      onChanged: (String? importServer) {
                        if (importServer!.isNotEmpty) {
                          var server = Provider.of<ServerListState>(context).getServer(importServer)!;
                          showImportConfirm(context, profile.onion, server.onion, server.description, server.serverBundle);
                        }
                      },
                      value: "",
                      items: importServerList,
                    )));

            return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return Scrollbar(
                  isAlwaysShown: true,
                  child: SingleChildScrollView(
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 10),
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 10),
                          child: Column(children: [if (importServerList.length > 1) importCard, Column(children: divided)]))));
            });

            return ListView(children: divided);
          },
        ));
  }

  showImportConfirm(BuildContext context, String profileHandle, String serverHandle, String serverDesc, String bundle) {
    var serverLabel = serverDesc.isNotEmpty ? serverDesc : serverHandle;
    serverHandle = serverHandle.substring(0, serverHandle.length - 6); // remove '.onion'
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(AppLocalizations.of(context)!.cancel),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    );
    Widget continueButton = ElevatedButton(
        child: Text(AppLocalizations.of(context)!.importLocalServerButton.replaceAll("%1", serverLabel)),
        onPressed: () {
          Provider.of<FlwtchState>(context, listen: false).cwtch.ImportBundle(profileHandle, bundle);
          // Wait 500ms and hope the server is imported and add it's description in the UI and as an attribute
          Future.delayed(const Duration(milliseconds: 500), () {
            var profile = Provider.of<ProfileInfoState>(context);
            if (profile.serverList.getServer(serverHandle) != null) {
              profile.serverList.getServer(serverHandle)?.updateDescription(serverDesc);

              Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profile.onion, profile.serverList.getServer(serverHandle)!.identifier, "server.description", serverDesc);
            }
          });
          Navigator.of(context).pop();
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.importLocalServerButton.replaceAll("%1", serverLabel)),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

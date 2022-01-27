import 'package:cwtch/main.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/views/addeditservers.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cwtch_icons_icons.dart';
import '../errorHandler.dart';
import '../settings.dart';

class ServerRow extends StatefulWidget {
  @override
  _ServerRowState createState() => _ServerRowState();
}

class _ServerRowState extends State<ServerRow> {
  @override
  Widget build(BuildContext context) {
    var server = Provider.of<ServerInfoState>(context);
    return Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(0.0),
        child: InkWell(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(
                  padding: const EdgeInsets.all(6.0), //border size
                  child: Icon(CwtchIcons.dns_24px,
                      color: server.running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor, size: 64)),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    server.description,
                    semanticsLabel: server.description,
                    style: Provider.of<FlwtchState>(context)
                        .biggerFont
                        .apply(color: server.running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Visibility(
                      visible: !Provider.of<Settings>(context).streamerMode,
                      child: ExcludeSemantics(
                          child: Text(
                        server.onion,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: server.running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor),
                      )))
                ],
              )),

              // Copy server button
              IconButton(
                enableFeedback: true,
                splashRadius: Material.defaultSplashRadius / 2,
                tooltip: AppLocalizations.of(context)!.copyServerKeys,
                icon: Icon(CwtchIcons.address_copy_2, color: Provider.of<Settings>(context).current().mainTextColor),
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: server.serverBundle));
                },
              ),

              // Edit button
              IconButton(
                enableFeedback: true,
                splashRadius: Material.defaultSplashRadius / 2,
                tooltip: AppLocalizations.of(context)!.editServerTitle,
                icon: Icon(Icons.create, color: Provider.of<Settings>(context).current().mainTextColor),
                onPressed: () {
                  _pushEditServer(server);
                },
              )
            ]),
            onTap: () {
              _pushEditServer(server);
            }));
  }

  void _pushEditServer(ServerInfoState server) {
    Provider.of<ErrorHandler>(context).reset();
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: "serveraddedit"),
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<ServerInfoState>(
              create: (_) => server,
            )
          ],
          child: AddEditServerView(),
        );
      },
    ));
  }
}

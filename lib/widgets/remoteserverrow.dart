import 'package:cwtch/main.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/views/addeditservers.dart';
import 'package:cwtch/views/remoteserverview.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../cwtch_icons_icons.dart';
import '../errorHandler.dart';
import '../model.dart';
import '../settings.dart';

class RemoteServerRow extends StatefulWidget {
  @override
  _RemoteServerRowState createState() => _RemoteServerRowState();
}

class _RemoteServerRowState extends State<RemoteServerRow> {
  @override
  Widget build(BuildContext context) {
    var server = Provider.of<RemoteServerInfoState>(context);
    var description = server.description.isNotEmpty ?  server.description : server.onion;
    var running = server.status == "Synced";
    return Card(clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.all(0.0),
        child: InkWell(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(6.0), //border size
                      child: Icon(CwtchIcons.dns_24px,
                          color: running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor(),
                          size: 64)

                  ),
                  Expanded(
                      child: Column(
                        children: [
                          Text(
                            description,
                            semanticsLabel: description,
                            style: Provider.of<FlwtchState>(context).biggerFont.apply(color: running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor()),
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
                                    style: TextStyle(color: running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor() : Provider.of<Settings>(context).theme.portraitOfflineBorderColor()),
                                  )))
                        ],
                      )),

                ]),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: "remoteserverview"),
                    builder: (BuildContext context) {
                      return MultiProvider(
                        providers: [ChangeNotifierProvider(create: (context) => server), Provider.value(value: Provider.of<FlwtchState>(context))],
                        child: RemoteServerView(),
                      );
                    }));
                }
        ));
  }

}
import 'package:cwtch/main.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/models/remoteserver.dart';
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
import '../settings.dart';

class RemoteServerRow extends StatefulWidget {
  @override
  _RemoteServerRowState createState() => _RemoteServerRowState();
}

class _RemoteServerRowState extends State<RemoteServerRow> {
  @override
  Widget build(BuildContext context) {
    var server = Provider.of<RemoteServerInfoState>(context);
    var description = server.description.isNotEmpty ? server.description : server.onion;
    var running = server.status == "Synced";
    return Consumer<ProfileInfoState>(builder: (context, profile, child) {
      return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(0.0),
          child: InkWell(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Padding(
                    padding: const EdgeInsets.all(6.0), //border size
                    child: Row(children: [
                      Icon(CwtchIcons.dns_24px,
                          color: running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor, size: 64),
                      Visibility(
                          visible: !running,
                          child: Icon(
                            CwtchIcons.negative_heart_24px,
                            color: Provider.of<Settings>(context).theme.portraitOfflineBorderColor,
                          )),
                    ])),
                Expanded(
                    child: Column(
                  children: [
                    Text(
                      description,
                      semanticsLabel: description,
                      style: Provider.of<FlwtchState>(context)
                          .biggerFont
                          .apply(color: running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor),
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
                          style: TextStyle(color: running ? Provider.of<Settings>(context).theme.portraitOnlineBorderColor : Provider.of<Settings>(context).theme.portraitOfflineBorderColor),
                        ))),
                    Visibility(
                        visible: server.status == "Authenticated",
                        child: LinearProgressIndicator(
                          color: Provider.of<Settings>(context).theme.defaultButtonActiveColor,
                          backgroundColor: Provider.of<Settings>(context).theme.defaultButtonDisabledColor,
                          value: server.syncProgress,
                        )),
                  ],
                )),
              ]),
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    settings: RouteSettings(name: "remoteserverview"),
                    pageBuilder: (bcontext, a1, a2) {
                      return MultiProvider(
                        providers: [Provider.value(value: profile), ChangeNotifierProvider(create: (context) => server), Provider.value(value: Provider.of<FlwtchState>(context))],
                        child: RemoteServerView(),
                      );
                    },
                    transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                    transitionDuration: Duration(milliseconds: 200),
                  ),
                );
              }));
    });
  }
}

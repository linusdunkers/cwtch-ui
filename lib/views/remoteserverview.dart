import 'dart:convert';
import 'package:cwtch/cwtch/cwtch.dart';
import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/widgets/buttontextfield.dart';
import 'package:cwtch/widgets/contactrow.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:cwtch/widgets/passwordfield.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../errorHandler.dart';
import '../main.dart';
import '../config.dart';
import '../model.dart';

/// Pane to add or edit a server
class RemoteServerView extends StatefulWidget {
  const RemoteServerView();

  @override
  _RemoteServerViewState createState() => _RemoteServerViewState();
}

class _RemoteServerViewState extends State<RemoteServerView> {
  final _formKey = GlobalKey<FormState>();

  final ctrlrDesc = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    var serverInfoState = Provider.of<RemoteServerInfoState>(context, listen: false);
    if (serverInfoState.description.isNotEmpty) {
      ctrlrDesc.text = serverInfoState.description;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<ProfileInfoState, RemoteServerInfoState, Settings>(builder: (context, profile, serverInfoState, settings, child) {
      return Scaffold(
          appBar: AppBar(title: Text(ctrlrDesc.text.isNotEmpty ? ctrlrDesc.text : serverInfoState.onion)),
          body: Container(
              margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: 20,
                ),
                CwtchLabel(label: AppLocalizations.of(context)!.serverAddress),
                SizedBox(
                  height: 20,
                ),
                SelectableText(serverInfoState.onion),

                // Description
                SizedBox(
                  height: 20,
                ),
                CwtchLabel(label: AppLocalizations.of(context)!.serverDescriptionLabel),
                Text(AppLocalizations.of(context)!.serverDescriptionDescription),
                SizedBox(
                  height: 20,
                ),
                CwtchButtonTextField(
                  controller: ctrlrDesc,
                  readonly: false,
                  tooltip: AppLocalizations.of(context)!.saveBtn,
                  labelText: AppLocalizations.of(context)!.fieldDescriptionLabel,
                  icon: Icon(Icons.save),
                  onPressed: () {
                    Provider.of<FlwtchState>(context, listen: false).cwtch.SetConversationAttribute(profile.onion, serverInfoState.identifier, "server.description", ctrlrDesc.text);
                    serverInfoState.updateDescription(ctrlrDesc.text);
                  },
                ),

                SizedBox(
                  height: 20,
                ),

                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(AppLocalizations.of(context)!.groupsOnThisServerLabel),
                ),
                Expanded(child: _buildGroupsList(serverInfoState))
              ])));
    });
  }

  Widget _buildGroupsList(RemoteServerInfoState serverInfoState) {
    final tiles = serverInfoState.groups.map(
      (ContactInfoState group) {
        return ChangeNotifierProvider<ContactInfoState>.value(
          value: group,
          builder: (context, child) => RepaintBoundary(child: _buildGroupRow(group)), // ServerRow()),
        );
      },
    );

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    var size = MediaQuery.of(context).size;

    int cols = ((size.width - 50) / 500).ceil();
    final double itemHeight = 60; // magic arbitary
    final double itemWidth = (size.width - 50 /* magic padding guess */) / cols;

    return GridView.count(crossAxisCount: cols, childAspectRatio: (itemWidth / itemHeight), children: divided);
  }

  Widget _buildGroupRow(ContactInfoState group) {
    return Padding(
        padding: const EdgeInsets.all(6.0), //border size
        child: Column(children: [
          Text(
            group.nickname,
            style: Provider.of<FlwtchState>(context).biggerFont.apply(color: Provider.of<Settings>(context).theme.portraitOnlineBorderColor()),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          Visibility(
              visible: !Provider.of<Settings>(context).streamerMode,
              child: ExcludeSemantics(
                  child: Text(
                group.onion,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Provider.of<Settings>(context).theme.portraitOnlineBorderColor()),
              )))
        ]));
  }
}

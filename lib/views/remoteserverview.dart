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
    return Consumer2<RemoteServerInfoState, Settings>(builder: (context, serverInfoState, settings, child) {
      return Scaffold(
        appBar: AppBar(
            title: Text(ctrlrDesc.text.isNotEmpty ? ctrlrDesc.text : serverInfoState.onion)
        ),
        body: LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return Scrollbar(
              isAlwaysShown: true,
              child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                      ),
                      child: Form(
                          key: _formKey,
                          child: Container(
                              margin: EdgeInsets.fromLTRB(30, 0, 30, 10),
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [

                                    Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      SizedBox(
                                        height: 20,
                                      ),
                                      CwtchLabel(label: AppLocalizations.of(context)!.serverAddress),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SelectableText(
                                          serverInfoState.onion
                                      )
                                    ]),

                                    // Description
                                    Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                        tooltip: "Save", //TODO localize
                                        labelText: "Description", // TODO localize
                                        icon: Icon(Icons.save),
                                        onPressed: () {
                                          // TODO save
                                        },
                                      )
                                    ]),

                                    Text("Groups on this server"),
                                    _buildGroupsList(serverInfoState),

                                  ]))))));
        }),);
    });
  }

  Widget _buildGroupsList(RemoteServerInfoState serverInfoState) {
    print("groups: ${serverInfoState.groups} lenMethod: ${serverInfoState.groupsLen} len: ${serverInfoState.groups.length}");
    final tiles = serverInfoState.groups.map((ContactInfoState group) {
      print("building group tile for ${group.onion}");
      return ChangeNotifierProvider<ContactInfoState>.value(key: ValueKey(group.profileOnion + "" + group.onion), value: group, builder: (_, __) => RepaintBoundary(child: _buildGroupRow(group)));
    });
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return RepaintBoundary(child: ListView(children: divided));
  }

  void _savePressed() {

    var server = Provider.of<ServerInfoState>(context, listen: false);

    Provider.of<FlwtchState>(context, listen: false)
        .cwtch.SetServerAttribute(server.onion, "description", ctrlrDesc.text);
    server.setDescription(ctrlrDesc.text);


    if (_formKey.currentState!.validate()) {
      // TODO support change password
    }
    Navigator.of(context).pop();
  }

  Widget _buildGroupRow(ContactInfoState group) {
    return Column(
      children: [
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
      ],
    );
  }

}


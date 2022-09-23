import 'dart:convert';

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/remoteserver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cwtch/errorHandler.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/settings.dart';
import 'package:cwtch/widgets/buttontextfield.dart';
import 'package:cwtch/widgets/cwtchlabel.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../main.dart';

/// Add Contact View is the one-stop shop for adding public keys to a Profiles contact list.
/// We support both Peers and Groups (experiment-pending).
/// NOTE: This view makes use of the global Error Handler to receive events from the Cwtch Library (for validating
/// error states caused by incorrect import string or duplicate requests to add a specific contact)
class AddContactView extends StatefulWidget {
  final newGroup;

  const AddContactView({Key? key, this.newGroup}) : super(key: key);

  @override
  _AddContactViewState createState() => _AddContactViewState();
}

class _AddContactViewState extends State<AddContactView> {
  final _formKey = GlobalKey<FormState>();
  final _createGroupFormKey = GlobalKey<FormState>();
  final ctrlrOnion = TextEditingController(text: "");
  final ctrlrContact = TextEditingController(text: "");
  final ctrlrGroupName = TextEditingController(text: "");
  String server = "";
  // flutter textfield onChange often fires twice and since we need contexts, we can't easily use a controler/listener
  String lastContactValue = "";
  bool failedImport = false;

  @override
  Widget build(BuildContext context) {
    //  if we haven't picked a server yet, pick the first one in the list...
    if (server.isEmpty && Provider.of<ProfileInfoState>(context).serverList.servers.isNotEmpty) {
      server = Provider.of<ProfileInfoState>(context).serverList.servers.first.onion;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleManageContacts),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    ctrlrOnion.text = Provider.of<ProfileInfoState>(context).onion;

    /// We display a different number of tabs depending on the experiment setup
    bool groupsEnabled = Provider.of<Settings>(context, listen: false).isExperimentEnabled(TapirGroupsExperiment);
    return Consumer<ErrorHandler>(builder: (bcontext, globalErrorHandler, child) {
      return DefaultTabController(
          initialIndex: widget.newGroup && groupsEnabled ? 1 : 0,
          length: groupsEnabled ? 2 : 1,
          child: Column(children: [
            (groupsEnabled ? getTabBarWithGroups() : getTabBarWithAddPeerOnly()),
            Expanded(
                child: TabBarView(
              children: (groupsEnabled
                  ? [
                      addPeerTab(bcontext),
                      addGroupTab(bcontext),
                    ]
                  : [addPeerTab(bcontext)]),
            )),
          ]));
    });
  }

  void _copyOnion() {
    Clipboard.setData(new ClipboardData(text: Provider.of<ProfileInfoState>(context, listen: false).onion));
    final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboardNotification));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// A Tab Bar with only the Add Peer Tab
  TabBar getTabBarWithAddPeerOnly() {
    return TabBar(
      tabs: [
        Tab(
          icon: Icon(CwtchIcons.add_peer),
          text: AppLocalizations.of(context)!.addPeer,
        ),
      ],
    );
  }

  /// The full tab bar with Join and Add Groups
  TabBar getTabBarWithGroups() {
    return TabBar(
      tabs: [
        Tab(
          icon: Icon(CwtchIcons.add_peer),
          text: AppLocalizations.of(context)!.tooltipAddContact,
        ),
        //Tab(icon: Icon(Icons.backup), text: AppLocalizations.of(context)!.titleManageServers),
        Tab(icon: Icon(CwtchIcons.add_group), text: AppLocalizations.of(context)!.createGroup),
      ],
    );
  }

  /// The Add Peer Tab allows a peer to add a specific non-group peer to their contact lists
  /// We also provide a convenient way to copy their onion.
  Widget addPeerTab(bcontext) {
    return Scrollbar(
        child: SingleChildScrollView(
            clipBehavior: Clip.antiAlias,
            child: Container(
                margin: EdgeInsets.all(30),
                padding: EdgeInsets.all(20),
                child: Form(
                    autovalidateMode: AutovalidateMode.always,
                    key: _formKey,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      CwtchLabel(label: AppLocalizations.of(context)!.profileOnionLabel),
                      SizedBox(
                        height: 20,
                      ),
                      CwtchButtonTextField(
                        controller: ctrlrOnion,
                        onPressed: _copyOnion,
                        readonly: true,
                        icon: Icon(
                          CwtchIcons.address_copy,
                          size: 32,
                        ),
                        tooltip: AppLocalizations.of(context)!.copyBtn,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      CwtchLabel(label: AppLocalizations.of(context)!.pasteAddressToAddContact),
                      SizedBox(
                        height: 20,
                      ),
                      CwtchTextField(
                        testKey: Key("txtAddP2P"),
                        key: Key("txtAddP2P"),
                        controller: ctrlrContact,
                        validator: (value) {
                          if (value == "") {
                            return null;
                          }
                          if (failedImport) {
                            return AppLocalizations.of(context)!.invalidImportString;
                          }
                          return null;
                        },
                        onChanged: (String importBundle) async {
                          if (lastContactValue != importBundle) {
                            lastContactValue = importBundle;
                            var profileOnion = Provider.of<ProfileInfoState>(bcontext, listen: false).onion;
                            Provider.of<FlwtchState>(bcontext, listen: false).cwtch.ImportBundle(profileOnion, importBundle.replaceFirst("cwtch:", "")).then((result) {
                              if (result == "importBundle.success") {
                                failedImport = false;
                                if (AppLocalizations.of(bcontext) != null) {
                                  final snackBar = SnackBar(content: Text(AppLocalizations.of(bcontext)!.successfullAddedContact + importBundle));
                                  ScaffoldMessenger.of(bcontext).showSnackBar(snackBar);
                                  Navigator.popUntil(bcontext, (route) => route.settings.name == "conversations");
                                }
                              } else {
                                failedImport = true;
                              }
                            });
                          }
                        },
                        hintText: '',
                      )
                    ])))));
  }

  /// TODO Add Group Pane
  Widget addGroupTab(bcontext) {
    // TODO We should replace with with a "Paste in Server Key Bundle"
    if (Provider.of<ProfileInfoState>(bcontext).serverList.servers.isEmpty) {
      return Text(AppLocalizations.of(bcontext)!.addServerFirst);
    }

    return Scrollbar(
        child: SingleChildScrollView(
            clipBehavior: Clip.antiAlias,
            child: Container(
                margin: EdgeInsets.all(30),
                padding: EdgeInsets.all(20),
                child: Form(
                    autovalidateMode: AutovalidateMode.always,
                    key: _createGroupFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CwtchLabel(label: AppLocalizations.of(context)!.server),
                        SizedBox(
                          height: 20,
                        ),
                        DropdownButton(
                            onChanged: (String? newServer) {
                              setState(() {
                                server = newServer!;
                              });
                            },
                            isExpanded: true, // magic property
                            value: server,
                            items: Provider.of<ProfileInfoState>(bcontext).serverList.servers.map<DropdownMenuItem<String>>((RemoteServerInfoState serverInfo) {
                              return DropdownMenuItem<String>(
                                value: serverInfo.onion,
                                child: Text(
                                  serverInfo.description.isNotEmpty ? serverInfo.description : serverInfo.onion,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList()),
                        SizedBox(
                          height: 20,
                        ),
                        CwtchLabel(label: AppLocalizations.of(bcontext)!.groupNameLabel),
                        SizedBox(
                          height: 20,
                        ),
                        CwtchTextField(
                          controller: ctrlrGroupName,
                          hintText: AppLocalizations.of(bcontext)!.groupNameLabel,
                          onChanged: (newValue) {},
                          validator: (value) {},
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            var profileOnion = Provider.of<ProfileInfoState>(bcontext, listen: false).onion;
                            Provider.of<FlwtchState>(bcontext, listen: false).cwtch.CreateGroup(profileOnion, server, ctrlrGroupName.text);
                            Future.delayed(const Duration(milliseconds: 500), () {
                              final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.successfullAddedContact + " " + ctrlrGroupName.text));
                              ScaffoldMessenger.of(bcontext).showSnackBar(snackBar);
                              Navigator.pop(bcontext);
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.createGroupBtn),
                        ),
                      ],
                    )))));
  }
}

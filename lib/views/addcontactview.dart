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
    bool groupsEnabled = Provider.of<Settings>(context).isExperimentEnabled(TapirGroupsExperiment);
    return Consumer<ErrorHandler>(builder: (context, globalErrorHandler, child) {
      return DefaultTabController(
          length: groupsEnabled ? 2 : 1,
          child: Column(children: [
            (groupsEnabled ? getTabBarWithGroups() : getTabBarWithAddPeerOnly()),
            Expanded(
                child: TabBarView(
              children: (groupsEnabled
                  ? [
                      addPeerTab(),
                      addGroupTab(),
                    ]
                  : [addPeerTab()]),
            )),
          ]));
    });
  }

  void _copyOnion() {
    Clipboard.setData(new ClipboardData(text: Provider.of<ProfileInfoState>(context, listen: false).onion));
    final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.copiedClipboardNotification));
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
  Widget addPeerTab() {
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
                          CwtchIcons.address_copy_2,
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
                        controller: ctrlrContact,
                        validator: (value) {
                          if (value == "") {
                            return null;
                          }
                          if (globalErrorHandler.invalidImportStringError) {
                            return AppLocalizations.of(context)!.invalidImportString;
                          } else if (globalErrorHandler.contactAlreadyExistsError) {
                            return AppLocalizations.of(context)!.contactAlreadyExists;
                          } else if (globalErrorHandler.explicitAddContactSuccess) {}
                          return null;
                        },
                        onChanged: (String importBundle) async {
                          var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
                          Provider.of<FlwtchState>(context, listen: false).cwtch.ImportBundle(profileOnion, importBundle);

                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (globalErrorHandler.importBundleSuccess) {
                              // TODO: This isn't ideal, but because onChange can be fired during this future check
                              // and because the context can change after being popped we have this kind of double assertion...
                              // There is probably a better pattern to handle this...
                              if (AppLocalizations.of(context) != null) {
                                final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.successfullAddedContact + importBundle));
                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                Navigator.popUntil(context, (route) => route.settings.name == "conversations");
                              }
                            }
                          });
                        },
                        hintText: '',
                      )
                    ])))));
  }

  /// TODO Add Group Pane
  Widget addGroupTab() {
    // TODO We should replace with with a "Paste in Server Key Bundle"
    if (Provider.of<ProfileInfoState>(context).serverList.servers.isEmpty) {
      return Text(AppLocalizations.of(context)!.addServerFirst);
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
                            items: Provider.of<ProfileInfoState>(context)
                                .serverList
                                .servers
                                .where((serverInfo) => serverInfo.status == "Synced")
                                .map<DropdownMenuItem<String>>((RemoteServerInfoState serverInfo) {
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
                        CwtchLabel(label: AppLocalizations.of(context)!.groupName),
                        SizedBox(
                          height: 20,
                        ),
                        CwtchTextField(
                          controller: ctrlrGroupName,
                          hintText: AppLocalizations.of(context)!.groupNameLabel,
                          onChanged: (newValue) {},
                          validator: (value) {},
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
                            Provider.of<FlwtchState>(context, listen: false).cwtch.CreateGroup(profileOnion, server, ctrlrGroupName.text);
                            Future.delayed(const Duration(milliseconds: 500), () {
                              final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.successfullAddedContact + " " + ctrlrGroupName.text));
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              Navigator.pop(context);
                            });
                          },
                          child: Text(AppLocalizations.of(context)!.createGroupBtn),
                        ),
                      ],
                    )))));
  }

  /// TODO Manage Servers Tab
  Widget manageServersTab() {
    final tiles = Provider.of<ProfileInfoState>(context).serverList.servers.map((RemoteServerInfoState server) {
      return ChangeNotifierProvider<RemoteServerInfoState>.value(
          value: server,
          child: ListTile(
            title: Text(server.onion),
          ));
    });
    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return ListView(children: divided);
  }
}

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/contactlist.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/models/profilelist.dart';
import 'package:cwtch/views/profileserversview.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/widgets/contactrow.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../settings.dart';
import 'addcontactview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'messageview.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({Key? key}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

// selectConversation can be called from anywhere to set the active conversation
void selectConversation(BuildContext context, int handle) {
  // requery instead of using contactinfostate directly because sometimes listview gets confused about data that resorts
  var initialIndex = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(handle)!.unreadMessages;
  Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(handle)!.unreadMessages = 0;
  // triggers update in Double/TripleColumnView
  Provider.of<AppState>(context, listen: false).initialScrollIndex = initialIndex;
  Provider.of<AppState>(context, listen: false).selectedConversation = handle;
  Provider.of<AppState>(context, listen: false).selectedIndex = null;
  Provider.of<AppState>(context, listen: false).hoveredIndex = -1;
  // if in singlepane mode, push to the stack
  var isLandscape = Provider.of<AppState>(context, listen: false).isLandscape(context);
  if (Provider.of<Settings>(context, listen: false).uiColumns(isLandscape).length == 1) _pushMessageView(context, handle);
}

void _pushMessageView(BuildContext context, int handle) {
  var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext builderContext) {
        // assert we have an actual profile...
        // We need to listen for updates to the profile in order to update things like invitation message bubbles.
        var profile = Provider.of<FlwtchState>(builderContext).profs.getProfile(profileOnion)!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: profile),
            ChangeNotifierProvider.value(value: profile.contactList.getContact(handle)!),
          ],
          builder: (context, child) => MessageView(),
        );
      },
    ),
  );
}

class _ContactsViewState extends State<ContactsView> {
  late TextEditingController ctrlrFilter;
  bool showSearchBar = false;

  @override
  void initState() {
    super.initState();
    ctrlrFilter = new TextEditingController(text: Provider.of<ContactListState>(context, listen: false).filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawerEnableOpenDragGesture: false,
        drawerEnableOpenDragGesture: false,
        appBar: AppBar(
          leading: Row(children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () {
                Provider.of<ProfileInfoState>(context, listen: false).recountUnread();
                Provider.of<AppState>(context, listen: false).selectedProfile = "";
                Navigator.of(context).pop();
              },
            ),
            StreamBuilder<bool>(
                stream: Provider.of<AppState>(context).getUnreadProfileNotifyStream(),
                builder: (BuildContext context, AsyncSnapshot<bool> unreadCountSnapshot) {
                  int unreadCount = Provider.of<ProfileListState>(context).generateUnreadCount(Provider.of<AppState>(context).selectedProfile ?? "");

                  return Visibility(
                      visible: unreadCount > 0,
                      child: CircleAvatar(
                        radius: 10.0,
                        backgroundColor: Provider.of<Settings>(context).theme.portraitProfileBadgeColor,
                        child: Text(unreadCount > 99 ? "99+" : unreadCount.toString(), style: TextStyle(color: Provider.of<Settings>(context).theme.portraitProfileBadgeTextColor, fontSize: 8.0)),
                      ));
                }),
          ]),
          title: RepaintBoundary(
              child: Row(children: [
            ProfileImage(
              imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment)
                  ? Provider.of<ProfileInfoState>(context).imagePath
                  : Provider.of<ProfileInfoState>(context).defaultImagePath,
              diameter: 42,
              border: Provider.of<Settings>(context).current().portraitOnlineBorderColor,
              badgeTextColor: Colors.red,
              badgeColor: Colors.red,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text("%1 » %2".replaceAll("%1", Provider.of<ProfileInfoState>(context).nickname).replaceAll("%2", AppLocalizations.of(context)!.titleManageContacts),
                    overflow: TextOverflow.ellipsis, style: TextStyle(color: Provider.of<Settings>(context).current().mainTextColor))),
          ])),
          actions: getActions(context),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _pushAddContact,
          tooltip: AppLocalizations.of(context)!.tooltipAddContact,
          child: const Icon(CwtchIcons.person_add_alt_1_24px),
        ),
        body: showSearchBar || Provider.of<ContactListState>(context).isFiltered ? _buildFilterable() : _buildContactList());
  }

  List<Widget> getActions(context) {
    var actions = List<Widget>.empty(growable: true);
    if (Provider.of<Settings>(context).blockUnknownConnections) {
      actions.add(Tooltip(message: AppLocalizations.of(context)!.blockUnknownConnectionsEnabledDescription, child: Icon(CwtchIcons.block_unknown)));
    }

    // Copy profile onion
    actions.add(IconButton(
        icon: Icon(CwtchIcons.address_copy_2),
        tooltip: AppLocalizations.of(context)!.copyAddress,
        splashRadius: Material.defaultSplashRadius / 2,
        onPressed: () {
          Clipboard.setData(new ClipboardData(text: Provider.of<ProfileInfoState>(context, listen: false).onion));
        }));

    // Manage known Servers
    if (Provider.of<Settings>(context, listen: false).isExperimentEnabled(TapirGroupsExperiment) || Provider.of<Settings>(context, listen: false).isExperimentEnabled(ServerManagementExperiment)) {
      actions.add(IconButton(
          icon: Icon(CwtchIcons.dns_24px),
          tooltip: AppLocalizations.of(context)!.manageKnownServersButton,
          splashRadius: Material.defaultSplashRadius / 2,
          onPressed: () {
            _pushServers();
          }));
    }

    // Search contacts
    actions.add(IconButton(
        // need both conditions for displaying initial empty textfield and also allowing filters to be cleared if this widget gets lost/reset
        icon: Icon(showSearchBar || Provider.of<ContactListState>(context).isFiltered ? Icons.search_off : Icons.search),
        splashRadius: Material.defaultSplashRadius / 2,
        onPressed: () {
          Provider.of<ContactListState>(context, listen: false).filter = "";
          setState(() {
            showSearchBar = !showSearchBar;
          });
        }));
    return actions;
  }

  Widget _buildFilterable() {
    Widget txtfield = CwtchTextField(
      controller: ctrlrFilter,
      hintText: AppLocalizations.of(context)!.search,
      onChanged: (newVal) {
        Provider.of<ContactListState>(context, listen: false).filter = newVal;
      },
    );
    return Column(children: [Padding(padding: EdgeInsets.all(8), child: txtfield), Expanded(child: _buildContactList())]);
  }

  Widget _buildContactList() {
    final tiles = Provider.of<ContactListState>(context).filteredList().map((ContactInfoState contact) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: contact),
          ChangeNotifierProvider.value(value: Provider.of<ProfileInfoState>(context).serverList),
        ],
        builder: (context, child) => RepaintBoundary(child: ContactRow()),
      );
    });

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();
    return RepaintBoundary(child: ListView(children: divided));
  }

  void _pushAddContact() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext bcontext) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: Provider.of<ProfileInfoState>(context)),
          ],
          child: AddContactView(),
        );
      },
    ));
  }

  void _pushServers() {
    var profile = Provider.of<ProfileInfoState>(context);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [ChangeNotifierProvider(create: (context) => profile), Provider.value(value: Provider.of<FlwtchState>(context))],
          child: ProfileServersView(),
        );
      },
    ));
  }
}

import 'dart:io';

import 'package:cwtch/cwtch/cwtch.dart';
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
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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
  var unread = Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(handle)!.unreadMessages;
  var previouslySelected = Provider.of<AppState>(context, listen: false).selectedConversation;
  if (previouslySelected != null) {
    Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(previouslySelected)!.unselected();
  }
  Provider.of<ProfileInfoState>(context, listen: false).contactList.getContact(handle)!.selected();

  // triggers update in Double/TripleColumnView
  Provider.of<AppState>(context, listen: false).initialScrollIndex = unread;
  Provider.of<AppState>(context, listen: false).selectedConversation = handle;
  Provider.of<AppState>(context, listen: false).selectedIndex = null;
  Provider.of<AppState>(context, listen: false).hoveredIndex = -1;
  // if in singlepane mode, push to the stack
  var isLandscape = Provider.of<AppState>(context, listen: false).isLandscape(context);
  if (Provider.of<Settings>(context, listen: false).uiColumns(isLandscape).length == 1) _pushMessageView(context, handle);

  // Set last message seen time in backend
  Provider.of<FlwtchState>(context, listen: false)
      .cwtch
      .SetConversationAttribute(Provider.of<ProfileInfoState>(context, listen: false).onion, handle, LastMessageSeenTimeKey, DateTime.now().toUtc().toIso8601String());
}

void _pushMessageView(BuildContext context, int handle) {
  var profileOnion = Provider.of<ProfileInfoState>(context, listen: false).onion;

  Navigator.of(context).push(
    PageRouteBuilder(
      settings: RouteSettings(name: "messages"),
      pageBuilder: (builderContext, a1, a2) {
        var profile = Provider.of<FlwtchState>(builderContext).profs.getProfile(profileOnion)!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: profile),
            ChangeNotifierProvider.value(value: profile.contactList.getContact(handle)!),
          ],
          builder: (context, child) => MessageView(),
        );
      },
      transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
      transitionDuration: Duration(milliseconds: 200),
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
          leading: Stack(children: [
            Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    Provider.of<ProfileInfoState>(context, listen: false).recountUnread();
                    Provider.of<AppState>(context, listen: false).selectedProfile = "";
                    Navigator.of(context).pop();
                  },
                )),
            Positioned(
              bottom: 5.0,
              right: 5.0,
              child: StreamBuilder<bool>(
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
            )
          ]),
          title: RepaintBoundary(
              child: Row(children: [
            ProfileImage(
              imagePath: Provider.of<Settings>(context).isExperimentEnabled(ImagePreviewsExperiment)
                  ? Provider.of<ProfileInfoState>(context).imagePath
                  : Provider.of<ProfileInfoState>(context).defaultImagePath,
              diameter: 42,
              border: Provider.of<ProfileInfoState>(context).isOnline
                  ? Provider.of<Settings>(context).current().portraitOnlineBorderColor
                  : Provider.of<Settings>(context).current().portraitOfflineBorderColor,
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
          onPressed: _modalAddImportChoice,
          tooltip: AppLocalizations.of(context)!.tooltipAddContact,
          child: Icon(
            CwtchIcons.person_add_alt_1_24px,
            color: Provider.of<Settings>(context).theme.defaultButtonTextColor,
          ),
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
          final snackBar = SnackBar(content: Text(AppLocalizations.of(context)!.copiedToClipboardNotification));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    var initialScroll =
        Provider.of<ProfileInfoState>(context, listen: false).contactList.filteredList().indexWhere((element) => element.identifier == Provider.of<AppState>(context).selectedConversation);
    if (initialScroll < 0) {
      initialScroll = 0;
    }

    var contactList = ScrollablePositionedList.separated(
      itemScrollController: Provider.of<ProfileInfoState>(context).contactListScrollController,
      itemCount: Provider.of<ContactListState>(context).numFiltered,
      initialScrollIndex: initialScroll,
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      semanticChildCount: Provider.of<ContactListState>(context).numFiltered,
      itemBuilder: (context, index) {
        return tiles.elementAt(index);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1);
      },
    );

    return RepaintBoundary(child: contactList);
  }

  void _pushAddContact(bool newGroup) {
    // close modal
    Navigator.popUntil(context, (route) => route.settings.name == "conversations");

    Navigator.of(context).push(
      PageRouteBuilder(
        settings: RouteSettings(name: "addcontact"),
        pageBuilder: (builderContext, a1, a2) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: Provider.of<ProfileInfoState>(context)),
            ],
            child: AddContactView(newGroup: newGroup),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _pushServers() {
    var profile = Provider.of<ProfileInfoState>(context);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (bcontext, a1, a2) {
          return MultiProvider(
            providers: [ChangeNotifierProvider(create: (context) => profile), Provider.value(value: Provider.of<FlwtchState>(context))],
            child: ProfileServersView(),
          );
        },
        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: Duration(milliseconds: 200),
      ),
    );
  }

  void _modalAddImportChoice() {
    bool groupsEnabled = Provider.of<Settings>(context, listen: false).isExperimentEnabled(TapirGroupsExperiment);

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: RepaintBoundary(
                  child: Container(
                height: Platform.isAndroid ? 250 : 200, // bespoke value courtesy of the [TextField] docs
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                                child: Tooltip(
                                    message: AppLocalizations.of(context)!.tooltipAddContact,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size.fromWidth(399),
                                        maximumSize: Size.fromWidth(400),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(180), right: Radius.circular(180))),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.addContact,
                                        semanticsLabel: AppLocalizations.of(context)!.addContact,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        _pushAddContact(false);
                                      },
                                    ))),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                              child: Tooltip(
                                  message: groupsEnabled ? AppLocalizations.of(context)!.addServerTooltip : AppLocalizations.of(context)!.thisFeatureRequiresGroupExpermientsToBeEnabled,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: Size.fromWidth(399),
                                      maximumSize: Size.fromWidth(400),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(180), right: Radius.circular(180))),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.addServerTitle,
                                      semanticsLabel: AppLocalizations.of(context)!.addServerTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: groupsEnabled
                                        ? () {
                                            _pushAddContact(false);
                                          }
                                        : null,
                                  )),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(
                                child: Tooltip(
                                    message: groupsEnabled ? AppLocalizations.of(context)!.createGroupTitle : AppLocalizations.of(context)!.thisFeatureRequiresGroupExpermientsToBeEnabled,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size.fromWidth(399),
                                        maximumSize: Size.fromWidth(400),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(left: Radius.circular(180), right: Radius.circular(180))),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.createGroupTitle,
                                        semanticsLabel: AppLocalizations.of(context)!.createGroupTitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: groupsEnabled
                                          ? () {
                                              _pushAddContact(true);
                                            }
                                          : null,
                                    ))),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ))),
              )));
        });
  }
}

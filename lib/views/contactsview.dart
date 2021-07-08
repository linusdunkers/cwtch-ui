import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:cwtch/views/torstatusview.dart';
import 'package:cwtch/widgets/contactrow.dart';
import 'package:cwtch/widgets/profileimage.dart';
import 'package:cwtch/widgets/textfield.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../settings.dart';
import 'addcontactview.dart';
import '../model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({Key? key}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
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
          title: RepaintBoundary(
              child: Row(children: [
            ProfileImage(
              imagePath: Provider.of<ProfileInfoState>(context).imagePath,
              diameter: 42,
              border: Provider.of<Settings>(context).current().portraitOnlineBorderColor(),
              badgeTextColor: Colors.red,
              badgeColor: Colors.red,
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
                child: Text("%1 » %2".replaceAll("%1", Provider.of<ProfileInfoState>(context).nickname).replaceAll("%2", AppLocalizations.of(context)!.titleManageContacts),
                    overflow: TextOverflow.ellipsis, style: TextStyle(color: Provider.of<Settings>(context).current().mainTextColor()))),
          ])),
          actions: [
            IconButton(icon: TorIcon(), onPressed: _pushTorStatus),
            IconButton(
                // need both conditions for displaying initial empty textfield and also allowing filters to be cleared if this widget gets lost/reset
                icon: Icon(showSearchBar || Provider.of<ContactListState>(context).isFiltered ? Icons.search_off : Icons.search),
                onPressed: () {
                  Provider.of<ContactListState>(context, listen: false).filter = "";
                  setState(() {
                    showSearchBar = !showSearchBar;
                  });
                })
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _pushAddContact,
          tooltip: AppLocalizations.of(context)!.tooltipAddContact,
          child: const Icon(CwtchIcons.person_add_alt_1_24px),
        ),
        body: showSearchBar || Provider.of<ContactListState>(context).isFiltered ? _buildFilterable() : _buildContactList());
  }

  Widget _buildFilterable() {
    Widget txtfield = CwtchTextField(
      controller: ctrlrFilter,
      labelText: AppLocalizations.of(context)!.search,
      onChanged: (newVal) {
        Provider.of<ContactListState>(context, listen: false).filter = newVal;
      },
    );
    return Column(children: [Padding(padding: EdgeInsets.all(8), child: txtfield), Expanded(child: _buildContactList())]);
  }

  Widget _buildContactList() {
    final tiles = Provider.of<ContactListState>(context).filteredList().map((ContactInfoState contact) {
      return ChangeNotifierProvider<ContactInfoState>.value(key: ValueKey(contact.profileOnion + "" + contact.onion), value: contact, builder: (_, __) => RepaintBoundary(child: ContactRow()));
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

  void _pushTorStatus() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [Provider.value(value: Provider.of<FlwtchState>(context))],
          child: TorStatusView(),
        );
      },
    ));
  }
}

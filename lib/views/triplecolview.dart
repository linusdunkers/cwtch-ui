import 'package:flutter/material.dart';
import 'package:cwtch/views/profilemgrview.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../model.dart';
import '../settings.dart';
import 'contactsview.dart';
import 'messageview.dart';

// currently unused but maybe one day?
class TripleColumnView extends StatefulWidget {
  @override
  _TripleColumnViewState createState() => _TripleColumnViewState();
}

class _TripleColumnViewState extends State<TripleColumnView> {
  @override
  Widget build(BuildContext context) {
    var appState = Provider.of<AppState>(context);
    var settings = Provider.of<Settings>(context);
    var columns = settings.uiColumns(appState.isLandscape(context));

    return Flex(direction: Axis.horizontal, children: <Widget>[
      Flexible(
        flex: columns[0],
        child: ProfileMgrView(),
      ),
      Flexible(
        flex: columns[1],
        child: appState.selectedProfile == null ? Center(child: Text(AppLocalizations.of(context)!.createProfileToBegin)) : ContactsView(), //dev
      ),
      Flexible(
        flex: columns[2],
        child: appState.selectedConversation == null
            ? Center(child: Text(AppLocalizations.of(context)!.addContactFirst))
            : //dev
            Container(child: MessageView()),
      ),
    ]);
  }
}

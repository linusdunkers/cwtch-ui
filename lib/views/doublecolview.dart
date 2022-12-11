import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../main.dart';
import '../settings.dart';
import 'contactsview.dart';
import 'messageview.dart';

class DoubleColumnView extends StatefulWidget {
  @override
  _DoubleColumnViewState createState() => _DoubleColumnViewState();
}

class _DoubleColumnViewState extends State<DoubleColumnView> {
  @override
  Widget build(BuildContext context) {
    var flwtch = Provider.of<AppState>(context);
    var selectedConversation = flwtch.selectedConversation;
    var cols = Provider.of<Settings>(context).uiColumns(true);
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Flexible(
          flex: cols[0],
          child: ContactsView(
            key: widget.key,
          ),
        ),
        Flexible(
          flex: cols[1],
          child: selectedConversation == null
              ? Container(
                  color: Provider.of<Settings>(context).theme.backgroundMainColor,
                  child: Card(
                      margin: EdgeInsets.all(0.0),
                      shape: new RoundedRectangleBorder(side: new BorderSide(color: Provider.of<Settings>(context).theme.defaultButtonColor, width: 4.0), borderRadius: BorderRadius.circular(4.0)),
                      child: Center(child: Text(AppLocalizations.of(context)!.addContactFirst))))
              : //dev
              MultiProvider(providers: [
                  ChangeNotifierProvider.value(value: Provider.of<ProfileInfoState>(context)),
                  // there is a potential timing issue here where selectConversation is changes as we move profiles, this will result
                  // in getContact being null, in that case we replace with an empty Contact Info State
                  ChangeNotifierProvider.value(value: Provider.of<ProfileInfoState>(context).contactList.getContact(selectedConversation) ?? ContactInfoState("", -1, "")),
                ], child: Container(key: Key(selectedConversation.toString()), child: MessageView())),
        ),
      ],
    );
  }
}

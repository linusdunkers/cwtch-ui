import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

bool noFilter(ContactInfoState peer) {
  return true;
}

// Dropdown menu populated from Provider.of<ProfileInfoState>'s contact list
// Includes both peers and groups; begins empty/nothing selected
// Displays nicknames to UI but uses handles as values
// Pass an onChanged handler to access value
class DropdownContacts extends StatefulWidget {
  DropdownContacts({
    required this.onChanged,
    this.filter = noFilter,
  });
  final Function(dynamic) onChanged;
  final bool Function(ContactInfoState) filter;

  @override
  _DropdownContactsState createState() => _DropdownContactsState();
}

class _DropdownContactsState extends State<DropdownContacts> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        isExpanded: true, // magic property
        value: this.selected,
        items: Provider.of<ProfileInfoState>(context, listen: false).contactList.contacts.where(widget.filter).map<DropdownMenuItem<String>>((ContactInfoState contact) {
          return DropdownMenuItem<String>(value: contact.onion, child: Text(contact.nickname));
        }).toList(),
        onChanged: (String? newVal) {
          setState(() {
            this.selected = newVal;
          });
          widget.onChanged(newVal);
        });
  }
}

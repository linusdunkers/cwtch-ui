import 'package:cwtch/widgets/passwordfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showPasswordDialog(BuildContext context, String title, String action, Function(String) onEntered) {
  TextEditingController passwordController = TextEditingController();
  CwtchPasswordField passwordField = CwtchPasswordField(
      controller: passwordController,
      validator: (passsword) {
        return null;
      });

  // set up the buttons
  Widget cancelButton = ElevatedButton(
    child: Text(AppLocalizations.of(context)!.cancel),
    onPressed: () {
      Navigator.of(context).pop(); // dismiss dialog
    },
  );
  Widget continueButton = ElevatedButton(
      child: Text(action),
      onPressed: () {
        onEntered(passwordController.value.text);
      });

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: passwordField,
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

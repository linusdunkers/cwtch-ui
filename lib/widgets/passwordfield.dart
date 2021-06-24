import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Provides a styled Password Input Field for use in Form Widgets.
// Callers must provide a text controller, label helper text and a validator.
class CwtchPasswordField extends StatefulWidget {
  CwtchPasswordField({required this.controller, required this.validator, this.action, this.autofocus = false});
  final TextEditingController controller;
  final FormFieldValidator validator;
  final Function(String)? action;
  final bool autofocus;

  @override
  _CwtchTextFieldState createState() => _CwtchTextFieldState();
}

class _CwtchTextFieldState extends State<CwtchPasswordField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    // todo: translations
    var label = AppLocalizations.of(context)!.tooltipShowPassword;
    if (!obscureText) {
      label = AppLocalizations.of(context)!.tooltipHidePassword;
    }

    return Consumer<Settings>(builder: (context, theme, child) {
      return TextFormField(
        autofocus: widget.autofocus,
        controller: widget.controller,
        validator: widget.validator,
        obscureText: obscureText,
        autovalidateMode: AutovalidateMode.always,
        onFieldSubmitted: widget.action,
        textInputAction: TextInputAction.unspecified,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                obscureText = !obscureText;
              });
            },
            icon: Icon((obscureText ? CwtchIcons.eye_closed : CwtchIcons.eye_open), semanticLabel: label),
            tooltip: label,
            color: theme.current().mainTextColor(),
            highlightColor: theme.current().defaultButtonColor(),
            focusColor: theme.current().defaultButtonActiveColor(),
            splashColor: theme.current().defaultButtonActiveColor(),
          ),
          errorStyle: TextStyle(
            color: theme.current().textfieldErrorColor(),
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor(), width: 3.0)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor(), width: 3.0)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor(), width: 3.0)),
          filled: true,
          fillColor: theme.current().textfieldBackgroundColor(),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor(), width: 3.0)),
        ),
      );
    });
  }
}

import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const hints = [AutofillHints.password];

// Provides a styled Password Input Field for use in Form Widgets.
// Callers must provide a text controller, label helper text and a validator.
class CwtchPasswordField extends StatefulWidget {
  CwtchPasswordField({required this.controller, required this.validator, this.action, this.autofocus = false, this.autoFillHints = hints});
  final TextEditingController controller;
  final FormFieldValidator validator;
  final Function(String)? action;
  final bool autofocus;
  final Iterable<String> autoFillHints;

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
        obscuringCharacter: '*',
        enableIMEPersonalizedLearning: false,
        autofillHints: widget.autoFillHints,
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
            color: theme.current().mainTextColor,
            highlightColor: theme.current().defaultButtonColor,
            focusColor: theme.current().defaultButtonActiveColor,
            splashColor: theme.current().defaultButtonActiveColor,
            splashRadius: Material.defaultSplashRadius / 2,
          ),
          errorStyle: TextStyle(
            color: theme.current().textfieldErrorColor,
            fontWeight: FontWeight.bold,
          ),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor, width: 1.0)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor, width: 1.0)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor, width: 1.0)),
          filled: true,
          fillColor: theme.current().textfieldBackgroundColor,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor, width: 1.0)),
        ),
      );
    });
  }
}

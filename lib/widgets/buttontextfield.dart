import 'package:flutter/material.dart';
import 'package:cwtch/settings.dart';
import 'package:provider/provider.dart';

// Provides a styled Text Field for use in Form Widgets.
// Callers must provide a text controller, label helper text and a validator.
class CwtchButtonTextField extends StatefulWidget {
  CwtchButtonTextField({required this.controller, required this.onPressed, required this.icon, required this.tooltip, this.readonly = true});
  final TextEditingController controller;
  final Function()? onPressed;
  final Icon icon;
  final String tooltip;
  final bool readonly;

  @override
  _CwtchButtonTextFieldState createState() => _CwtchButtonTextFieldState();
}

class _CwtchButtonTextFieldState extends State<CwtchButtonTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      // Select all...
      if (_focusNode.hasFocus) widget.controller.selection = TextSelection(baseOffset: 0, extentOffset: widget.controller.text.length);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, theme, child) {
      return TextFormField(
        controller: widget.controller,
        readOnly: widget.readonly,
        showCursor: !widget.readonly,
        focusNode: _focusNode,
        enableIMEPersonalizedLearning: false,
        decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: widget.onPressed,
              icon: widget.icon,
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 2.0, 2.0),
              tooltip: widget.tooltip,
              enableFeedback: true,
              color: theme.current().mainTextColor(),
              highlightColor: theme.current().defaultButtonColor(),
              focusColor: theme.current().defaultButtonActiveColor(),
              splashColor: theme.current().defaultButtonActiveColor(),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: theme.current().textfieldBackgroundColor(),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor(), width: 3.0)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor(), width: 3.0)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor(), width: 3.0)),
            errorStyle: TextStyle(
              color: theme.current().textfieldErrorColor(),
              fontWeight: FontWeight.bold,
            ),
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor(), width: 3.0))),
      );
    });
  }
}

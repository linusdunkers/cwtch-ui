import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../settings.dart';

doNothing(String x) {}

// Provides a styled Text Field for use in Form Widgets.
// Callers must provide a text controller, label helper text and a validator.
class CwtchTextField extends StatefulWidget {
  CwtchTextField({required this.controller, this.hintText = "", this.validator, this.autofocus = false, this.onChanged = doNothing, this.number = false, this.multiLine = false});
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator? validator;
  final Function(String) onChanged;
  final bool autofocus;
  final bool multiLine;
  final bool number;

  @override
  _CwtchTextFieldState createState() => _CwtchTextFieldState();
}

class _CwtchTextFieldState extends State<CwtchTextField> {
  late final FocusNode _focusNode;
  late final ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();

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
        validator: widget.validator,
        onChanged: widget.onChanged,
        autofocus: widget.autofocus,
        textAlign: widget.number ? TextAlign.end : TextAlign.start,
        keyboardType: widget.multiLine
            ? TextInputType.multiline
            : widget.number
                ? TextInputType.number
                : TextInputType.text,
        maxLines: widget.multiLine ? null : 1,
        scrollController: _scrollController,
        enableIMEPersonalizedLearning: false,
        focusNode: _focusNode,
        decoration: InputDecoration(
            hintText: widget.hintText,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor, width: 3.0)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor, width: 3.0)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldErrorColor, width: 3.0)),
            errorStyle: TextStyle(
              color: theme.current().textfieldErrorColor,
              fontWeight: FontWeight.bold,
            ),
            fillColor: theme.current().textfieldBackgroundColor,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0), borderSide: BorderSide(color: theme.current().textfieldBorderColor, width: 3.0))),
      );
    });
  }
}

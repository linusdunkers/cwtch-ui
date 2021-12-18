import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings.dart';

// Provides a styled Label
// Callers must provide a label text
class CwtchLabel extends StatefulWidget {
  CwtchLabel({required this.label});
  final String label;

  @override
  _CwtchLabelState createState() => _CwtchLabelState();
}

class _CwtchLabelState extends State<CwtchLabel> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Settings>(builder: (context, theme, child) {
      return Text(
        widget.label,
        style: TextStyle(fontSize: 20, color: theme.current().mainTextColor),
      );
    });
  }
}

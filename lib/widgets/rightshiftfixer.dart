import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// From https://github.com/flutter/flutter/issues/75675#issuecomment-846601115
// necessary to fix bug in flutter engine on Windows.
// todo: hopefully we can remove this soon
class ShiftRightFixer extends StatefulWidget {
  ShiftRightFixer({required this.child});
  final Widget child;
  @override
  State<StatefulWidget> createState() => _ShiftRightFixerState();
}

class _ShiftRightFixerState extends State<ShiftRightFixer> {
  final FocusNode focus = FocusNode(skipTraversal: true, canRequestFocus: false);
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focus,
      onKey: (_, RawKeyEvent event) {
        return event.physicalKey == PhysicalKeyboardKey.shiftRight ? KeyEventResult.handled : KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}

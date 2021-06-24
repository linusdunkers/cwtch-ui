import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final Color malformedColor = Color(0xFFE85DA1);

// MalformedBubble is displayed in the case of a malformed message
class MalformedBubble extends StatefulWidget {
  @override
  MalformedBubbleState createState() => MalformedBubbleState();
}

class MalformedBubbleState extends State<MalformedBubble> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Center(
          widthFactor: 1.0,
          child: Container(
              decoration: BoxDecoration(
                color: malformedColor,
                border: Border.all(color: malformedColor, width: 1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.zero,
                  topRight: Radius.zero,
                  bottomLeft: Radius.zero,
                  bottomRight: Radius.zero,
                ),
              ),
              child: Center(
                  widthFactor: 1.0,
                  child: Padding(
                      padding: EdgeInsets.all(9.0),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Center(
                            widthFactor: 1,
                            child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  CwtchIcons.favorite_black_24dp_broken,
                                  size: 24,
                                ))),
                        Center(
                            widthFactor: 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [Text(AppLocalizations.of(context)!.malformedMessage)],
                            ))
                      ])))));
    });
  }
}

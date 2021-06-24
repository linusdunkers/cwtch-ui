import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model.dart';
import 'package:intl/intl.dart';

import '../settings.dart';

class MessageLoadingBubble extends StatefulWidget {
  @override
  MessageLoadingBubbleState createState() => MessageLoadingBubbleState();
}

class MessageLoadingBubbleState extends State<MessageLoadingBubble> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Row(children: [SizedBox(width: 40, height: 100, child: Text(""))]));
  }
}

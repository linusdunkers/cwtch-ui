import 'package:flutter/material.dart';

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

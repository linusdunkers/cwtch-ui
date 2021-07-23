import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Provides message decorations (acks/errors/dates etc.) for generic message bubble overlays (chats, invites etc.)
class MessageBubbleDecoration extends StatefulWidget {
  MessageBubbleDecoration({required this.ackd, required this.errored, required this.prettyDate, required this.fromMe});
  final String prettyDate;
  final bool fromMe;
  final bool ackd;
  final bool errored;

  @override
  _MessageBubbleDecoration createState() => _MessageBubbleDecoration();
}

class _MessageBubbleDecoration extends State<MessageBubbleDecoration> {
  @override
  Widget build(BuildContext context) {
    return Center(
        widthFactor: 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.prettyDate,
                style:
                    TextStyle(fontSize: 9.0, color: widget.fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor() : Provider.of<Settings>(context).theme.messageFromOtherTextColor()),
                textAlign: widget.fromMe ? TextAlign.right : TextAlign.left),
            !widget.fromMe
                ? SizedBox(width: 1, height: 1)
                : Padding(
                    padding: EdgeInsets.all(1.0),
                    child: widget.ackd == true
                        ? Tooltip(
                            message: AppLocalizations.of(context)!.acknowledgedLabel,
                            child: Icon(Icons.check_circle_outline, color: Provider.of<Settings>(context).theme.messageFromMeTextColor(), size: 16))
                        : (widget.errored == true
                            ? Tooltip(
                                message: AppLocalizations.of(context)!.couldNotSendMsgError,
                                child: Icon(Icons.error_outline, color: Provider.of<Settings>(context).theme.messageFromMeTextColor(), size: 16))
                            : Tooltip(
                                message: AppLocalizations.of(context)!.pendingLabel,
                                child: Icon(Icons.hourglass_bottom_outlined, color: Provider.of<Settings>(context).theme.messageFromMeTextColor(), size: 16))))
          ],
        ));
  }
}

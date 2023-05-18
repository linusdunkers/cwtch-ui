import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/open_link_modal.dart';
import '../settings.dart';
import '../themes/opaque.dart';
import '../third_party/linkify/flutter_linkify.dart';

Widget compileSenderWidget(BuildContext context, bool fromMe, String senderDisplayStr) {
  return Container(
      height: 14 * Provider.of<Settings>(context).fontScaling,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(),
      child: SelectableText(senderDisplayStr,
          maxLines: 1,
          style: TextStyle(
            fontSize: 9.0 * Provider.of<Settings>(context).fontScaling,
            fontWeight: FontWeight.bold,
            fontFamily: "Inter",
            overflow: TextOverflow.clip,
            color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor,
          )));
}

Widget compileMessageContentWidget(BuildContext context, bool fromMe, String content, FocusNode focus, bool formatMessages, bool showClickableLinks) {
  return SelectableLinkify(
    text: content + '\u202F',
    // TODO: onOpen breaks the "selectable" functionality. Maybe something to do with gesture handler?
    options: LinkifyOptions(messageFormatting: formatMessages, parseLinks: showClickableLinks, looseUrl: true, defaultToHttps: true),
    linkifiers: [UrlLinkifier()],
    onOpen: showClickableLinks
        ? (link) {
            modalOpenLink(context, link);
          }
        : null,
    //key: Key(myKey),
    focusNode: focus,
    style: Provider.of<Settings>(context)
        .scaleFonts(defaultMessageTextStyle.copyWith(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
    linkStyle: Provider.of<Settings>(context)
        .scaleFonts(defaultMessageTextStyle.copyWith(color: fromMe ? Provider.of<Settings>(context).theme.messageFromMeTextColor : Provider.of<Settings>(context).theme.messageFromOtherTextColor)),
    codeStyle: Provider.of<Settings>(context).scaleFonts(defaultMessageTextStyle.copyWith(
        fontFamily: "RobotoMono",
        color: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherTextColor : Provider.of<Settings>(context).theme.messageFromMeTextColor,
        backgroundColor: fromMe ? Provider.of<Settings>(context).theme.messageFromOtherBackgroundColor : Provider.of<Settings>(context).theme.messageFromMeBackgroundColor)),
    textAlign: TextAlign.left,
    textWidthBasis: TextWidthBasis.longestLine,
  );
}

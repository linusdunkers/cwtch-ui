import 'package:cwtch/third_party/linkify/linkify.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void modalOpenLink(BuildContext ctx, LinkableElement link) {
  showModalBottomSheet<void>(
      context: ctx,
      builder: (BuildContext bcontext) {
        return Container(
            height: 200, // bespoke value courtesy of the [TextField] docs
            child: Center(
              child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(AppLocalizations.of(bcontext)!.clickableLinksWarning),
                      Flex(direction: Axis.horizontal, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          child: ElevatedButton(
                            child: Text(AppLocalizations.of(bcontext)!.clickableLinksCopy, semanticsLabel: AppLocalizations.of(bcontext)!.clickableLinksCopy),
                            onPressed: () {
                              Clipboard.setData(new ClipboardData(text: link.url));

                              final snackBar = SnackBar(
                                content: Text(AppLocalizations.of(bcontext)!.copiedToClipboardNotification),
                              );

                              Navigator.pop(bcontext);
                              ScaffoldMessenger.of(bcontext).showSnackBar(snackBar);
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                          child: ElevatedButton(
                            child: Text(AppLocalizations.of(bcontext)!.clickableLinkOpen, semanticsLabel: AppLocalizations.of(bcontext)!.clickableLinkOpen),
                            onPressed: () async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                                Navigator.pop(bcontext);
                              } else {
                                final snackBar = SnackBar(
                                  content: Text(AppLocalizations.of(bcontext)!.clickableLinkError),
                                );
                                ScaffoldMessenger.of(bcontext).showSnackBar(snackBar);
                              }
                            },
                          ),
                        ),
                      ]),
                    ],
                  )),
            ));
      });
}

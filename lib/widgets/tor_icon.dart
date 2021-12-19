import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../settings.dart';
import '../torstatus.dart';

/// A reusable Tor Icon Widget that displays the current status of the underlying Tor connections
class TorIcon extends StatefulWidget {
  TorIcon();

  @override
  State<StatefulWidget> createState() => _TorIconState();
}

class _TorIconState extends State<TorIcon> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        child: Icon(
      Provider.of<TorStatus>(context).progress == 0 ? CwtchIcons.onion_off : (Provider.of<TorStatus>(context).progress == 100 ? CwtchIcons.onion_on : CwtchIcons.onion_waiting),
      color: Provider.of<Settings>(context).theme.mainTextColor,
      semanticLabel: Provider.of<TorStatus>(context).progress == 100
          ? AppLocalizations.of(context)!.networkStatusOnline
          : (Provider.of<TorStatus>(context).progress == 0 ? AppLocalizations.of(context)!.networkStatusDisconnected : AppLocalizations.of(context)!.networkStatusAttemptingTor),
    ));
  }
}

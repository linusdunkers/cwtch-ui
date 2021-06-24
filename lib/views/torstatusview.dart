import 'package:flutter/material.dart';
import 'package:cwtch/torstatus.dart';
import 'package:cwtch/widgets/tor_icon.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';

/// Tor Status View provides all info on Tor network state and the (future) ability to configure the network in a variety
/// of ways (restart, enable bridges, enable pluggable transports etc)
class TorStatusView extends StatefulWidget {
  @override
  _TorStatusView createState() => _TorStatusView();
}

class _TorStatusView extends State<TorStatusView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.torNetworkStatus),
      ),
      body: _buildSettingsList(),
    );
  }

  Widget _buildSettingsList() {
    return Consumer<TorStatus>(builder: (context, torStatus, child) {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(children: [
                      ListTile(
                        leading: TorIcon(),
                        title: Text(AppLocalizations.of(context)!.torStatus),
                        subtitle: Text(torStatus.progress == 100 ? AppLocalizations.of(context)!.networkStatusOnline : torStatus.status),
                        trailing: ElevatedButton(
                          child: Text(AppLocalizations.of(context)!.resetTor),
                          onPressed: () {
                            Provider.of<FlwtchState>(context, listen: false).cwtch.ResetTor();
                          },
                        ),
                      ),
                      ListTile(
                        title: Text(AppLocalizations.of(context)!.torVersion),
                        subtitle: Text(torStatus.version),
                      ),
                    ]))));
      });
    });
  }
}

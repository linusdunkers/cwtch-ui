import 'package:cwtch/models/appstate.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../main.dart';
import '../settings.dart';

class SplashView extends StatefulWidget {
  @override
  _SplashViewState createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  Widget build(BuildContext context) {
    var cwtch = Provider.of<FlwtchState>(context, listen: false).cwtch;
    if (!cwtch.isL10nInit()) {
      if (AppLocalizations.of(context) != null && AppLocalizations.of(context)!.newMessageNotificationSimple.isNotEmpty) {
        cwtch.l10nInit(AppLocalizations.of(context)!.newMessageNotificationSimple, AppLocalizations.of(context)!.newMessageNotificationConversationInfo);
      }
    }

    return Consumer<AppState>(
        builder: (context, appState, child) => Scaffold(
              key: Key("SplashView"),
              body: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Image(
                  image: AssetImage("assets/core/knott-white.png"),
                  filterQuality: FilterQuality.medium,
                  isAntiAlias: true,
                  width: 200,
                  height: 200,
                ),
                Image(
                  image: AssetImage("assets/cwtch_title.png"),
                  filterQuality: FilterQuality.medium,
                  isAntiAlias: true,
                ),
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: [
                      Padding(
                          padding: EdgeInsets.all(6.0),
                          child: Text(
                              appState.appError != ""
                                  ? appState.appError
                                  : appState.modalState == ModalState.none
                                      ? AppLocalizations.of(context)!.loadingCwtch
                                      : appState.modalState == ModalState.storageMigration
                                          ? AppLocalizations.of(context)!.storageMigrationModalMessage
                                          : AppLocalizations.of(context)!.shuttingDownApp, // Todo l10n AppLocalizations.of(context)!.storageMigrationModalMessage
                              style: TextStyle(
                                  fontSize: 16.0, color: appState.appError == "" ? Provider.of<Settings>(context).theme.mainTextColor : Provider.of<Settings>(context).theme.textfieldErrorColor))),
                      Visibility(
                          visible: appState.modalState == ModalState.storageMigration || appState.modalState == ModalState.shutdown,
                          child: LinearProgressIndicator(
                            color: Provider.of<Settings>(context).theme.defaultButtonActiveColor,
                          ))
                    ])),
                Image(image: AssetImage("assets/Open_Privacy_Logo_lightoutline.png")),
              ])),
            ));
  }
}

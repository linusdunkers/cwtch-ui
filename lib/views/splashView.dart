import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model.dart';
import '../settings.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
        builder: (context, appState, child) => Scaffold(
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
                  child: Text(appState.appError == "" ? "Loading Cwtch..." : appState.appError,
                      style: TextStyle(fontSize: 16.0, color: appState.appError == "" ? Provider.of<Settings>(context).theme.mainTextColor : Provider.of<Settings>(context).theme.textfieldErrorColor)),
                ),
                Image(image: AssetImage("assets/Open_Privacy_Logo_lightoutline.png")),
              ])),
            ));
  }
}

import 'dart:convert';

import 'package:cwtch/config.dart';
import 'package:cwtch/cwtch/cwtch.dart';
import 'package:cwtch/main.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/profile.dart';
import 'package:cwtch/settings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../cwtch_icons_icons.dart';

class FileSharingView extends StatefulWidget {
  @override
  _FileSharingViewState createState() => _FileSharingViewState();
}

class _FileSharingViewState extends State<FileSharingView> {
  @override
  Widget build(BuildContext context) {
    var handle = Provider.of<ContactInfoState>(context).nickname;
    if (handle.isEmpty) {
      handle = Provider.of<ContactInfoState>(context).onion;
    }

    var profileHandle = Provider.of<ProfileInfoState>(context).onion;

    return Scaffold(
      appBar: AppBar(
        title: Text(handle + " » " + AppLocalizations.of(context)!.manageSharedFiles),
      ),
      body: FutureBuilder(
        future: Provider.of<FlwtchState>(context, listen: false).cwtch.GetSharedFiles(profileHandle, Provider.of<ContactInfoState>(context).identifier),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<dynamic> sharedFiles = jsonDecode(snapshot.data as String);
            sharedFiles.sort((a, b) {
              return a["DateShared"].toString().compareTo(b["DateShared"].toString());
            });

            var fileList = ScrollablePositionedList.separated(
              itemScrollController: ItemScrollController(),
              itemCount: sharedFiles.length,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              semanticChildCount: sharedFiles.length,
              itemBuilder: (context, index) {
                String filekey = sharedFiles[index]["FileKey"];
                EnvironmentConfig.debugLog("$sharedFiles " + sharedFiles[index].toString());
                return SwitchListTile(
                    title: Text(sharedFiles[index]["Path"]),
                    subtitle: Text(sharedFiles[index]["DateShared"]),
                    value: sharedFiles[index]["Active"],
                    activeTrackColor: Provider.of<Settings>(context).theme.defaultButtonColor,
                    inactiveTrackColor: Provider.of<Settings>(context).theme.defaultButtonDisabledColor,
                    secondary: Icon(CwtchIcons.attached_file_2, color: Provider.of<Settings>(context).current().mainTextColor),
                    onChanged: (newValue) {
                      setState(() {
                        if (newValue) {
                          Provider.of<FlwtchState>(context, listen: false).cwtch.RestartSharing(profileHandle, filekey);
                        } else {
                          Provider.of<FlwtchState>(context, listen: false).cwtch.StopSharing(profileHandle, filekey);
                        }
                      });
                    });
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(height: 1);
              },
            );
            return fileList;
          }
          return Container();
        },
      ),
    );
  }
}

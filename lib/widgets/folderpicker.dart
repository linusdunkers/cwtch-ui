import 'package:cwtch/cwtch_icons_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'package:provider/provider.dart';
import '../settings.dart';
import 'buttontextfield.dart';
import 'cwtchlabel.dart';

class CwtchFolderPicker extends StatefulWidget {
  final String label;
  final String initialValue;
  final String tooltip;
  final String description;
  final Function(String)? onSave;
  const CwtchFolderPicker({Key? key, this.label = "", this.tooltip = "", this.initialValue = "", this.onSave, this.description = ""}) : super(key: key);

  @override
  _CwtchFolderPickerState createState() => _CwtchFolderPickerState();
}

class _CwtchFolderPickerState extends State<CwtchFolderPicker> {
  final TextEditingController ctrlrVal = TextEditingController();

  @override
  void initState() {
    super.initState();
    ctrlrVal.text = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(Icons.file_download, color: Provider.of<Settings>(context).theme.messageFromMeTextColor, size: 16),
        title: Text(widget.label),
        subtitle: Text(widget.description),
        trailing: Container(
            width: 200,
            child: CwtchButtonTextField(
              controller: ctrlrVal,
              readonly: Platform.isAndroid,
              onPressed: () async {
                if (Platform.isAndroid) {
                  return;
                }

                try {
                  var selectedDirectory = await getDirectoryPath();
                  if (selectedDirectory != null) {
                    //File directory = File(selectedDirectory);
                    selectedDirectory += "/";
                    ctrlrVal.text = selectedDirectory;
                    if (widget.onSave != null) {
                      widget.onSave!(selectedDirectory);
                    }
                  } else {
                    // User canceled the picker
                  }
                } catch (e) {
                  print(e);
                }
              },
              icon: Icon(Icons.folder),
              tooltip: widget.tooltip, //todo: l18n
            )));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

import 'package:file_picker_desktop/file_picker_desktop.dart';
import 'buttontextfield.dart';
import 'cwtchlabel.dart';

class CwtchFolderPicker extends StatefulWidget {
  final String label;
  final String initialValue;
  final Function(String)? onSave;
  const CwtchFolderPicker({Key? key, this.label = "", this.initialValue = "", this.onSave}) : super(key: key);

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
    return Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(2),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
          CwtchLabel(label: widget.label),
          SizedBox(
            height: 20,
          ),
          CwtchButtonTextField(
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
            tooltip: "Browse", //todo: l18n
          )
        ]));
  }
}

import 'package:cwtch/controllers/filesharing.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:flutter/material.dart';
import 'dart:io';
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
  final Key? testKey;
  const CwtchFolderPicker({Key? key, this.testKey, this.label = "", this.tooltip = "", this.initialValue = "", this.onSave, this.description = ""}) : super(key: key);

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
            width: MediaQuery.of(context).size.width / 4,
            child: CwtchButtonTextField(
              testKey: widget.testKey,
              controller: ctrlrVal,
              readonly: Platform.isAndroid,
              onPressed: Provider.of<AppState>(context).disableFilePicker
                  ? null
                  : () async {
                      if (Platform.isAndroid) {
                        return;
                      }

                      var selectedDirectory = await showSelectDirectoryPicker(context);
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
                    },
              onChanged: widget.onSave,
              icon: Icon(Icons.folder),
              tooltip: widget.tooltip,
            )));
  }
}

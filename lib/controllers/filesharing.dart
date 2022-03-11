import 'dart:io';
import 'package:cwtch/models/appstate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

void showFilePicker(BuildContext ctx, int maxBytes, Function(File) onSuccess, Function onError, Function onCancel) async {
  // only allow one file picker at a time
  // note: ideally we would destroy file picker when leaving a conversation
  // but we don't currently have that option.
  // we need to store AppState in a variable because ctx might be destroyed
  // while awaiting for pickFiles.
  var appstate = Provider.of<AppState>(ctx, listen: false);
  appstate.disableFilePicker = true;
  // currently lockParentWindow only works on Windows...
  FilePickerResult? result = await FilePicker.platform.pickFiles(lockParentWindow: true);
  appstate.disableFilePicker = false;
  if (result != null && result.files.first.path != null) {
    File file = File(result.files.first.path!);
    // We have a maximum number of bytes we can represent in terms of
    // a manifest (see : https://git.openprivacy.ca/cwtch.im/cwtch/src/branch/master/protocol/files/manifest.go#L25)
    if (file.lengthSync() <= maxBytes) {
      onSuccess(file);
    } else {
      onError();
    }
  } else {
    onCancel();
  }
}

Future<String?> showCreateFilePicker(BuildContext ctx) async {
  // only allow one file picker at a time
  // note: ideally we would destroy file picker when leaving a conversation
  // but we don't currently have that option.
  // we need to store AppState in a variable because ctx might be destroyed
  // while awaiting for pickFiles.
  var appstate = Provider.of<AppState>(ctx, listen: false);
  appstate.disableFilePicker = true;
  // currently lockParentWindow only works on Windows...
  String? result = await FilePicker.platform.saveFile(lockParentWindow: true);
  appstate.disableFilePicker = false;
  return result;
}

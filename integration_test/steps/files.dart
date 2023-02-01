import 'dart:io';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric FolderExists() {
  return then1<String, FlutterWorld>(
    RegExp(r'I expect the folder {string} to exist'),
    (input1, context) async {
      context.expect(Directory(input1).existsSync(), true);
    },
  );
}

StepDefinitionGeneric FileExists() {
  return then1<String, FlutterWorld>(
    RegExp(r'I expect the file {string} to exist'),
    (input1, context) async {
      context.expect(File(input1).existsSync(), true);
    },
  );
}

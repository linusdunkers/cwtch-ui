import 'dart:convert';

import 'package:cwtch/config.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:path/path.dart' as path;

import 'cwtch.dart';
import 'cwtchNotifier.dart';

/*
TODO: make a reusable plugin for other flutter apps

import 'package:federated_plugin_platform_interface/federated_plugin_platform_interface.dart';

/// It uses [FederatedPluginInterface]
Future startCwtch() async {
  return await FederatedPluginInterface.instance.startCwtch();
}
 */

class CwtchGomobile implements Cwtch {
  static const appInfoPlatform = const MethodChannel('test.flutter.dev/applicationInfo');
  static const cwtchPlatform = const MethodChannel('cwtch');

  final appbusEventChannelName = 'test.flutter.dev/eventBus';

  late Future<dynamic> androidLibraryDir;
  late Future<dynamic> androidHomeDirectory;
  String androidHomeDirectoryStr = "";
  late CwtchNotifier cwtchNotifier;

  CwtchGomobile(CwtchNotifier _cwtchNotifier) {
    print("gomobile.dart: CwtchGomobile()");
    cwtchNotifier = _cwtchNotifier;
    androidHomeDirectory = getApplicationDocumentsDirectory();
    androidLibraryDir = appInfoPlatform.invokeMethod('getNativeLibDir');

    // Method channel to receive libcwtch-go events via Kotlin and dispatch them to _handleAppbusEvent (sends to cwtchNotifier)
    final appbusEventChannel = MethodChannel(appbusEventChannelName);
    appbusEventChannel.setMethodCallHandler(this._handleAppbusEvent);
  }

  // ignore: non_constant_identifier_names
  Future<void> Start() async {
    print("gomobile.dart: Start()...");
    androidHomeDirectoryStr = (await androidHomeDirectory).path;
    var cwtchDir = path.join(androidHomeDirectoryStr, ".cwtch");
    if (EnvironmentConfig.BUILD_VER == dev_version) {
      cwtchDir = path.join(cwtchDir, "dev");
    }
    String torPath = path.join(await androidLibraryDir, "libtor.so");
    print("gomobile.dart: Start invokeMethod Start($cwtchDir, $torPath)...");
    return cwtchPlatform.invokeMethod("Start", {"appDir": cwtchDir, "torPath": torPath});
  }

  @override
  // ignore: non_constant_identifier_names
  Future<void> ReconnectCwtchForeground() async {
    cwtchPlatform.invokeMethod("ReconnectCwtchForeground", {});
  }

  // Handle libcwtch-go events (received via kotlin) and dispatch to the cwtchNotifier
  Future<void> _handleAppbusEvent(MethodCall call) async {
    final String json = call.arguments;
    var obj = jsonDecode(json);
    cwtchNotifier.handleMessage(call.method, obj);
  }

  // ignore: non_constant_identifier_names
  void CreateProfile(String nick, String pass) {
    cwtchPlatform.invokeMethod("CreateProfile", {"nick": nick, "pass": pass});
  }

  // ignore: non_constant_identifier_names
  void LoadProfiles(String pass) {
    cwtchPlatform.invokeMethod("LoadProfiles", {"pass": pass});
  }

  // ignore: non_constant_identifier_names
  void DeleteProfile(String onion, String pass) {
    cwtchPlatform.invokeMethod("DeleteProfile", {"ProfileOnion": onion, "pass": pass});
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessage(String profile, int conversation, int index) {
    return cwtchPlatform.invokeMethod("GetMessage", {"ProfileOnion": profile, "conversation": conversation, "index": index});
  }

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessageByID(String profile, int conversation, int id) {
    return cwtchPlatform.invokeMethod("GetMessageByID", {"ProfileOnion": profile, "conversation": conversation, "id": id});
  }

  @override
  // ignore: non_constant_identifier_names
  void SendProfileEvent(String onion, String jsonEvent) {
    cwtchPlatform.invokeMethod("SendProfileEvent", {"onion": onion, "jsonEvent": jsonEvent});
  }

  @override
  // ignore: non_constant_identifier_names
  void SendAppEvent(String jsonEvent) {
    cwtchPlatform.invokeMethod("SendAppEvent", {"jsonEvent": jsonEvent});
  }

  @override
  void dispose() => {};

  @override
  // ignore: non_constant_identifier_names
  void AcceptContact(String profileOnion, int conversation) {
    cwtchPlatform.invokeMethod("AcceptContact", {"ProfileOnion": profileOnion, "conversation": conversation});
  }

  @override
  // ignore: non_constant_identifier_names
  void BlockContact(String profileOnion, int conversation) {
    cwtchPlatform.invokeMethod("BlockContact", {"ProfileOnion": profileOnion, "conversation": conversation});
  }

  @override
  // ignore: non_constant_identifier_names
  void SendMessage(String profileOnion, int conversation, String message) {
    cwtchPlatform.invokeMethod("SendMessage", {"ProfileOnion": profileOnion, "conversation": conversation, "message": message});
  }

  @override
  // ignore: non_constant_identifier_names
  void SendInvitation(String profileOnion, int conversation, int target) {
    cwtchPlatform.invokeMethod("SendInvitation", {"ProfileOnion": profileOnion, "conversation": conversation, "target": target});
  }

  @override
  // ignore: non_constant_identifier_names
  void ShareFile(String profileOnion, int conversation, String filepath) {
    cwtchPlatform.invokeMethod("ShareFile", {"ProfileOnion": profileOnion, "conversation": conversation, "filepath": filepath});
  }

  @override
  // ignore: non_constant_identifier_names
  void DownloadFile(String profileOnion, int conversation, String filepath, String manifestpath, String filekey) {
    cwtchPlatform.invokeMethod("DownloadFile", {"ProfileOnion": profileOnion, "conversation": conversation, "filepath": filepath, "manifestpath": manifestpath, "filekey": filekey});
  }

  // ignore: non_constant_identifier_names
  void CreateDownloadableFile(String profileOnion, int conversation, String filenameSuggestion, String filekey) {
    cwtchPlatform.invokeMethod("CreateDownloadableFile", {"ProfileOnion": profileOnion, "conversation": conversation, "filename": filenameSuggestion, "filekey": filekey});
  }

  @override
  // ignore: non_constant_identifier_names
  void CheckDownloadStatus(String profileOnion, String fileKey) {
    cwtchPlatform.invokeMethod("CheckDownloadStatus", {"ProfileOnion": profileOnion, "fileKey": fileKey});
  }

  @override
  // ignore: non_constant_identifier_names
  void VerifyOrResumeDownload(String profileOnion, int conversation, String filekey) {
    cwtchPlatform.invokeMethod("VerifyOrResumeDownload", {"ProfileOnion": profileOnion, "conversation": conversation, "filekey": filekey});
  }

  @override
  // ignore: non_constant_identifier_names
  void ResetTor() {
    cwtchPlatform.invokeMethod("ResetTor", {});
  }

  @override
  // ignore: non_constant_identifier_names
  void ImportBundle(String profileOnion, String bundle) {
    cwtchPlatform.invokeMethod("ImportBundle", {"ProfileOnion": profileOnion, "bundle": bundle});
  }

  @override
  void CreateGroup(String profileOnion, String server, String groupName) {
    cwtchPlatform.invokeMethod("CreateGroup", {"ProfileOnion": profileOnion, "server": server, "groupName": groupName});
  }

  @override
  // ignore: non_constant_identifier_names
  void DeleteContact(String profileOnion, int conversation) {
    cwtchPlatform.invokeMethod("DeleteContact", {"ProfileOnion": profileOnion, "conversation": conversation});
  }

  @override
  // ignore: non_constant_identifier_names
  void ArchiveConversation(String profileOnion, int conversation) {
    cwtchPlatform.invokeMethod("ArchiveConversation", {"ProfileOnion": profileOnion, "conversation": conversation});
  }

  @override
  // ignore: non_constant_identifier_names
  void SetProfileAttribute(String profile, String key, String val) {
    cwtchPlatform.invokeMethod("SetProfileAttribute", {"ProfileOnion": profile, "Key": key, "Val": val});
  }

  @override
  // ignore: non_constant_identifier_names
  void SetConversationAttribute(String profile, int conversation, String key, String val) {
    cwtchPlatform.invokeMethod("SetContactAttribute", {"ProfileOnion": profile, "conversation": conversation, "Key": key, "Val": val});
  }

  @override
  // ignore: non_constant_identifier_names
  void LoadServers(String password) {
    cwtchPlatform.invokeMethod("LoadServers", {"Password": password});
  }

  @override
  // ignore: non_constant_identifier_names
  void CreateServer(String password, String description, bool autostart) {
    cwtchPlatform.invokeMethod("CreateServer", {"Password": password, "Description": description, "Autostart": autostart});
  }

  @override
  // ignore: non_constant_identifier_names
  void DeleteServer(String serverOnion, String password) {
    cwtchPlatform.invokeMethod("DeleteServer", {"ServerOnion": serverOnion, "Password": password});
  }

  @override
  // ignore: non_constant_identifier_names
  void LaunchServers() {
    cwtchPlatform.invokeMethod("LaunchServers", {});
  }

  @override
  // ignore: non_constant_identifier_names
  void LaunchServer(String serverOnion) {
    cwtchPlatform.invokeMethod("LaunchServer", {"ServerOnion": serverOnion});
  }

  @override
  // ignore: non_constant_identifier_names
  void StopServer(String serverOnion) {
    cwtchPlatform.invokeMethod("StopServer", {"ServerOnion": serverOnion});
  }

  @override
  // ignore: non_constant_identifier_names
  void StopServers() {
    cwtchPlatform.invokeMethod("StopServers", {});
  }

  @override
  // ignore: non_constant_identifier_names
  void DestroyServers() {
    cwtchPlatform.invokeMethod("DestroyServers", {});
  }

  @override
  // ignore: non_constant_identifier_names
  void SetServerAttribute(String serverOnion, String key, String val) {
    cwtchPlatform.invokeMethod("SetServerAttribute", {"ServerOnion": serverOnion, "Key": key, "Val": val});
  }

  @override
  Future<void> Shutdown() async {
    print("gomobile.dart Shutdown");
    cwtchPlatform.invokeMethod("Shutdown", {});
  }

  @override
  Future GetMessageByContentHash(String profile, int conversation, String contentHash) {
    return cwtchPlatform.invokeMethod("GetMessageByContentHash", {"ProfileOnion": profile, "conversation": conversation, "contentHash": contentHash});
  }

  @override
  void SetMessageAttribute(String profile, int conversation, int channel, int message, String key, String val) {
    cwtchPlatform.invokeMethod("SetMessageAttribute", {"ProfileOnion": profile, "conversation": conversation, "Channel": channel, "Message": message, "Key": key, "Val": val});
  }

  @override
  String defaultDownloadPath() {
    return this.androidHomeDirectoryStr;
  }
}

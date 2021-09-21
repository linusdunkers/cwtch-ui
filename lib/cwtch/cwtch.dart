import 'package:flutter/src/services/text_input.dart';

abstract class Cwtch {
  // ignore: non_constant_identifier_names
  Future<void> Start();
  // ignore: non_constant_identifier_names
  Future<void> ReconnectCwtchForeground();

  // ignore: non_constant_identifier_names
  void SelectProfile(String onion);
  // ignore: non_constant_identifier_names
  void CreateProfile(String nick, String pass);
  // ignore: non_constant_identifier_names
  void LoadProfiles(String pass);
  // ignore: non_constant_identifier_names
  void DeleteProfile(String onion, String pass);

  // ignore: non_constant_identifier_names
  void ResetTor();

  // todo: remove these
  // ignore: non_constant_identifier_names
  void SendProfileEvent(String onion, String jsonEvent);
  // ignore: non_constant_identifier_names
  void SendAppEvent(String jsonEvent);

  // ignore: non_constant_identifier_names
  void AcceptContact(String profileOnion, String contactHandle);
  // ignore: non_constant_identifier_names
  void BlockContact(String profileOnion, String contactHandle);

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessage(String profile, String handle, int index);
  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessageByContentHash(String profile, String handle, String contentHash);
  // ignore: non_constant_identifier_names
  void UpdateMessageFlags(String profile, String handle, int index, int flags);
  // ignore: non_constant_identifier_names
  void SendMessage(String profile, String handle, String message);
  // ignore: non_constant_identifier_names
  void SendInvitation(String profile, String handle, String target);

  // ignore: non_constant_identifier_names
  void ShareFile(String profile, String handle, String filepath);
  // ignore: non_constant_identifier_names
  void DownloadFile(String profile, String handle, String filepath, String manifestpath, String filekey);
  // ignore: non_constant_identifier_names
  void CreateDownloadableFile(String profile, String handle, String filenameSuggestion, String filekey);

  // ignore: non_constant_identifier_names
  void ArchiveConversation(String profile, String handle);
  // ignore: non_constant_identifier_names
  void DeleteContact(String profile, String handle);

  // ignore: non_constant_identifier_names
  void CreateGroup(String profile, String server, String groupName);

  // ignore: non_constant_identifier_names
  void ImportBundle(String profile, String bundle);
  // ignore: non_constant_identifier_names
  void SetGroupAttribute(String profile, String groupHandle, String key, String value);
  // ignore: non_constant_identifier_names
  void RejectInvite(String profileOnion, String groupHandle);

  // ignore: non_constant_identifier_names
  void Shutdown();

  void dispose();
}

import 'package:flutter/src/services/text_input.dart';

// To handle profiles that are "unencrypted" (i.e don't require a password to open) we currently create a profile with a defacto, hardcoded password.
// Details: https://docs.openprivacy.ca/cwtch-security-handbook/profile_encryption_and_storage.html
const DefaultPassword = "be gay do crime";

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
  void AcceptContact(String profileOnion, int contactHandle);
  // ignore: non_constant_identifier_names
  void BlockContact(String profileOnion, int contactHandle);

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessage(String profile, int handle, int index);

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessageByID(String profile, int handle, int index);

  // ignore: non_constant_identifier_names
  Future<dynamic> GetMessageByContentHash(String profile, int handle, String contentHash);

  // ignore: non_constant_identifier_names
  void SendMessage(String profile, int handle, String message);
  // ignore: non_constant_identifier_names
  void SendInvitation(String profile, int handle, int target);

  // ignore: non_constant_identifier_names
  void ShareFile(String profile, int handle, String filepath);
  // ignore: non_constant_identifier_names
  void DownloadFile(String profile, int handle, String filepath, String manifestpath, String filekey);
  // ignore: non_constant_identifier_names
  void CreateDownloadableFile(String profile, int handle, String filenameSuggestion, String filekey);
  // ignore: non_constant_identifier_names
  void CheckDownloadStatus(String profile, String fileKey);
  // ignore: non_constant_identifier_names
  void VerifyOrResumeDownload(String profile, int handle, String filekey);

  // ignore: non_constant_identifier_names
  void ArchiveConversation(String profile, int handle);
  // ignore: non_constant_identifier_names
  void DeleteContact(String profile, int handle);

  // ignore: non_constant_identifier_names
  void CreateGroup(String profile, String server, String groupName);

  // ignore: non_constant_identifier_names
  void ImportBundle(String profile, String bundle);
  // ignore: non_constant_identifier_names
  void RejectInvite(String profileOnion, int groupHandle);
  // ignore: non_constant_identifier_names
  void SetProfileAttribute(String profile, String key, String val);
  // ignore: non_constant_identifier_names
  void SetConversationAttribute(String profile, int contact, String key, String val);

  // ignore: non_constant_identifier_names
  void LoadServers(String password);
  // ignore: non_constant_identifier_names
  void CreateServer(String password, String description, bool autostart);
  // ignore: non_constant_identifier_names
  void DeleteServer(String serverOnion, String password);
  // ignore: non_constant_identifier_names
  void LaunchServers();
  // ignore: non_constant_identifier_names
  void LaunchServer(String serverOnion);
  // ignore: non_constant_identifier_names
  void StopServer(String serverOnion);
  // ignore: non_constant_identifier_names
  void StopServers();
  // ignore: non_constant_identifier_names
  void DestroyServers();
  // ignore: non_constant_identifier_names
  void SetServerAttribute(String serverOnion, String key, String val);

  // ignore: non_constant_identifier_names
  void Shutdown();

  void dispose();
}

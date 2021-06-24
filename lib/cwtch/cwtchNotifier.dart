import 'dart:convert';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/notification_manager.dart';
import 'package:provider/provider.dart';

import 'package:cwtch/torstatus.dart';

import '../errorHandler.dart';
import '../model.dart';
import '../settings.dart';

// Class that handles libcwtch-go events (received either via ffi with an isolate or gomobile over a method channel from kotlin)
//   Takes Notifiers and triggers them on appropriate events
class CwtchNotifier {
  late ProfileListState profileCN;
  late Settings settings;
  late ErrorHandler error;
  late TorStatus torStatus;
  late NotificationsManager notificationManager;
  late AppState appState;

  CwtchNotifier(ProfileListState pcn, Settings settingsCN, ErrorHandler errorCN, TorStatus torStatusCN, NotificationsManager notificationManagerP, AppState appStateCN) {
    profileCN = pcn;
    settings = settingsCN;
    error = errorCN;
    torStatus = torStatusCN;
    notificationManager = notificationManagerP;
    appState = appStateCN;
  }

  void handleMessage(String type, dynamic data) {
    switch (type) {
      case "CwtchStarted":
        appState.SetCwtchInit();
        break;
      case "CwtchStartError":
        appState.SetAppError(data["Error"]);
        break;
      case "NewPeer":
        // if tag != v1-defaultPassword then it is either encrypted OR it is an unencrypted account created during pre-beta...
        profileCN.add(data["Identity"], data["name"], data["picture"], data["ContactsJson"], data["ServerList"], data["Online"] == "true", data["tag"] != "v1-defaultPassword");
        break;
      case "PeerCreated":
        profileCN.getProfile(data["ProfileOnion"])?.contactList.add(ContactInfoState(
              data["ProfileOnion"],
              data["RemotePeer"],
              nickname: data["nick"],
              status: data["status"],
              imagePath: data["picture"],
              isBlocked: data["authorization"] == "blocked",
              isInvitation: data["authorization"] == "unknown",
              savePeerHistory: data["saveConversationHistory"] == null ? "DeleteHistoryConfirmed" : data["saveConversationHistory"],
              numMessages: int.parse(data["numMessages"]),
              numUnread: int.parse(data["unread"]),
              isGroup: data["isGroup"] == true,
              server: data["groupServer"],
              lastMessageTime: DateTime.now(), //show at the top of the contact list even if no messages yet
            ));
        break;
      case "GroupCreated":

        // Retrieve Server Status from Cache...
        String status = "";
        ServerInfoState? serverInfoState = profileCN.getProfile(data["ProfileOnion"])?.serverList.getServer(data["GroupServer"]);
        if (serverInfoState != null) {
          status = serverInfoState.status;
        }
        if (profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"]) == null) {
          profileCN.getProfile(data["ProfileOnion"])?.contactList.add(ContactInfoState(data["ProfileOnion"], data["GroupID"],
              isInvitation: false, imagePath: data["PicturePath"], nickname: data["GroupName"], status: status, server: data["GroupServer"], isGroup: true, lastMessageTime: DateTime.now()));
          profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(data["GroupID"], DateTime.now());
        }
        break;
      case "PeerDeleted":
        profileCN.delete(data["Identity"]);
        // todo standarize
        error.handleUpdate("deleteprofile.success");
        break;
      case "DeleteContact":
        profileCN.getProfile(data["ProfileOnion"])?.contactList.removeContact(data["RemotePeer"]);
        break;
      case "DeleteGroup":
        profileCN.getProfile(data["ProfileOnion"])?.contactList.removeContact(data["GroupID"]);
        break;
      case "PeerStateChange":
        ContactInfoState? contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"]);
        if (contact != null) {
          if (data["ConnectionState"] != null) {
            contact.status = data["ConnectionState"];
          }
          if (data["authorization"] != null) {
            contact.isInvitation = data["authorization"] == "unknown";
            contact.isBlocked = data["authorization"] == "blocked";
          }
          // contact.[status/isBlocked] might change the list's sort order
          profileCN.getProfile(data["ProfileOnion"])?.contactList.resort();
        }
        break;
      case "NewMessageFromPeer":
        notificationManager.notify("New Message From Peer!");
        if (appState.selectedProfile != data["ProfileOnion"] || appState.selectedConversation != data["RemotePeer"]) {
          profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"])!.unreadMessages++;
        }
        profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"])!.totalMessages++;
        profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(data["RemotePeer"], DateTime.now());
        break;
      case "PeerAcknowledgement":
        // We don't use these anymore, IndexedAcknowledgement is more suited to the UI front end...
        break;
      case "IndexedAcknowledgement":
        var idx = data["Index"];
        // We return -1 for protocol message acks if there is no message
        if (idx == "-1") break;
        var key = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"])!.getMessageKey(idx);
        if (key == null) break;
        try {
          var message = Provider.of<MessageState>(key.currentContext!, listen: false);
          if (message == null) break;
          message.ackd = true;
        } catch (e) {
          // ignore, we received an ack for a message that hasn't loaded onto the screen yet...
          // the protocol was faster than the ui....yay?
        }
        break;
      case "NewMessageFromGroup":
        if (data["ProfileOnion"] != data["RemotePeer"]) {
          //not from me
          if (appState.selectedProfile != data["ProfileOnion"] || appState.selectedConversation != data["GroupID"]) {
            profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"])!.unreadMessages++;
          }
          profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"])!.totalMessages++;
          profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(data["GroupID"], DateTime.now());
        } else {
          // from me (already displayed - do not update counter)
          var idx = data["Signature"];
          var key = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"])!.getMessageKey(idx);
          if (key == null) break;
          try {
            var message = Provider.of<MessageState>(key.currentContext!, listen: false);
            if (message == null) break;
            message.ackd = true;
          } catch (e) {
            // ignore, we likely have an old key that has been replaced with an actual signature
          }
        }
        break;
      case "MessageCounterResync":
        var contactHandle = data["RemotePeer"];
        if (contactHandle == null || contactHandle == "") contactHandle = data["GroupID"];
        profileCN.getProfile(data["Identity"])?.contactList.getContact(contactHandle)!.totalMessages = int.parse(data["Data"]);
        break;
      case "IndexedFailure":
        print("IndexedFailure: $data");
        var idx = data["Index"];
        var key = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"])!.getMessageKey(idx);
        try {
          var message = Provider.of<MessageState>(key!.currentContext!, listen: false);
          message.error = true;
        } catch (e) {
          // ignore, we likely have an old key that has been replaced with an actual signature
        }
        break;
      case "SendMessageToGroupError":
        // from me (already displayed - do not update counter)
        print("SendMessageToGroupError: $data");
        var idx = data["Signature"];
        var key = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"])!.getMessageKey(idx);
        if (key == null) break;
        try {
          var message = Provider.of<MessageState>(key.currentContext!, listen: false);
          if (message == null) break;
          message.error = true;
        } catch (e) {
          // ignore, we likely have an old key that has been replaced with an actual signature
        }
        break;
      case "AppError":
        print("New App Error: $data");
        // special case for delete error (todo: standardize cwtch errors)
        if (data["Error"] == "Password did not match") {
          error.handleUpdate("deleteprofile.error");
        } else if (data["Data"] != null) {
          error.handleUpdate(data["Data"]);
        }
        break;
      case "UpdateGlobalSettings":
        settings.handleUpdate(jsonDecode(data["Data"]));
        break;
      case "SetAttribute":
        if (data["Key"] == "public.name") {
          profileCN.getProfile(data["ProfileOnion"])?.nickname = data["Data"];
        } else {
          print("unhandled set attribute event: $type $data");
        }
        break;
      case "NetworkError":
        var isOnline = data["Status"] == "Success";
        profileCN.getProfile(data["ProfileOnion"])?.isOnline = isOnline;
        break;
      case "ACNStatus":
        print("acn status: $data");
        torStatus.handleUpdate(int.parse(data["Progress"]), data["Status"]);
        break;
      case "ACNVersion":
        print("acn version: $data");
        torStatus.updateVersion(data["Data"]);
        break;
      case "UpdateServerInfo":
        profileCN.getProfile(data["ProfileOnion"])?.replaceServers(data["ServerList"]);
        break;
      case "NewGroup":
        print("new group: $data");
        String invite = data["GroupInvite"].toString();
        if (invite.startsWith("torv3")) {
          String inviteJson = new String.fromCharCodes(base64Decode(invite.substring(5)));
          dynamic groupInvite = jsonDecode(inviteJson);
          print("group invite: $groupInvite");

          // Retrieve Server Status from Cache...
          String status = "";
          ServerInfoState? serverInfoState = profileCN.getProfile(data["ProfileOnion"])!.serverList.getServer(groupInvite["ServerHost"]);
          if (serverInfoState != null) {
            print("Got server status: " + serverInfoState.status);
            status = serverInfoState.status;
          }

          if (profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(groupInvite["GroupID"]) == null) {
            profileCN.getProfile(data["ProfileOnion"])?.contactList.add(ContactInfoState(data["ProfileOnion"], groupInvite["GroupID"],
                isInvitation: false,
                imagePath: data["PicturePath"],
                nickname: groupInvite["GroupName"],
                server: groupInvite["ServerHost"],
                status: status,
                isGroup: true,
                lastMessageTime: DateTime.now()));
            profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(groupInvite["GroupID"], DateTime.now());
          }
        }
        break;
      case "AcceptGroupInvite":
        print("accept group invite: $data");

        profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"])!.isInvitation = false;
        profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(data["GroupID"], DateTime.now());
        break;
      case "ServerStateChange":
        print("server state change: $data");
        // Update the Server Cache
        profileCN.getProfile(data["ProfileOnion"])?.updateServerStatusCache(data["GroupServer"], data["ConnectionState"]);
        profileCN.getProfile(data["ProfileOnion"])?.contactList.contacts.forEach((contact) {
          if (contact.isGroup == true && contact.server == data["GroupServer"]) {
            contact.status = data["ConnectionState"];
          }
        });
        profileCN.getProfile(data["ProfileOnion"])?.contactList.resort();
        break;
      case "SetGroupAttribute":
        if (data["Key"] == "local.name") {
          if (profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"]) != null) {
            profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["GroupID"])!.nickname = data["Data"];
          }
        } else {
          print("unhandled set group attribute event: $type $data");
        }
        break;
      case "NewRetValMessageFromPeer":
        if (data["Path"] == "name") {
          // Update locally on the UI...
          if (profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"]) != null) {
            profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(data["RemotePeer"])!.nickname = data["Data"];
          }
        } else {
          print("unhandled peer attribute event: $type $data");
        }
        break;
      default:
        print("unhandled event: $type $data");
    }
  }
}

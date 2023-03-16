import 'dart:convert';
import 'package:cwtch/main.dart';
import 'package:cwtch/models/appstate.dart';
import 'package:cwtch/models/contact.dart';
import 'package:cwtch/models/message.dart';
import 'package:cwtch/models/profilelist.dart';
import 'package:cwtch/models/profileservers.dart';
import 'package:cwtch/models/remoteserver.dart';
import 'package:cwtch/models/servers.dart';
import 'package:cwtch/notification_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:cwtch/torstatus.dart';

import '../config.dart';
import '../errorHandler.dart';
import '../settings.dart';

typedef SeenMessageCallback = Function(String, int, DateTime);

// Class that handles libcwtch-go events (received either via ffi with an isolate or gomobile over a method channel from kotlin)
//   Takes Notifiers and triggers them on appropriate events
class CwtchNotifier {
  late ProfileListState profileCN;
  late Settings settings;
  late ErrorHandler error;
  late TorStatus torStatus;
  late NotificationsManager notificationManager;
  late AppState appState;
  late ServerListState serverListState;

  String? notificationSimple;
  String? notificationConversationInfo;

  SeenMessageCallback? seenMessageCallback;

  CwtchNotifier(
      ProfileListState pcn, Settings settingsCN, ErrorHandler errorCN, TorStatus torStatusCN, NotificationsManager notificationManagerP, AppState appStateCN, ServerListState serverListStateCN) {
    profileCN = pcn;
    settings = settingsCN;
    error = errorCN;
    torStatus = torStatusCN;
    notificationManager = notificationManagerP;
    appState = appStateCN;
    serverListState = serverListStateCN;
  }

  void l10nInit(String notificationSimple, String notificationConversationInfo) {
    this.notificationSimple = notificationSimple;
    this.notificationConversationInfo = notificationConversationInfo;
  }

  void setMessageSeenCallback(SeenMessageCallback callback) {
    seenMessageCallback = callback;
  }

  void handleMessage(String type, dynamic data) {
    //EnvironmentConfig.debugLog("NewEvent $type $data");
    switch (type) {
      case "CwtchStarted":
        appState.SetCwtchInit();
        break;
      case "CwtchStartError":
        appState.SetAppError(data["Error"]);
        break;
      case "NewPeer":
        // empty events can be caused by the testing framework
        if (data["Online"] == null) {
          break;
        }
        // EnvironmentConfig.debugLog("NewPeer $data");
        // if tag != v1-defaultPassword then it is either encrypted OR it is an unencrypted account created during pre-beta...
        profileCN.add(data["Identity"], data["name"], data["picture"], data["defaultPicture"], data["ContactsJson"], data["ServerList"], data["Online"] == "true", data["autostart"] == "true",
            data["tag"] != "v1-defaultPassword");
        break;
      case "ContactCreated":
        EnvironmentConfig.debugLog("ContactCreated $data");

        profileCN.getProfile(data["ProfileOnion"])?.contactList.add(ContactInfoState(data["ProfileOnion"], int.parse(data["ConversationID"]), data["RemotePeer"],
            nickname: data["nick"],
            status: data["status"],
            imagePath: data["picture"],
            defaultImagePath: data["defaultPicture"],
            blocked: data["blocked"] == "true",
            accepted: data["accepted"] == "true",
            savePeerHistory: data["saveConversationHistory"] == null ? "DeleteHistoryConfirmed" : data["saveConversationHistory"],
            numMessages: int.parse(data["numMessages"]),
            numUnread: int.parse(data["unread"]),
            isGroup: false, // by definition
            server: null,
            archived: false,
            lastMessageTime: DateTime.now(), //show at the top of the contact list even if no messages yet
            notificationPolicy: data["notificationPolicy"] ?? "ConversationNotificationPolicy.Default"));

        break;
      case "NewServer":
        EnvironmentConfig.debugLog("NewServer $data");
        serverListState.add(data["Onion"], data["ServerBundle"], data["Running"] == "true", data["Description"], data["Autostart"] == "true", data["StorageType"] == "storage-password");
        break;
      case "ServerIntentUpdate":
        EnvironmentConfig.debugLog("ServerIntentUpdate $data");
        var server = serverListState.getServer(data["Identity"]);
        if (server != null) {
          server.setRunning(data["Intent"] == "running");
        }
        break;
      case "ServerStatsUpdate":
        EnvironmentConfig.debugLog("ServerStatsUpdate $data");
        var totalMessages = int.parse(data["TotalMessages"]);
        var connections = int.parse(data["Connections"]);
        serverListState.updateServerStats(data["Identity"], totalMessages, connections);
        break;
      case "GroupCreated":
        // Retrieve Server Status from Cache...
        String status = "";
        RemoteServerInfoState? serverInfoState = profileCN.getProfile(data["ProfileOnion"])?.serverList.getServer(data["GroupServer"]);
        if (serverInfoState != null) {
          status = serverInfoState.status;
        }
        if (profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(int.parse(data["ConversationID"])) == null) {
          profileCN.getProfile(data["ProfileOnion"])?.contactList.add(ContactInfoState(data["ProfileOnion"], int.parse(data["ConversationID"]), data["GroupID"],
              blocked: false, // we created
              accepted: true, // we created
              imagePath: data["picture"],
              defaultImagePath: data["picture"],
              nickname: data["GroupName"],
              status: status,
              server: data["GroupServer"],
              isGroup: true,
              lastMessageTime: DateTime.now(),
              notificationPolicy: data["notificationPolicy"] ?? "ConversationNotificationPolicy.Default"));

          profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(int.parse(data["ConversationID"]), DateTime.now());
        }
        break;
      case "PeerDeleted":
        profileCN.delete(data["Identity"]);
        // todo standarize
        error.handleUpdate("deleteprofile.success");
        break;
      case "ServerDeleted":
        error.handleUpdate("deletedserver." + data["Status"]);
        if (data["Status"] == "success") {
          serverListState.delete(data["Identity"]);
        }
        break;
      case "DeleteContact":
        profileCN.getProfile(data["ProfileOnion"])?.contactList.removeContact(data["ConversationID"]);
        break;
      case "DeleteGroup":
        profileCN.getProfile(data["ProfileOnion"])?.contactList.removeContact(data["ConversationID"]);
        break;
      case "PeerStateChange":
        ContactInfoState? contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.findContact(data["RemotePeer"]);
        if (contact != null) {
          if (data["ConnectionState"] != null) {
            contact.status = data["ConnectionState"];
          }
          profileCN.getProfile(data["ProfileOnion"])?.contactList.resort();
        }
        break;
      case "NewMessageFromPeer":
        var identifier = int.parse(data["ConversationID"]);
        var messageID = int.parse(data["Index"]);
        var timestamp = DateTime.tryParse(data['TimestampReceived'])!;
        var senderHandle = data['RemotePeer'];
        var senderImage = data['picture'];
        var isAuto = data['Auto'] == "true";
        String contenthash = data['ContentHash'];
        var selectedProfile = appState.selectedProfile == data["ProfileOnion"];
        var selectedConversation = selectedProfile && appState.selectedConversation == identifier;
        var notification = data["notification"];

        if (selectedConversation && seenMessageCallback != null) {
          seenMessageCallback!(data["ProfileOnion"]!, identifier, DateTime.now().toUtc());
        }

        if (notification == "SimpleEvent") {
          notificationManager.notify(notificationSimple ?? "New Message", "", 0);
        } else if (notification == "ContactInfo") {
          var contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(identifier);
          notificationManager.notify((notificationConversationInfo ?? "New Message from %1").replaceFirst("%1", (contact?.nickname ?? senderHandle.toString())), data["ProfileOnion"], identifier);
        }

        profileCN.getProfile(data["ProfileOnion"])?.newMessage(
              identifier,
              messageID,
              timestamp,
              senderHandle,
              senderImage,
              isAuto,
              data["Data"],
              contenthash,
              selectedProfile,
              selectedConversation,
            );
        appState.notifyProfileUnread();
        break;
      case "PeerAcknowledgement":
        // We don't use these anymore, IndexedAcknowledgement is more suited to the UI front end...
        break;
      case "IndexedAcknowledgement":
        var conversation = int.parse(data["ConversationID"]);
        var messageID = int.parse(data["Index"]);

        // We only ever see acks from authenticated peers.
        // If the contact is marked as offline then override this - can happen when the contact is removed from the front
        // end during syncing.
        if (profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(conversation)!.isOnline() == false) {
          profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(conversation)!.status = "Authenticated";
        }
        profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(conversation)!.ackCache(messageID);

        break;
      case "NewMessageFromGroup":
        var identifier = int.parse(data["ConversationID"]);
        if (data["ProfileOnion"] != data["RemotePeer"]) {
          var idx = int.parse(data["Index"]);
          var senderHandle = data['RemotePeer'];
          var senderImage = data['picture'];
          var timestampSent = DateTime.tryParse(data['TimestampSent'])!;
          var contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(identifier);
          var currentTotal = contact!.totalMessages;
          var isAuto = data['Auto'] == "true";
          String contenthash = data['ContentHash'];
          var selectedProfile = appState.selectedProfile == data["ProfileOnion"];
          var selectedConversation = selectedProfile && appState.selectedConversation == identifier;
          var notification = data["notification"];

          // Only bother to do anything if we know about the group and the provided index is greater than our current total...
          if (currentTotal != null && idx >= currentTotal) {
            // TODO: There are 2 timestamps associated with a new group message - time sent and time received.
            // Sent refers to the time a profile alleges they sent a message
            // Received refers to the time we actually saw the message from the server
            // These can obviously be very different for legitimate reasons.
            // We also maintain a relative hash-link through PreviousMessageSignature which is the ground truth for
            // order.
            // In the future we will want to combine these 3 ordering mechanisms into a cohesive view of the timeline
            // For now we perform some minimal checks on the sent timestamp to use to provide a useful ordering for honest contacts
            // and ensure that malicious contacts in groups can only set this timestamp to a value within the range of `last seen message time`
            // and `local now`.
            profileCN.getProfile(data["ProfileOnion"])?.newMessage(identifier, idx, timestampSent, senderHandle, senderImage, isAuto, data["Data"], contenthash, selectedProfile, selectedConversation);
            if (selectedConversation && seenMessageCallback != null) {
              seenMessageCallback!(data["ProfileOnion"]!, identifier, DateTime.now().toUtc());
            }

            if (notification == "SimpleEvent") {
              notificationManager.notify(notificationSimple ?? "New Message", "", 0);
            } else if (notification == "ContactInfo") {
              var contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(identifier);
              notificationManager.notify((notificationConversationInfo ?? "New Message from %1").replaceFirst("%1", (contact?.nickname ?? senderHandle.toString())), data["ProfileOnion"], identifier);
            }
            appState.notifyProfileUnread();
          }
          RemoteServerInfoState? server = profileCN.getProfile(data["ProfileOnion"])?.serverList.getServer(contact.server ?? "");
          server?.updateSyncProgressFor(timestampSent);
        } else {
          // This is dealt with by IndexedAcknowledgment
          EnvironmentConfig.debugLog("new message from group from yourself - this should not happen");
        }
        break;
      case "IndexedFailure":
        var identifier = int.parse(data["ConversationID"]);
        var contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(identifier);
        var messageID = int.parse(data["Index"]);
        contact!.errCache(messageID);
        break;
      case "AppError":
        EnvironmentConfig.debugLog("New App Error: $data");
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
      case "UpdatedProfileAttribute":
        if (data["Key"] == "public.profile.name") {
          profileCN.getProfile(data["ProfileOnion"])?.nickname = data["Data"];
        } else if (data["Key"].toString().startsWith("local.filesharing.")) {
          if (data["Key"].toString().endsWith(".path")) {
            // local.conversation.filekey.path
            List<String> keyparts = data["Key"].toString().split(".");
            if (keyparts.length == 5) {
              String filekey = keyparts[2] + "." + keyparts[3];
              profileCN.getProfile(data["ProfileOnion"])?.downloadSetPathForSender(filekey, data["Data"]);
            }
          }
        } else {
          EnvironmentConfig.debugLog("unhandled set attribute event: ${data['Key']}");
        }
        break;
      case "NetworkError":
        var isOnline = data["Status"] == "Success";
        profileCN.getProfile(data["ProfileOnion"])?.isOnline = isOnline;
        break;
      case "ACNStatus":
        EnvironmentConfig.debugLog("acn status: $data");
        torStatus.handleUpdate(int.parse(data["Progress"]), data["Status"]);
        break;
      case "ACNVersion":
        EnvironmentConfig.debugLog("acn version: $data");
        torStatus.updateVersion(data["Data"]);
        break;
      case "UpdateServerInfo":
        profileCN.getProfile(data["ProfileOnion"])?.replaceServers(data["ServerList"]);
        break;
      case "TokenManagerInfo":
        try {
          List<dynamic> associatedGroups = jsonDecode(data["Data"]);
          int count = int.parse(data["ServerTokenCount"]);
          associatedGroups.forEach((identifier) {
            profileCN.getProfile(data["ProfileOnion"])?.contactList.getContact(int.parse(identifier.toString()))!.antispamTickets = count;
          });
          EnvironmentConfig.debugLog("update server token count for ${associatedGroups}, $count");
        } catch (e) {
          //  No tokens in data...
        }
        break;
      case "NewGroup":
        String invite = data["GroupInvite"].toString();
        if (invite.startsWith("torv3")) {
          String inviteJson = new String.fromCharCodes(base64Decode(invite.substring(5)));
          dynamic groupInvite = jsonDecode(inviteJson);

          // Retrieve Server Status from Cache...
          String status = "";
          RemoteServerInfoState? serverInfoState = profileCN.getProfile(data["ProfileOnion"])!.serverList.getServer(groupInvite["ServerHost"]);
          if (serverInfoState != null) {
            status = serverInfoState.status;
          }

          if (profileCN.getProfile(data["ProfileOnion"])?.contactList.findContact(groupInvite["GroupID"]) == null) {
            var identifier = int.parse(data["ConversationID"]);
            profileCN.getProfile(data["ProfileOnion"])?.contactList.add(ContactInfoState(data["ProfileOnion"], identifier, groupInvite["GroupID"],
                blocked: false, // NewGroup only issued on accepting invite
                accepted: true, // NewGroup only issued on accepting invite
                imagePath: data["picture"],
                nickname: groupInvite["GroupName"],
                server: groupInvite["ServerHost"],
                status: status,
                isGroup: true,
                lastMessageTime: DateTime.now()));
            profileCN.getProfile(data["ProfileOnion"])?.contactList.updateLastMessageTime(identifier, DateTime.fromMillisecondsSinceEpoch(0));
          }
        }
        break;
      case "ServerStateChange":
        // Update the Server Cache
        profileCN.getProfile(data["ProfileOnion"])?.updateServerStatusCache(data["GroupServer"], data["ConnectionState"]);
        profileCN.getProfile(data["ProfileOnion"])?.contactList.contacts.forEach((contact) {
          if (contact.isGroup == true && contact.server == data["GroupServer"]) {
            contact.status = data["ConnectionState"];
          }
        });
        profileCN.getProfile(data["ProfileOnion"])?.contactList.resort();
        break;
      case "NewRetValMessageFromPeer":
        if (data["Path"] == "profile.name" && data["Exists"] == "true") {
          if (data["Data"].toString().trim().length > 0) {
            // Update locally on the UI...
            if (profileCN.getProfile(data["ProfileOnion"])?.contactList.findContact(data["RemotePeer"]) != null) {
              profileCN.getProfile(data["ProfileOnion"])?.contactList.findContact(data["RemotePeer"])!.nickname = data["Data"];
            }
          }
        } else if (data['Path'] == "profile.custom-profile-image") {
          if (data["Exists"] == "true") {
            EnvironmentConfig.debugLog("received ret val of custom profile image: $data");
            String fileKey = data['Data'];
            var contact = profileCN.getProfile(data["ProfileOnion"])?.contactList.findContact(data["RemotePeer"]);
            if (contact != null) {
              profileCN.getProfile(data["ProfileOnion"])?.waitForDownloadComplete(contact.identifier, fileKey);
            }
          }
        } else {
          EnvironmentConfig.debugLog("unhandled ret val event: ${data['Path']}");
        }
        break;
      case "ManifestSizeReceived":
        if (!profileCN.getProfile(data["ProfileOnion"])!.downloadActive(data["FileKey"])) {
          profileCN.getProfile(data["ProfileOnion"])?.downloadUpdate(data["FileKey"], 0, 1);
        }
        break;
      case "ManifestSaved":
        profileCN.getProfile(data["ProfileOnion"])?.downloadMarkManifest(data["FileKey"]);
        break;
      case "FileDownloadProgressUpdate":
        var progress = int.parse(data["Progress"]);
        profileCN.getProfile(data["ProfileOnion"])?.downloadUpdate(data["FileKey"], progress, int.parse(data["FileSizeInChunks"]));
        // progress == -1 is a "download was interrupted" message and should contain a path
        if (progress < 0) {
          profileCN.getProfile(data["ProfileOnion"])?.downloadSetPath(data["FileKey"], data["FilePath"]);
        }
        break;
      case "FileDownloaded":
        profileCN.getProfile(data["ProfileOnion"])?.downloadMarkFinished(data["FileKey"], data["FilePath"]);
        break;
      case "ImportingProfileEvent":
        break;
      case "StartingStorageMigration":
        appState.SetModalState(ModalState.storageMigration);
        break;
      case "DoneStorageMigration":
        appState.SetModalState(ModalState.none);
        break;
      case "ACNInfo":
        var key = data["Key"];
        var handle = data["Handle"];
        if (key == "circuit") {
          profileCN.getProfile(data["ProfileOnion"])?.contactList.findContact(handle)?.acnCircuit = data["Data"];
        }
        break;
      default:
        EnvironmentConfig.debugLog("unhandled event: $type");
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cwtch/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:win_toast/win_toast.dart';
import 'package:desktop_notifications/desktop_notifications.dart' as linux_notifications;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:flutter_local_notifications_linux/src/model/hint.dart';
import 'package:flutter_local_notifications_linux/src/model/icon.dart';


import 'package:path/path.dart' as path;

import 'config.dart';

// NotificationsManager provides a wrapper around platform specific notifications logic.
abstract class NotificationsManager {
  Future<void> notify(String message, String profile, int conversationId);
}

// NullNotificationsManager ignores all notification requests
class NullNotificationsManager implements NotificationsManager {
  @override
  Future<void> notify(String message, String profile, int conversationId) async {}
}

// Windows Notification Manager uses https://pub.dev/packages/desktoasts to implement
// windows notifications
class WindowsNotificationManager implements NotificationsManager {
  bool active = false;
  bool initialized = false;

  WindowsNotificationManager() {
    scheduleMicrotask(() async {
      initialized = await WinToast.instance().initialize(appName: 'cwtch', productName: 'Cwtch', companyName: 'Open Privacy Research Society');
    });
  }

  Future<void> notify(String message, String profile, int conversationId) async {
    if (initialized && !globalAppState.focus) {
      if (!active) {
        active = true;
        WinToast.instance().clear();
        final toast = await WinToast.instance().showToast(type: ToastType.text01, title: message);
        toast?.eventStream.listen((event) {
          if (event is ActivatedEvent) {
            WinToast.instance().bringWindowToFront();
          }
          active = false;
        });
      }
    }
  }
}

// LinuxNotificationsManager uses the desktop_notifications package to implement
// the standard dbus-powered linux desktop notifications.
class LinuxNotificationsManager implements NotificationsManager {
  int previous_id = 0;
  late linux_notifications.NotificationsClient client;
  late Future<void> Function(String, int) notificationSelectConvo;
  late String assetsPath;

  LinuxNotificationsManager(Future<void> Function(String, int) notificationSelectConvo) {
    this.client = linux_notifications.NotificationsClient();
    this.notificationSelectConvo = notificationSelectConvo;
    scheduleMicrotask(() async {
      assetsPath = await detectLinuxAssetsPath();
    });
  }

  // Cwtch can install in non flutter supported ways on linux, this code detects where the assets are on Linux
  Future<String> detectLinuxAssetsPath() async {
    var devStat = FileStat.stat("assets");
    var localStat = FileStat.stat("data/flutter_assets");
    var homeStat = FileStat.stat((Platform.environment["HOME"] ?? "") + "/.local/share/cwtch/data/flutter_assets");
    var rootStat = FileStat.stat("/usr/share/cwtch/data/flutter_assets");

    if ((await devStat).type == FileSystemEntityType.directory) {
      return Directory.current.path; //appPath;
    } else if ((await localStat).type == FileSystemEntityType.directory) {
      return path.join(Directory.current.path, "data/flutter_assets/");
    } else if ((await homeStat).type == FileSystemEntityType.directory) {
      return (Platform.environment["HOME"] ?? "") + "/.local/share/cwtch/data/flutter_assets/";
    } else if ((await rootStat).type == FileSystemEntityType.directory) {
      return "/usr/share/cwtch/data/flutter_assets/";
    }
    return "";
  }

  Future<void> notify(String message, String profile, int conversationId) async {
    var iconPath = Uri.file(path.join(assetsPath, "assets/knott.png"));
    client.notify(message, appName: "cwtch", appIcon: iconPath.toString(), replacesId: this.previous_id).then((linux_notifications.Notification value) async {
      previous_id = value.id;
      if ((await value.closeReason) == linux_notifications.NotificationClosedReason.dismissed) {
        this.notificationSelectConvo(profile, conversationId);
      }
    });
  }
}

class NotificationPayload {
  late String profileOnion;
  late int convoId;

  NotificationPayload(String po, int cid) {
    profileOnion = po;
    convoId = cid;
  }

  NotificationPayload.fromJson(Map<String, dynamic> json)
      : profileOnion = json['profileOnion'],
        convoId = json['convoId'];

  Map<String, dynamic> toJson() => {
        'profileOnion': profileOnion,
        'convoId': convoId,
      };
}

// FlutterLocalNotificationsPlugin based NotificationManager that handles MacOS
// Todo: work with author to allow settings of asset_path so we can use this for Linux and deprecate the LinuxNotificationManager
// Todo: it can also handle Android, do we want to migrate away from our manual solution?
class NixNotificationManager implements NotificationsManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Future<void> Function(String, int) notificationSelectConvo;
  late String linuxAssetsPath;


  // Cwtch can install in non flutter supported ways on linux, this code detects where the assets are on Linux
  Future<String> detectLinuxAssetsPath() async {
    //var devStat = FileStat.stat("assets");
    //var localStat = FileStat.stat("data/flutter_assets");
    var homeStat = FileStat.stat((Platform.environment["HOME"] ?? "") + "/.local/share/cwtch/data/flutter_assets");
    var rootStat = FileStat.stat("/usr/share/cwtch/data/flutter_assets");

    /*if ((await devStat).type == FileSystemEntityType.directory) {
      return Directory.current.path; //appPath;
    } else if ((await localStat).type == FileSystemEntityType.directory) {
      return path.join(Directory.current.path, "data/flutter_assets/");
    } else */if ((await homeStat).type == FileSystemEntityType.directory) {
      return (Platform.environment["HOME"] ?? "") + "/.local/share/cwtch/data/flutter_assets/";
    } else if ((await rootStat).type == FileSystemEntityType.directory) {
      return "/usr/share/cwtch/data/flutter_assets/";
    }
    return "";
  }

  NixNotificationManager(Future<void> Function(String, int) notificationSelectConvo) {
    this.notificationSelectConvo = notificationSelectConvo;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();



    scheduleMicrotask(() async {

      if (Platform.isLinux) {
        linuxAssetsPath = await detectLinuxAssetsPath();
        print("NixNotificationManager found LinuxAssetsPath!: $linuxAssetsPath");
      } else {
        linuxAssetsPath = "";
      }

      final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings(defaultPresentSound: false);
      var linuxIcon = FilePathLinuxIcon( path.join(linuxAssetsPath, 'assets/knott.png'));
      print("NixNotificationManager make linux settings");

      final LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'Open notification', defaultIcon: linuxIcon, defaultSuppressSound: true);

      print("NixNotificationManager InitializationSettings");

      final InitializationSettings initializationSettings = InitializationSettings(android: null, iOS: null, macOS: initializationSettingsMacOS, linux: initializationSettingsLinux);

      print("NixNotificationManager mac req perms");

      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: false,
            sound: false,
          );

      print("NixNotificationManager initialize...");
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
      print("NixNotificationManager initialized!!!");
    });
  }

  Future<void> notify(String message, String profile, int conversationId) async {
    print("notify if !globalAppState.focus so do? ${!globalAppState.focus}");
    if (!globalAppState.focus) {

      print("do notify!");

      // Warning: Only use title field on Linux, body field will render links as clickable
      await flutterLocalNotificationsPlugin.show(0, message, '',
          NotificationDetails(linux: LinuxNotificationDetails(suppressSound: true, category: LinuxNotificationCategory.imReceived(), icon: FilePathLinuxIcon(path.join(linuxAssetsPath, 'assets/knott.png')))),
          payload: jsonEncode(NotificationPayload(profile, conversationId)));

      print("done notify");
    }
  }

  // Notification click response function, triggers ui jump to conversation
  void selectNotification(String? payloadJson) async {
    if (payloadJson != null) {
      Map<String, dynamic> payloadMap = jsonDecode(payloadJson);
      var payload = NotificationPayload.fromJson(payloadMap);
      notificationSelectConvo(payload.profileOnion, payload.convoId);
    }
  }
}

NotificationsManager newDesktopNotificationsManager(Future<void> Function(String profileOnion, int convoId) notificationSelectConvo) {
  if (Platform.isLinux && !Platform.isAndroid) {
    try {
      return NixNotificationManager(notificationSelectConvo);
    } catch (e) {
      EnvironmentConfig.debugLog("Failed to create LinuxNotificationManager. Switching off notifications.");
    }
  } else if (Platform.isMacOS) {
    try {
      return NixNotificationManager(notificationSelectConvo);
    } catch (e) {
      EnvironmentConfig.debugLog("Failed to create NixNotificationManager. Switching off notifications.");
    }
  } else if (Platform.isWindows) {
    try {
      return WindowsNotificationManager();
    } catch (e) {
      EnvironmentConfig.debugLog("Failed to create Windows desktoasts notification manager");
    }
  }

  return NullNotificationsManager();
}

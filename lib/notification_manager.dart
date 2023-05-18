import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cwtch/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:win_toast/win_toast.dart';
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

  // TODO This needs testing and redefining...
  WindowsNotificationManager() {
    scheduleMicrotask(() async {
      initialized = await WinToast.instance().initialize(clsid: 'cwtch', displayName: 'Cwtch', aumId: 'Open Privacy Research Society', iconPath: '');
    });
  }

  Future<void> notify(String message, String profile, int conversationId) async {
    if (initialized && !globalAppState.focus) {
      if (!active) {
        active = true;
        // WinToast.instance().clear();
        //final toast = await WinToast.instance().showToast(toast: Toast(children: ,type: ToastType.text01, title: message));
        //toast?.eventStream.listen((event) {
        //  if (event is ActivatedEvent) {
        //   WinToast.instance().bringWindowToFront();
        // }
        active = false;
        // });
      }
    }
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

// FlutterLocalNotificationsPlugin based NotificationManager that handles MacOS <s>and Linux</s>
// TODO: Upgrade from 9.6 to 12.x but there are breaking changes (including for mac)
// TODO: Windows support is being worked on, check back and migrate to that too when it lands
class NixNotificationManager implements NotificationsManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Future<void> Function(String, int) notificationSelectConvo;
  late String linuxAssetsPath;

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

  NixNotificationManager(Future<void> Function(String, int) notificationSelectConvo) {
    this.notificationSelectConvo = notificationSelectConvo;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    scheduleMicrotask(() async {
      if (Platform.isLinux) {
        linuxAssetsPath = await detectLinuxAssetsPath();
      } else {
        linuxAssetsPath = "";
      }

      var linuxIcon = FilePathLinuxIcon(path.join(linuxAssetsPath, 'assets/knott.png'));

      final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification', defaultIcon: linuxIcon, defaultSuppressSound: true);

      final InitializationSettings initializationSettings =
          InitializationSettings(android: null, iOS: null, macOS: DarwinInitializationSettings(defaultPresentSound: false), linux: initializationSettingsLinux);

      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: false,
            sound: false,
          );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    });
  }

  Future<void> notify(String message, String profile, int conversationId) async {
    if (!globalAppState.focus) {
      // Warning: Only use title field on Linux, body field will render links as clickable
      await flutterLocalNotificationsPlugin.show(
          0,
          message,
          '',
          NotificationDetails(
              linux: LinuxNotificationDetails(suppressSound: true, category: LinuxNotificationCategory.imReceived, icon: FilePathLinuxIcon(path.join(linuxAssetsPath, 'assets/knott.png')))),
          payload: jsonEncode(NotificationPayload(profile, conversationId)));
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
  // We don't want notifications in Dev Mode
  if (EnvironmentConfig.TEST_MODE) {
    return NullNotificationsManager();
  }

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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cwtch/main.dart';
import 'package:win_toast/win_toast.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

// FlutterLocalNotificationsPlugin based NotificationManager that handles Linux and MacOS
// Todo: it can also handle Android, do we want to migrate away from our manual solution?
class NixNotificationManager implements NotificationsManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  late Future<void> Function(String, int) notificationSelectConvo;

  NixNotificationManager(Future<void> Function(String, int) notificationSelectConvo) {
    this.notificationSelectConvo = notificationSelectConvo;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
    final LinuxInitializationSettings initializationSettingsLinux =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('assets/knott.png'),
    );

    final InitializationSettings initializationSettings = InitializationSettings(android: null, iOS: null, macOS: initializationSettingsMacOS, linux: initializationSettingsLinux);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    scheduleMicrotask(() async {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
    });
  }

  void selectNotification(String? payloadJson) async {
    if (payloadJson != null) {
      Map<String, dynamic> payloadMap = jsonDecode(payloadJson);
      var  payload = NotificationPayload.fromJson(payloadMap);
      notificationSelectConvo(payload.profileOnion, payload.convoId);
    }
}

  Future<void> notify(String message, String profile, int conversationId) async {
    await flutterLocalNotificationsPlugin.show(0, 'Cwtch', message, null, payload: jsonEncode(NotificationPayload(profile, conversationId)));
  }
}

NotificationsManager newDesktopNotificationsManager(Future<void> Function(String profileOnion, int convoId) notificationSelectConvo) {
  if (Platform.isLinux || Platform.isMacOS) {
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

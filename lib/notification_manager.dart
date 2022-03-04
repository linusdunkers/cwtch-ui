import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cwtch/main.dart';
import 'package:win_toast/win_toast.dart';
//import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications_linux/flutter_local_notifications_linux.dart';
import 'package:flutter_local_notifications_linux/src/model/hint.dart';

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
    final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings(defaultPresentSound: false);
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification', defaultIcon: AssetsLinuxIcon('assets/knott.png'), defaultSuppressSound: true);

    final InitializationSettings initializationSettings = InitializationSettings(android: null, iOS: null, macOS: initializationSettingsMacOS, linux: initializationSettingsLinux);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: false,
          sound: false,
        );

    scheduleMicrotask(() async {
      await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
    });
  }

  Future<void> notify(String message, String profile, int conversationId) async {
    if (!globalAppState.focus) {
      // Warning: Only use title field on Linux, body field will render links as clickable
      await flutterLocalNotificationsPlugin.show(0, message, '', NotificationDetails(linux: LinuxNotificationDetails(suppressSound: true, category: LinuxNotificationCategory.imReceived())),
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
  if ((Platform.isLinux && !Platform.isAndroid) || Platform.isMacOS) {
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

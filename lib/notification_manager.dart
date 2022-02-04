import 'dart:async';
import 'dart:io';

import 'package:cwtch/main.dart';
import 'package:win_toast/win_toast.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:path/path.dart' as path;

import 'config.dart';

// NotificationsManager provides a wrapper around platform specific notifications logic.
abstract class NotificationsManager {
  Future<void> notify(String message);
}

// NullNotificationsManager ignores all notification requests
class NullNotificationsManager implements NotificationsManager {
  @override
  Future<void> notify(String message) async {}
}

// LinuxNotificationsManager uses the desktop_notifications package to implement
// the standard dbus-powered linux desktop notifications.
class LinuxNotificationsManager implements NotificationsManager {
  int previous_id = 0;
  late NotificationsClient client;

  LinuxNotificationsManager(NotificationsClient client) {
    this.client = client;
  }

  Future<void> notify(String message) async {
    var iconPath = Uri.file(path.join(path.current, "cwtch.png"));
    client.notify(message, appName: "cwtch", appIcon: iconPath.toString(), replacesId: this.previous_id).then((Notification value) => previous_id = value.id);
  }
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

  Future<void> notify(String message) async {
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

NotificationsManager newDesktopNotificationsManager() {
  if (Platform.isLinux) {
    try {
      // Test that we can actually access DBUS. Otherwise return a null
      // notifications manager...
      NotificationsClient client = NotificationsClient();
      client.getCapabilities();
      return LinuxNotificationsManager(client);
    } catch (e) {
      EnvironmentConfig.debugLog("Attempted to access DBUS for notifications but failed. Switching off notifications.");
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

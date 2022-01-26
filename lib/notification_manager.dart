import 'dart:io';

import 'package:cwtch/main.dart';
import 'package:desktoasts/desktoasts.dart';
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
  late ToastService service;
  bool active = false;

  WindowsNotificationManager() {
    service = new ToastService(
      appName: 'cwtch',
      companyName: 'Open Privacy Research Society',
      productName: 'Cwtch',
    );

    service.stream.listen((event) {
      // the user closed the notification of the OS timed it out
      if (event is ToastDismissed) {
        active = false;
      }
      // clicked
      if (event is ToastActivated) {
          active = false;
      }
      // if a supplied action was clicked
      if (event is ToastInteracted) {
        active = false;
      }
    });
  }

  Future<void> notify(String message) async {
    if (!globalAppState.focus) {
      if (!active) {
        // One string of bold text on the first line (title),
        // one string (subtitle) of regular text wrapped across the second and third lines.
        Toast toast = new Toast(
          type: ToastType.text02,
          title: 'Cwtch',
          subtitle: message,
        );
        service.show(toast);
        active = true;
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
      EnvironmentConfig.debugLog(
          "Attempted to access DBUS for notifications but failed. Switching off notifications.");
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

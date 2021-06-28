import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:path/path.dart' as path;

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
      client.notify(message, appName: "cwtch",
          appIcon: iconPath.toString(),
          replacesId: this.previous_id).then((Notification value) =>
      previous_id = value.id);
  }
}

NotificationsManager newDesktopNotificationsManager() {
  try {
    // Test that we can actually access DBUS. Otherwise return a null
    // notifications manager...
    NotificationsClient client = NotificationsClient();
    client.getCapabilities();
    return LinuxNotificationsManager(client);
  } catch (e) {
    print("Attempted to access DBUS for notifications but failed. Switching off notifications.");
  }
  return NullNotificationsManager();
}
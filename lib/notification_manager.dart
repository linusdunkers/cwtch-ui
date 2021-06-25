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
  final NotificationsClient client = NotificationsClient();
  LinuxNotificationsManager() {}
  Future<void> notify(String message) async {
    var icon_path = Uri.file(path.join(path.current, "cwtch.png"));
    client.notify(message, appName: "cwtch", appIcon: icon_path.toString(), replacesId: this.previous_id).then((Notification value) => previous_id = value.id);
  }
}

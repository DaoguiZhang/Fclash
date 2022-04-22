import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kommon/kommon.dart';

class NotificationService extends GetxService {
  FlutterLocalNotificationsPlugin notification =
      FlutterLocalNotificationsPlugin();
  var id = 0;

  Future<NotificationService> init() async {
    await notification.initialize(const InitializationSettings(
        linux: LinuxInitializationSettings(defaultActionName: 'act')));
    return this;
  }

  Future<void> showNotification(String title, String body) async {
    await notification.show(
        id++,
        title,
        body,
        const NotificationDetails(
            linux: LinuxNotificationDetails(
                urgency: LinuxNotificationUrgency.critical)));
  }
}

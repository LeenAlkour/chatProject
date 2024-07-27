import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// دالة لاستقبال الإشعارات في الخلفية
void onDidReceiveBackgroundNotificationResponse(NotificationResponse details) {
  print("Notification clicked!");
  print(details.payload);
}

class LocalNotification {
  static final FlutterLocalNotificationsPlugin _notiPlugin = FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    _notiPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );
  }

  static void showNotification(RemoteMessage message) {
    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.example.testnoti',
        'push_notification',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    _notiPlugin.show(
      DateTime.now().microsecond,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: message.data.toString(),
    );
  }
}

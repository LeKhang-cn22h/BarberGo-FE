// lib/services/simple_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:typed_data';

class SimpleNotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  /// Khởi tạo - Gọi 1 lần trong main.dart
  static Future<void> init() async {
    // Setup timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Setup Android
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings);

    print(' Notification ready!');
  }

  /// Thông báo trước giờ đặt lịch
  static Future<void> scheduleReminder({
    required int id,
    required DateTime time,
    required String title,
    required String message,
    int minutesBefore = 30,
  }) async {
    // Tính thời gian thông báo
    final notifyTime = time.subtract(Duration(minutes: minutesBefore));

    // Nếu đã qua thì bỏ qua
    if (notifyTime.isBefore(DateTime.now())) {
      print('⚠Time passed, skip notification');
      return;
    }

    // Convert sang timezone
    final scheduledDate = tz.TZDateTime.from(notifyTime, tz.local);

    final android = AndroidNotificationDetails(
      'booking_reminder',
      'Nhắc lịch đặt',
      channelDescription: 'Thông báo nhắc lịch đặt',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    );

    final details = NotificationDetails(android: android);

    // Lên lịch notification
    await _notifications.zonedSchedule(
      id,
      title,
      message,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    print('Scheduled notification #$id at $scheduledDate');
  }

  /// Hủy thông báo
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
    print('Cancelled notification #$id');
  }

  /// Test thông báo ngay
  static Future<void> testNow() async {
    const android = AndroidNotificationDetails(
      'test',
      'Test',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications.show(
      999,
      ' Test thông báo',
      'Nếu thấy được thì đã hoạt động!',
      const NotificationDetails(android: android),
    );
  }
}
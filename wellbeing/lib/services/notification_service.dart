import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel(
    'com.wellbeing.notifications',
  );

  static Future<int> getDailyNotificationCount() async {
    try {
      final int count = await _channel.invokeMethod(
        'getDailyNotificationCount',
      );
      return count;
    } on PlatformException catch (e) {
      print("Failed to get notification count: '${e.message}'.");
      return 0;
    }
  }

  static Future<int> getDailyAppOpens() async {
    try {
      final int count = await _channel.invokeMethod('getDailyAppOpens');
      return count;
    } on PlatformException catch (e) {
      print("Failed to get app opens count: '${e.message}'.");
      return 0;
    }
  }
}

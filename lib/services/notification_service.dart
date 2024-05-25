import 'package:flutter/services.dart';

class NotificationService {
  static const MethodChannel _channel = MethodChannel('Notifications');

  Future<dynamic> getDeliveredNotifications() async {
    return await _channel.invokeMethod('getDeliveredNotifications');
  }

  Future<void> removeChannelNotifications() async {
    await _channel.invokeMethod('removeChannelNotifications');
  }

  Future<void> removeThreadNotifications() async {
    await _channel.invokeMethod('removeThreadNotifications');
  }

  Future<void> removeServerNotifications() async {
    await _channel.invokeMethod('removeServerNotifications');
  }
}

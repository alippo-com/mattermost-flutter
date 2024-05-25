// Converted from TypeScript (React Native) to Dart (Flutter)
// Original file: ./mattermost-mobile/app/notifications/index.ts
// This Dart file uses the package `flutter_native` to handle native modules.

import 'package:flutter_native/flutter_native.dart';

class NativeNotification {
  Future<void> getDeliveredNotifications() async {
    return await Notifications.getDeliveredNotifications();
  }

  Future<void> removeChannelNotifications() async {
    return await Notifications.removeChannelNotifications();
  }

  Future<void> removeThreadNotifications() async {
    return await Notifications.removeThreadNotifications();
  }

  Future<void> removeServerNotifications() async {
    return await Notifications.removeServerNotifications();
  }
}

final NativeNotification nativeNotification = NativeNotification();
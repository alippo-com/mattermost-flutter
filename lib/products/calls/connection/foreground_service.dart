// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:mattermost_flutter/utils/log.dart';

final channelConfig = NotificationChannel(
  id: 'calls_channel',
  name: 'Mattermost',
  description: 'Mattermost Calls microphone while app is in the background',
  vibration: false,
);

void foregroundServiceSetup() {
  FlutterForegroundTask().createNotificationChannel(channelConfig);
}

Future<void> foregroundServiceStart() async {
  final notificationConfig = NotificationOptions(
    channelId: 'calls_channel',
    id: 345678,
    title: 'Mattermost',
    text: 'Mattermost Calls Microphone',
    iconData: const NotificationIconData(
      resType: ResourceType.drawable,
      resPrefix: ResourcePrefix.ic,
      name: 'launcher',
    ),
    buttons: [
      const NotificationButton(id: 'stop', text: 'Stop'),
    ],
  );
  try {
    await FlutterForegroundTask().startService(notificationConfig: notificationConfig);
  } catch (e) {
    logError('Calls: Cannot start ForegroundService, error: $e');
  }
}

Future<void> foregroundServiceStop() async {
  await FlutterForegroundTask().stopService();
}

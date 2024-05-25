
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:async';
import 'package:flutter/foundation.dart';

class NativeNotification {
  Future<List<NotificationWithChannel>> getDeliveredNotifications() async {}
  void removeChannelNotifications(String serverUrl, String channelId) {}
  void removeThreadNotifications(String serverUrl, String threadId) {}
  void removeServerNotifications(String serverUrl) {}
}

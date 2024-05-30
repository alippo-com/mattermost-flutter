// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Import statements can be adjusted according to actual project structure in Flutter
import 'package:mattermost_flutter/types/localization.dart';

// Needed for localization on iOS native side
const notVerifiedErrorMessage = LocalizedString(
  id: 'native.ios.notifications.not_verified',
  message: 'We could not verify this notification with the server',
);

const CATEGORY = 'CAN_REPLY';

const REPLY_ACTION = 'REPLY_ACTION';

const NOTIFICATION_TYPE = {
  'CLEAR': 'clear',
  'MESSAGE': 'message',
  'SESSION': 'session',
};

const NOTIFICATION_SUB_TYPE = {
  'CALLS': 'calls',
};

final notificationConstants = {
  'CATEGORY': CATEGORY,
  'NOTIFICATION_TYPE': NOTIFICATION_TYPE,
  'REPLY_ACTION': REPLY_ACTION,
};

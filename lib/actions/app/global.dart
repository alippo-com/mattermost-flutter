// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/init/credentials.dart';
import 'package:mattermost_flutter/utils/log.dart';

Future<void> storeGlobal(String id, dynamic value, {bool prepareRecordsOnly = false}) async {
  try {
    final operator = DatabaseManager.getAppDatabaseAndOperator().operator;
    await operator.handleGlobal({
      'globals': [{'id': id, 'value': value}],
      'prepareRecordsOnly': prepareRecordsOnly,
    });
  } catch (error) {
    logError('storeGlobal', error);
    throw error;
  }
}

Future<void> storeDeviceToken(String token, {bool prepareRecordsOnly = false}) async {
  return storeGlobal(GLOBAL_IDENTIFIERS.DEVICE_TOKEN, token, prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeOnboardingViewedValue({bool value = true}) async {
  return storeGlobal(GLOBAL_IDENTIFIERS.ONBOARDING, value);
}

Future<void> storeMultiServerTutorial({bool prepareRecordsOnly = false}) async {
  return storeGlobal(Tutorial.MULTI_SERVER, 'true', prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeProfileLongPressTutorial({bool prepareRecordsOnly = false}) async {
  return storeGlobal(Tutorial.PROFILE_LONG_PRESS, 'true', prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeSkinEmojiSelectorTutorial({bool prepareRecordsOnly = false}) async {
  return storeGlobal(Tutorial.EMOJI_SKIN_SELECTOR, 'true', prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeDontAskForReview({bool prepareRecordsOnly = false}) async {
  return storeGlobal(GLOBAL_IDENTIFIERS.DONT_ASK_FOR_REVIEW, 'true', prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeLastAskForReview({bool prepareRecordsOnly = false}) async {
  return storeGlobal(GLOBAL_IDENTIFIERS.LAST_ASK_FOR_REVIEW, DateTime.now().millisecondsSinceEpoch, prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeFirstLaunch({bool prepareRecordsOnly = false}) async {
  return storeGlobal(GLOBAL_IDENTIFIERS.FIRST_LAUNCH, DateTime.now().millisecondsSinceEpoch, prepareRecordsOnly: prepareRecordsOnly);
}

Future<void> storeLastViewedChannelIdAndServer(String channelId) async {
  final currentServerUrl = await getActiveServerUrl();
  return storeGlobal(
    GLOBAL_IDENTIFIERS.LAST_VIEWED_CHANNEL,
    {'server_url': currentServerUrl, 'channel_id': channelId},
  );
}

Future<void> storeLastViewedThreadIdAndServer(String threadId) async {
  final currentServerUrl = await getActiveServerUrl();
  return storeGlobal(
    GLOBAL_IDENTIFIERS.LAST_VIEWED_THREAD,
    {'server_url': currentServerUrl, 'thread_id': threadId},
  );
}

Future<void> removeLastViewedChannelIdAndServer() async {
  return storeGlobal(GLOBAL_IDENTIFIERS.LAST_VIEWED_CHANNEL, null);
}

Future<void> removeLastViewedThreadIdAndServer() async {
  return storeGlobal(GLOBAL_IDENTIFIERS.LAST_VIEWED_THREAD, null);
}

Future<void> storePushDisabledInServerAcknowledged(String serverUrl) async {
  return storeGlobal('${GLOBAL_IDENTIFIERS.PUSH_DISABLED_ACK}$serverUrl', 'true');
}

Future<void> removePushDisabledInServerAcknowledged(String serverUrl) async {
  return storeGlobal('${GLOBAL_IDENTIFIERS.PUSH_DISABLED_ACK}$serverUrl', null);
}

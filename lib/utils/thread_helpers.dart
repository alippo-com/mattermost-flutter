// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/types/database/models/servers/preference.dart';

bool processIsCRTAllowed(String? configValue) {
  return configValue != null && configValue.isNotEmpty && configValue != Config.DISABLED;
}

bool processIsCRTEnabled(List<PreferenceModel> preferences, {String? configValue, String? featureFlag, String? version}) {
  var preferenceDefault = Preferences.COLLAPSED_REPLY_THREADS_OFF;
  if (configValue == Config.DEFAULT_ON) {
    preferenceDefault = Preferences.COLLAPSED_REPLY_THREADS_ON;
  }
  var preference = getDisplayNamePreference<String>(preferences, Preferences.COLLAPSED_REPLY_THREADS, preferenceDefault);

  // CRT Feature flag removed in 7.6
  var isFeatureFlagEnabled = version != null && isMinimumServerVersion(version, 7, 6) ? true : featureFlag == Config.TRUE;

  var isAllowed = isFeatureFlagEnabled && configValue != Config.DISABLED;

  return isAllowed && (preference == Preferences.COLLAPSED_REPLY_THREADS_ON || configValue == Config.ALWAYS_ON);
}

Map<String, Thread> getThreadsListEdges(List<Thread> threads) {
  // Sort a clone of 'threads' list by last_reply_at
  var sortedThreads = List<Thread>.from(threads)..sort((a, b) => a.lastReplyAt.compareTo(b.lastReplyAt));

  var earliestThread = sortedThreads.first;
  var latestThread = sortedThreads.last;

  return {'earliestThread': earliestThread, 'latestThread': latestThread};
}

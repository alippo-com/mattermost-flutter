// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:convert';
import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/actions/remote/preference.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/types/web_socket_message.dart';
import 'package:mattermost_flutter/types/preference_type.dart';

Future<void> handlePreferenceChangedEvent(String serverUrl, WebSocketMessage msg) async {
  if (EphemeralStore.isEnablingCRT()) {
    return;
  }

  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final preference = PreferenceType.fromJson(jsonDecode(msg.data['preference']));
    await handleSavePostAdded(serverUrl, [preference]);

    final hasDiffNameFormatPref = await differsFromLocalNameFormat(databaseAndOperator.database, [preference]);
    final crtToggled = await getHasCRTChanged(databaseAndOperator.database, [preference]);

    await databaseAndOperator.operator.handlePreferences(
      prepareRecordsOnly: false,
      preferences: [preference],
    );

    if (hasDiffNameFormatPref) {
      updateDmGmDisplayName(serverUrl);
    }

    if (crtToggled) {
      handleCRTToggled(serverUrl);
    }
  } catch (error) {
    // Do nothing
  }
}

Future<void> handlePreferencesChangedEvent(String serverUrl, WebSocketMessage msg) async {
  if (EphemeralStore.isEnablingCRT()) {
    return;
  }

  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final preferences = (jsonDecode(msg.data['preferences']) as List)
        .map((pref) => PreferenceType.fromJson(pref))
        .toList();
    await handleSavePostAdded(serverUrl, preferences);

    final hasDiffNameFormatPref = await differsFromLocalNameFormat(databaseAndOperator.database, preferences);
    final crtToggled = await getHasCRTChanged(databaseAndOperator.database, preferences);

    await databaseAndOperator.operator.handlePreferences(
      prepareRecordsOnly: false,
      preferences: preferences,
    );

    if (hasDiffNameFormatPref) {
      updateDmGmDisplayName(serverUrl);
    }

    if (crtToggled) {
      handleCRTToggled(serverUrl);
    }
  } catch (error) {
    // Do nothing
  }
}

Future<void> handlePreferencesDeletedEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final preferences = (jsonDecode(msg.data['preferences']) as List)
        .map((pref) => PreferenceType.fromJson(pref))
        .toList();
    await deletePreferences(databaseAndOperator, preferences);
  } catch (error) {
    // Do nothing
  }
}

Future<void> handleSavePostAdded(String serverUrl, List<PreferenceType> preferences) async {
  try {
    final database = await DatabaseManager.getServerDatabase(serverUrl);
    final savedPosts = preferences.where((p) => p.category == Preferences.CATEGORIES.SAVED_POST).toList();

    for (final saved in savedPosts) {
      final post = await getPostById(database, saved.name);
      if (post == null) {
        await fetchPostById(serverUrl, saved.name, false);
      }
    }
  } catch (error) {
    // Do nothing
  }
}

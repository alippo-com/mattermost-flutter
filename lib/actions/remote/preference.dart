// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';

import 'package:mattermost_flutter/actions/websocket.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/entry.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/utils/channel.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/user.dart';

import 'session.dart';

import 'package:mattermost_flutter/types/database/models/servers/channel.dart';

class MyPreferencesRequest {
  List<PreferenceType>? preferences;
  dynamic error;

  MyPreferencesRequest({this.preferences, this.error});
}

Future<MyPreferencesRequest> fetchMyPreferences(String serverUrl, [bool fetchOnly = false]) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final preferences = await client.getMyPreferences();

    if (!fetchOnly) {
      await operator.handlePreferences(
        prepareRecordsOnly: false,
        preferences: preferences,
        sync: true,
      );
    }

    return MyPreferencesRequest(preferences: preferences);
  } catch (error) {
    logDebug('error on fetchMyPreferences', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return MyPreferencesRequest(error: error);
  }
}

Future<void> saveFavoriteChannel(String serverUrl, String channelId, bool isFavorite) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final userId = await getCurrentUserId(database);
    final favPref = PreferenceType(
      category: Preferences.CATEGORIES.FAVORITE_CHANNEL,
      name: channelId,
      userId: userId,
      value: isFavorite.toString(),
    );
    await savePreference(serverUrl, [favPref]);
  } catch (error) {
    return {'error': error};
  }
}

Future<void> savePostPreference(String serverUrl, String postId) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final userId = await getCurrentUserId(database);
    final pref = PreferenceType(
      userId: userId,
      category: Preferences.CATEGORIES.SAVED_POST,
      name: postId,
      value: 'true',
    );
    await savePreference(serverUrl, [pref]);
  } catch (error) {
    return {'error': error};
  }
}

Future<void> savePreference(String serverUrl, List<PreferenceType> preferences, [bool prepareRecordsOnly = false]) async {
  try {
    if (preferences.isEmpty) {
      return {'preferences': []};
    }

    final client = NetworkManager.getClient(serverUrl);
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseOperator.database;
    final operator = databaseOperator.operator;

    final userId = await getCurrentUserId(database);
    const chunkSize = 100;
    final chunks = partition(preferences, chunkSize);
    for (final c in chunks) {
      await client.savePreferences(userId, c);
    }
    final preferenceModels = await operator.handlePreferences(
      preferences: preferences,
      prepareRecordsOnly: prepareRecordsOnly,
    );

    return {'preferences': preferenceModels};
  } catch (error) {
    logDebug('error on savePreference', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<void> deleteSavedPost(String serverUrl, String postId) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final client = NetworkManager.getClient(serverUrl);
    final userId = await getCurrentUserId(database);
    final records = await querySavedPostsPreferences(database, postId).fetch();
    final postPreferenceRecord = records.firstWhereOrNull((r) => postId == r.name);
    final pref = PreferenceType(
      userId: userId,
      category: Preferences.CATEGORIES.SAVED_POST,
      name: postId,
      value: 'true',
    );

    if (postPreferenceRecord != null) {
      await client.deletePreferences(userId, [pref]);
      await postPreferenceRecord.destroyPermanently();
    }

    return {'preference': pref};
  } catch (error) {
    logDebug('error on deleteSavedPost', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<void> openChannelIfNeeded(String serverUrl, String channelId) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final channel = await getChannelById(database, channelId);
    if (channel == null || !isDMorGM(channel)) {
      return {};
    }
    final res = await openChannels(serverUrl, [channel]);
    return res;
  } catch (error) {
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<void> openAllUnreadChannels(String serverUrl) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final channels = await queryAllUnreadDMsAndGMsIds(database).fetch();
    final res = await openChannels(serverUrl, channels);
    return res;
  } catch (error) {
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<void> openChannels(String serverUrl, List<ChannelModel> channels) async {
  final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
  final userId = await getCurrentUserId(database);

  final directChannelShowPreferences = await queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.DIRECT_CHANNEL_SHOW).fetch();
  final groupChannelShowPreferences = await queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.GROUP_CHANNEL_SHOW).fetch();
  final showPreferences = [...directChannelShowPreferences, ...groupChannelShowPreferences];

  final prefs = <PreferenceType>[];
  for (final channel in channels) {
    final category = channel.type == General.DM_CHANNEL ? Preferences.CATEGORIES.DIRECT_CHANNEL_SHOW : Preferences.CATEGORIES.GROUP_CHANNEL_SHOW;
    final name = channel.type == General.DM_CHANNEL ? getUserIdFromChannelName(userId, channel.name) : channel.id;
    final visible = getPreferenceAsBool(showPreferences, category, name, false);
    if (visible) {
      continue;
    }

    prefs.addAll([
      PreferenceType(
        userId: userId,
        category: category,
        name: name,
        value: 'true',
      ),
      PreferenceType(
        userId: userId,
        category: Preferences.CATEGORIES.CHANNEL_OPEN_TIME,
        name: channel.id,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      ),
    ]);
  }

  await savePreference(serverUrl, prefs);
}

Future<void> setDirectChannelVisible(String serverUrl, String channelId, [bool visible = true]) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final channel = await getChannelById(database, channelId);
    if (channel?.type == General.DM_CHANNEL || channel?.type == General.GM_CHANNEL) {
      final userId = await getCurrentUserId(database);
      final category = channel.type == General.DM_CHANNEL ? Preferences.CATEGORIES.DIRECT_CHANNEL_SHOW : Preferences.CATEGORIES.GROUP_CHANNEL_SHOW;
      final name = channel.type == General.DM_CHANNEL ? getUserIdFromChannelName(userId, channel.name) : channelId;
      final pref = PreferenceType(
        userId: userId,
        category: category,
        name: name,
        value: visible.toString(),
      );
      await savePreference(serverUrl, [pref]);
    }

    return {};
  } catch (error) {
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<void> savePreferredSkinTone(String serverUrl, String skinCode) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final userId = await getCurrentUserId(database);
    final pref = PreferenceType(
      userId: userId,
      category: Preferences.CATEGORIES.EMOJI,
      name: Preferences.EMOJI_SKINTONE,
      value: skinCode,
    );
    await savePreference(serverUrl, [pref]);
  } catch (error) {
    return {'error': error};
  }
}

Future<void> handleCRTToggled(String serverUrl) async {
  final currentServerUrl = await DatabaseManager.getActiveServerUrl();
  await truncateCrtRelatedTables(serverUrl);
  await handleReconnect(serverUrl);
  EphemeralStore.setEnablingCRT(false);
  ServicesBinding.instance.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const StandardMethodCodec().encodeSuccessEnvelope(<String, dynamic>{'type': Events.CRT_TOGGLED, 'serverUrl': serverUrl == currentServerUrl}),
    (_) {},
  );
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/constants.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/types/preference_type.dart';
import 'package:mattermost_flutter/types/theme.dart';

Future<List<PreferenceModel>> prepareMyPreferences(ServerDataOperator operator, List<PreferenceType> preferences, [bool sync = false]) async {
  return await operator.handlePreferences(
    prepareRecordsOnly: true,
    preferences: preferences,
    sync: sync,
  );
}

Query<PreferenceModel> queryPreferencesByCategoryAndName(Database database, String category, {String? name, String? value}) {
  final clauses = [Q.where('category', category)];
  if (name != null) {
    clauses.add(Q.where('name', name));
  }
  if (value != null) {
    clauses.add(Q.where('value', value));
  }
  return database.get<PreferenceModel>(MM_TABLES.SERVER.PREFERENCE).query(...clauses);
}

Future<Theme?> getThemeForCurrentTeam(Database database) async {
  final currentTeamId = await getCurrentTeamId(database);
  final teamTheme = await queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.THEME, name: currentTeamId).fetch();
  if (teamTheme.isNotEmpty) {
    try {
      return Theme.fromJson(teamTheme[0].value);
    } catch {
      return null;
    }
  }

  return null;
}

Future<bool> deletePreferences(ServerDatabase database, List<PreferenceType> preferences) async {
  try {
    final preparedModels = <Model>[];
    for (final pref in preferences) {
      final myPrefs = await queryPreferencesByCategoryAndName(database.database, pref.category, name: pref.name).fetch();
      for (final p in myPrefs) {
        preparedModels.add(p.prepareDestroyPermanently());
      }
    }
    if (preparedModels.isNotEmpty) {
      await database.operator.batchRecords(preparedModels, 'deletePreferences');
    }
    return true;
  } catch (error) {
    return false;
  }
}

Future<bool> differsFromLocalNameFormat(Database database, List<PreferenceType> preferences) async {
  final displayPref = getPreferenceValue<String>(preferences, Preferences.CATEGORIES.DISPLAY_SETTINGS, Preferences.NAME_NAME_FORMAT);
  if (displayPref.isEmpty) {
    return false;
  }

  final currentPref = await queryDisplayNamePreferences(database, name: Preferences.NAME_NAME_FORMAT, value: displayPref).fetch();
  return currentPref.isEmpty;
}

Future<bool> getHasCRTChanged(Database database, List<PreferenceType> preferences) async {
  final oldCRT = await getIsCRTEnabled(database);
  final newCRTPref = preferences.firstWhere((p) => p.name == Preferences.COLLAPSED_REPLY_THREADS, orElse: () => null);

  if (newCRTPref == null) {
    return false;
  }

  final newCRT = newCRTPref.value == 'on';

  return oldCRT != newCRT;
}

Query<PreferenceModel> queryDisplayNamePreferences(Database database, {String? name, String? value}) {
  return queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.DISPLAY_SETTINGS, name: name, value: value);
}

Query<PreferenceModel> querySavedPostsPreferences(Database database, {String? postId, String? value}) {
  return queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.SAVED_POST, name: postId, value: value);
}

Query<PreferenceModel> queryThemePreferences(Database database, {String? teamId}) {
  return queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.THEME, name: teamId);
}

Query<PreferenceModel> querySidebarPreferences(Database database, {String? name}) {
  return queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.SIDEBAR_SETTINGS, name: name);
}

Query<PreferenceModel> queryEmojiPreferences(Database database, {required String name}) {
  return queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.EMOJI, name: name);
}

Query<PreferenceModel> queryAdvanceSettingsPreferences(Database database, {String? name, String? value}) {
  return queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.ADVANCED_SETTINGS, name: name, value: value);
}

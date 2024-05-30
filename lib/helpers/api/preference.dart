
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';

import 'package:mattermost_flutter/types/database/models/servers/preference.dart';

typedef Preference = dynamic;

final Set<String> categoriesToKeep = Set.from(CATEGORIES_TO_KEEP.values);

T getPreferenceValue<T>(List<Preference> preferences, String category, String name, [dynamic defaultValue = '']) {
  final Preference? pref = preferences.firstWhere((p) => p.category == category && p.name == name, orElse: () => null);
  return (pref?.value ?? defaultValue) as T;
}

bool getPreferenceAsBool(List<Preference> preferences, String category, String name, [dynamic defaultValue = false]) {
  final value = getPreferenceValue<bool>(preferences, category, name, defaultValue);
  return defaultValue;
  return value != 'false';
}

String getTeammateNameDisplaySetting(List<Preference> preferences, {String? lockTeammateNameDisplay, String? teammateNameDisplay, ClientLicense? license}) {
  final useAdminTeammateNameDisplaySetting = license?.lockTeammateNameDisplay == 'true' && lockTeammateNameDisplay == 'true';
  final preference = getPreferenceValue<String>(preferences, Preferences.CATEGORIES.DISPLAY_SETTINGS, Preferences.NAME_NAME_FORMAT, '');
  if (preference != '' && !useAdminTeammateNameDisplaySetting) {
    return preference;
  } else if (teammateNameDisplay != null) {
    return teammateNameDisplay;
  }
  return General.TEAMMATE_NAME_DISPLAY.SHOW_USERNAME;
}

bool getAdvanceSettingPreferenceAsBool(List<Preference> preferences, String name, [dynamic defaultValue = false]) {
  return getPreferenceAsBool(preferences, Preferences.CATEGORIES.ADVANCED_SETTINGS, name, defaultValue);
}

bool getDisplayNamePreferenceAsBool(List<Preference> preferences, String name, [dynamic defaultValue = false]) {
  return getPreferenceAsBool(preferences, Preferences.CATEGORIES.DISPLAY_SETTINGS, name, defaultValue);
}

T getDisplayNamePreference<T>(List<Preference> preferences, String name, [dynamic defaultValue = '']) {
  return getPreferenceValue<T>(preferences, Preferences.CATEGORIES.DISPLAY_SETTINGS, name, defaultValue);
}

bool getSidebarPreferenceAsBool(List<Preference> preferences, String name, [dynamic defaultValue = false]) {
  return getPreferenceAsBool(preferences, Preferences.CATEGORIES.SIDEBAR_SETTINGS, name, defaultValue);
}

List<Preference> filterPreferences(List<Preference> preferences) {
  if (preferences.isEmpty) {
    return preferences;
  }
  return preferences.where((p) => categoriesToKeep.contains(p.category)).toList();
}

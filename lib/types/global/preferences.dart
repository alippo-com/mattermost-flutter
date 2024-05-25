// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class PreferenceType {
  String category;
  String name;
  String user_id;
  String value;

  PreferenceType(
      {required this.category,
      required this.name,
      required this.user_id,
      required this.value});
}

class PreferencesType {
  Map<String, PreferenceType> preferences = Map();
}

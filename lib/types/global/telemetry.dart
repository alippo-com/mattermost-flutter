
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

abstract class RudderClient {
  Future<void> setup(String key, dynamic options);
  void track(String event, Map<String, dynamic> properties, [Map<String, dynamic> options]);
  Future<void> identify(String userId, Map<String, dynamic> traits, [Map<String, dynamic> options]);
  void screen(String name, Map<String, dynamic> properties, [Map<String, dynamic> options]);
  Future<void> reset();
}

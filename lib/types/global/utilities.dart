// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

abstract class RudderClient {
  Future<void> setup(String key, dynamic options);
  void track(String event, Map<String, dynamic> properties,
      [Map<String, dynamic> options]);
  Future<void> identify(String userId, Map<String, dynamic> traits,
      [Map<String, dynamic> options]);
  void screen(String name, Map<String, dynamic> properties,
      [Map<String, dynamic> options]);
  Future<void> reset();
}

class E {
  String id, user_id, name, username, email;

  E(
      {required this.id,
      required this.user_id,
      required this.name,
      required this.username,
      required this.email});
}

class T {}

class RelationOneToOne {
  Map<String, T> map = Map();
}

class RelationOneToMany {
  Map<String, List<String>> map = Map();
}

class IDMappedObjects extends RelationOneToOne {}

class UserIDMappedObjects {
  Map<String, E> map = Map();
}

class NameMappedObjects {
  Map<String, E> map = Map();
}

class UsernameMappedObjects {
  Map<String, E> map = Map();
}

class EmailMappedObjects {
  Map<String, E> map = Map();
}

class Dictionary<T> {
  Map<String, T> map = Map();
}

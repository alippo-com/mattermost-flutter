// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

Map<String, dynamic> keyMirror(List<String> keys) {
  return Map.fromIterable(keys, key: (item) => item, value: (item) => null);
}

final Map<String, dynamic> tabTypes = keyMirror(['MESSAGES', 'FILES']);

typedef TabType = String;
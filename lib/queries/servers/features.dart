// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants/versions.dart';
import 'package:mattermost_flutter/utils/helpers.dart';
'./system.dart';

import 'package:watermelondb/watermelondb.dart';

Stream<bool> observeHasGMasDMFeature(Database database) {
  return observeConfigValue(database, 'Version').switchMap((v) {
    return Stream.value(isMinimumServerVersion(v, GM_AS_DM_VERSION[0], GM_AS_DM_VERSION[1], GM_AS_DM_VERSION[2]));
  });
}

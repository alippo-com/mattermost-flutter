
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

class InfoSchema {
  static final String tableName = MM_TABLES.APP.INFO;

  static final List<Map<String, dynamic>> columns = [
    {'name': 'build_number', 'type': 'String'},
    {'name': 'created_at', 'type': 'int'},
    {'name': 'version_number', 'type': 'String'},
  ];
}

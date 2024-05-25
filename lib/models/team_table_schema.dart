// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

final String tableRole = MM_TABLES.SERVER.ROLE;

class TeamTableSchema {
  static final tableName = tableRole;
  static final columns = [
    ColumnSchema(name: 'name', type: 'string', isIndexed: true),
    ColumnSchema(name: 'permissions', type: 'string'),
  ];
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:nozbe_watermelondb/nozbe_watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/schema.dart';

class TeamThreadsSyncSchema extends Table {
  static const String tableName = MM_TABLES.SERVER.TEAM_THREADS_SYNC;

  @override
  List<Column> get columns => [
        Column(name: 'earliest', type: ColumnType.number),
        Column(name: 'latest', type: ColumnType.number),
      ];
}

final teamThreadsSyncSchema = TeamThreadsSyncSchema();
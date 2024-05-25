// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:nozbe_watermelondb/nozbe_watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

class ConfigSchema extends Table {
  static const String tableName = MM_TABLES.SERVER.CONFIG;

  @override
  List<Column> get columns => [
        Column(name: 'value', type: ColumnType.string),
      ];
}

final configSchema = ConfigSchema();
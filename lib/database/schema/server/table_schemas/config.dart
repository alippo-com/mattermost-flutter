// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

const String CONFIG = MM_TABLES.SERVER['CONFIG'];

final TableSchema tableSchemaSpec = TableSchema(
  name: CONFIG,
  columns: [
    Column(name: 'value', type: ColumnType.string),
  ],
);

final TableSchema tableSchema = tableSchemaSpec;

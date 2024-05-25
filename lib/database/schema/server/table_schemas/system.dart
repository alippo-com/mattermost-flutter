// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types.dart'; // Changed from '@constants/database'

final systemTableSchema = TableSchema(
  name: MMTables.server.SYSTEM,
  columns: [
    ColumnSchema(name: 'value', type: ColumnType.text),
  ],
);

// Copyright (c) 2020-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/lib/types/table_schema.dart';
import 'package:mattermost_flutter/lib/constants/database.dart';

final teamSearchHistory = TableSchema(
    name: MMTables.server.teamSearchHistory,
    columns: [
        TableColumn(name: 'created_at', type: ColumnType.integer),
        TableColumn(name: 'display_term', type: ColumnType.text),
        TableColumn(name: 'team_id', type: ColumnType.text, isIndexed: true),
        TableColumn(name: 'term', type: ColumnType.text),
    ],
);
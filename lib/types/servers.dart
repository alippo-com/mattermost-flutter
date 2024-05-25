
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart';

final serversTableSchema = TableSchema(
    name: SERVERS,
    columns: [
        TableColumn(name: 'db_path', type: 'string'),
        TableColumn(name: 'display_name', type: 'string'),
        TableColumn(name: 'url', type: 'string', isIndexed: true),
        TableColumn(name: 'last_active_at', type: 'number', isIndexed: true),
        TableColumn(name: 'identifier', type: 'string', isIndexed: true),
    ],
);

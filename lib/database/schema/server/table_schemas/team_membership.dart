// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/table_schema.dart';

import 'package:mattermost_flutter/constants/database.dart';

final teamMembership = TableSchema(
  name: MMTables.server.teamMembership,
  columns: [
    TableColumn(name: 'team_id', type: 'String', isIndexed: true),
    TableColumn(name: 'user_id', type: 'String', isIndexed: true),
    TableColumn(name: 'scheme_admin', type: 'bool'),
  ],
);

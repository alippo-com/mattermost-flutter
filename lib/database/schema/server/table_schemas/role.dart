
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/table_schema.dart';
import 'package:mattermost_flutter/constants/database.dart';

final String role = MM_TABLES['SERVER']['ROLE'];

class RoleSchema extends TableSchema {
  @override
  final String name = role;
  @override
  final List<Column> columns = [
    Column(name: 'name', type: 'string', isIndexed: true),
    Column(name: 'permissions', type: 'string'),
  ];
}

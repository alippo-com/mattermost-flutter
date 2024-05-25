// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/constants.dart';

const CATEGORY_CHANNEL = MM_TABLES.SERVER.CATEGORY_CHANNEL;

class CategoryChannelTableSchema extends TableSchema {
  @override
  String get name => CATEGORY_CHANNEL;

  @override
  List<ColumnSchema> get columns => [
        ColumnSchema(name: 'category_id', type: ColumnType.string, isIndexed: true),
        ColumnSchema(name: 'channel_id', type: ColumnType.string, isIndexed: true),
        ColumnSchema(name: 'sort_order', type: ColumnType.number),
      ];
}
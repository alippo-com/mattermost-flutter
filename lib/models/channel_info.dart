// Copyright 2022-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelon_db/watermelon_db.dart';
import 'package:mattermost_flutter/models/types.dart';

const String tableName = 'channel_info';

class ChannelInfo extends Table {
  @override
  String get name => tableName;

  @override
  List<Column> get columns => [
        Column(name: 'guest_count', type: ColumnType.integer),
        Column(name: 'header', type: ColumnType.text),
        Column(name: 'member_count', type: ColumnType.integer),
        Column(name: 'pinned_post_count', type: ColumnType.integer),
        Column(name: 'files_count', type: ColumnType.integer),
        Column(name: 'purpose', type: ColumnType.text),
      ];
}
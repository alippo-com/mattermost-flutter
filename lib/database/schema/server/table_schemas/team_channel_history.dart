// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_mattermost/types/constants.dart';
import 'package:watermelondb/watermelondb.dart';

final String teamChannelHistoryTable = MM_TABLES['SERVER']['TEAM_CHANNEL_HISTORY'];

class TeamChannelHistory extends Table {
  @override
  String get tableName => teamChannelHistoryTable;

  @override
  List<Column> get columns => [
    Column(name: 'channel_ids', type: ColumnType.text),
  ];
}
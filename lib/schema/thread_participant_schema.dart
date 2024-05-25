// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:nozbe_watermelondb/nozbe_watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

class ThreadParticipantSchema extends Table {
  static const String tableName = MM_TABLES.SERVER.THREAD_PARTICIPANT;

  @override
  List<Column> get columns => [
        Column(name: 'thread_id', type: ColumnType.string, isIndexed: true),
        Column(name: 'user_id', type: ColumnType.string, isIndexed: true),
      ];
}

final threadParticipantSchema = ThreadParticipantSchema();
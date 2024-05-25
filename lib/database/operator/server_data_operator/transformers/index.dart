// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:nozbe_watermelondb/watermelondb.dart';

Future<Model> prepareBaseRecord({
  required OperationType action,
  required Database database,
  required String tableName,
  required RecordPair value,
  required Function(Model) fieldsMapper,
}) async {
  if (action == OperationType.UPDATE) {
    final record = value.record as Model;
    return record.prepareUpdate(() => fieldsMapper(record));
  }

  return database.collections.get(tableName).prepareCreate(fieldsMapper);
}

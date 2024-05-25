
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers.dart';

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/models/app/global.dart';
import 'package:mattermost_flutter/types/database/models/app/info.dart';
import 'package:mattermost_flutter/types/database/database.dart';

const INFO = MM_TABLES.APP['INFO'];
const GLOBAL = MM_TABLES.APP['GLOBAL'];

Future<Model> transformInfoRecord({required TransformerArgs operator}) async {
  final raw = operator.value.raw as AppInfo;
  final InfoModel? record = operator.value.record as InfoModel?;
  final bool isCreateAction = operator.action == OperationType.CREATE;

  void fieldsMapper(InfoModel app) {
    app.raw.id = isCreateAction ? app.id : (record?.id ?? app.id);
    app.buildNumber = raw.buildNumber;
    app.createdAt = raw.createdAt;
    app.versionNumber = raw.versionNumber;
  }

  return prepareBaseRecord(
    action: operator.action,
    database: operator.database,
    fieldsMapper: fieldsMapper,
    tableName: INFO,
    value: operator.value,
  );
}

Future<Model> transformGlobalRecord({required TransformerArgs operator}) async {
  final raw = operator.value.raw as IdValue;

  void fieldsMapper(GlobalModel global) {
    global.raw.id = raw.id;
    global.value = raw.value;
  }

  return prepareBaseRecord(
    action: operator.action,
    database: operator.database,
    fieldsMapper: fieldsMapper,
    tableName: GLOBAL,
    value: operator.value,
  );
}

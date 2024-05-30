
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/app_data_operator/comparator.dart';
import 'package:mattermost_flutter/database/operator/app_data_operator/transformers.dart';
import 'package:mattermost_flutter/database/operator/base_data_operator.dart';
import 'package:mattermost_flutter/utils/log.dart';

const INFO = MM_TABLES.APP.INFO;
const GLOBAL = MM_TABLES.APP.GLOBAL;

class AppDataOperator extends BaseDataOperator {
  Future<List> handleInfo({List<dynamic>? info, bool prepareRecordsOnly = true}) async {
    if (info == null || info isEmpty) {
      logWarning('An empty or undefined "info" array has been passed to the handleInfo');
      return [];
    }

    return handleRecords(
      fieldName: 'version_number',
      buildKeyRecordBy: buildAppInfoKey,
      transformer: transformInfoRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: getUniqueRawsBy(raws: info, key: 'version_number'),
      tableName: INFO,
      context: 'handleInfo',
    );
  }

  Future<List> handleGlobal({List<dynamic>? globals, bool prepareRecordsOnly = true}) async {
    if (globals == null || globals isEmpty) {
      logWarning('An empty or undefined "globals" array has been passed to the handleGlobal');
      return [];
    }

    return handleRecords(
      fieldName: 'id',
      transformer: transformGlobalRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: getUniqueRawsBy(raws: globals, key: 'id'),
      tableName: GLOBAL,
      context: 'handleGlobal',
    );
  }
}

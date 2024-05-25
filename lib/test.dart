// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';

import 'index.dart';

class TestSchema {
  static const INFO = MM_TABLES.APP.INFO;
  static const GLOBAL = MM_TABLES.APP.GLOBAL;
  static const SERVERS = MM_TABLES.APP.SERVERS;

  static void testSchema() {
    // Test schema matching
    assert(schema.version == 1);
    assert(schema.tables[INFO]?.name == INFO);
    assert(schema.tables[INFO]?.columns['build_number']?.type == 'string');
    assert(schema.tables[GLOBAL]?.name == GLOBAL);
    assert(schema.tables[GLOBAL]?.columns['value']?.type == 'string');
    assert(schema.tables[SERVERS]?.name == SERVERS);
    assert(schema.tables[SERVERS]?.columns['db_path']?.type == 'string');
  }
}

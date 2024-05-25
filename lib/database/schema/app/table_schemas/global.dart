
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/schema.dart';  // Assuming all schema-related interfaces/types are here
import 'package:mattermost_flutter/constants/database.dart';  // Assuming all constants are moved here

class GlobalTableSchema {
  static final tableName = GLOBAL;  // Assuming GLOBAL is a valid constant in database.dart

  static final columns = [
    {'name': 'value', 'type': 'String'},
  ];
}

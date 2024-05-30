// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';

import 'package:mattermost_flutter/constants/database.dart';

import 'package:mattermost_flutter/types/global.dart';

class GlobalModel extends Model with GlobalModelInterface {
  static final table = MM_TABLES.APP.GLOBAL;

  @Json('value', safeParseJSON)
  late final dynamic value;
}

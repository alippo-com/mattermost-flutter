// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';

import 'package:mattermost_flutter/constants/database.dart';

import 'package:mattermost_flutter/types/system_model_interface.dart';

/**
 * The System model is another set of key-value pair combination but this one
 * will mostly hold configuration information about the client, the licences and some
 * custom data (e.g. recent emoji used)
 */
class SystemModel extends Model implements SystemModelInterface {
  /** table (name) : System */
  static final table = MM_TABLES.SERVER.SYSTEM;

  /** value : The value for that config/information and whose key will be the id column */
  @Json('value', safeParseJSON)
  late final dynamic value;
}

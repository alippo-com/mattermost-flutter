// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/system.dart'; // Assuming the types are defined in this file

/// The System model is another set of key-value pair combination but this one
/// will mostly hold configuration information about the client, the licences and some
/// custom data (e.g. recent emoji used)
class SystemModel extends Model {
  /// table (name) : System
  static final String table = 'System';

  /// value : The value for that config/information and whose key will be the id column
  dynamic value;

  // Constructor
  SystemModel({this.value});
}
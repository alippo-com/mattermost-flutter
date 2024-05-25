
// Copyright (c) Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming all type declarations are stored here

/// The System model is another set of key-value pair combination but this one
/// will mostly hold configuration information about the client, the licences and some
/// custom data (e.g. recent emoji used)
class SystemModel extends Model {
  /// table (name) : System
  static final String table = 'System';

  /// value : The value for that config/information and whose key will be the id column
  dynamic value;

  // Constructor and other methods would be defined here as per the original TypeScript functionality
}


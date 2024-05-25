
// Copyright (c) 2023 Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

// Dart imports
import 'package:mattermost_flutter/types.dart'; // Assuming this file exists to handle type imports

/// The Config model is another set of key-value pair combination but this one
/// will hold the server configuration.
class ConfigModel {
  // Static table name for Config
  static const String table = 'Config';

  // The value for that config/information and whose key will be the id column
  String value;

  // Constructor for ConfigModel
  ConfigModel({required this.value});
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/model.dart'; // Assuming model.dart is where the Dart equivalent of Model is defined

/// The Config model is another set of key-value pair combination but this one
/// will hold the server configuration.
class ConfigModel extends Model {
  /// table (name) : Config
  static final String table = 'config';

  /// value : The value for that config/information and whose key will be the id column
  String value;

  ConfigModel({required this value});
}
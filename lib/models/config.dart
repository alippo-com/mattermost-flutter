// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types.dart';

/// The Config model is another set of key-value pair combination but this one
/// will hold the server configuration.
class ConfigModel {
  /// table (name) : Config
  static const String table = 'Config';

  /// value : The value for that config/information and whose key will be the id column
  String value;

  ConfigModel({required this.value});
}

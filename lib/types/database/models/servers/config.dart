
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart'; // Assuming an equivalent WatermelonDB package for Dart
import 'package:mattermost_flutter/constants/database.dart';
// Adjust this import based on the actual structure

abstract class ConfigModelInterface {
  String get value;
}

class ConfigModel extends DatabaseModel implements ConfigModelInterface {
  static const String tableName = MM_TABLES.SERVER.CONFIG;

  @Field('value')
  late final String value;

  ConfigModel({
    required this.value,
  });

  @override
  String get table => tableName;
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart'; // Assuming an equivalent WatermelonDB package for Dart
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/app/info.dart'; // Adjust this import based on the actual structure

class InfoModel extends DatabaseModel implements InfoModelInterface {
  static const String tableName = MM_TABLES.APP.INFO;

  @Field('build_number')
  late final String buildNumber;

  @Field('created_at')
  late final int createdAt;

  @Field('version_number')
  late final String versionNumber;

  InfoModel({
    required this.buildNumber,
    required this.createdAt,
    required this.versionNumber,
  });

  @override
  String get table => tableName;
}

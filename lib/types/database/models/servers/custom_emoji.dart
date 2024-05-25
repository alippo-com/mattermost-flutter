// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart'; // Assuming an equivalent WatermelonDB package for Dart
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart'; // Adjust this import based on the actual structure

class CustomEmojiModel extends DatabaseModel implements CustomEmojiModelInterface {
  static const String tableName = MM_TABLES.SERVER.CUSTOM_EMOJI;

  @Field('name')
  late final String name;

  CustomEmojiModel({
    required this.name,
  });

  @override
  String get table => tableName;
}
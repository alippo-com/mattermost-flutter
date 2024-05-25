// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

final String CHANNEL = MM_TABLES.SERVER;

class ChannelSchema {
  static final tableSchema = {
    'name': CHANNEL,
    'columns': [
      {'name': 'create_at', 'type': 'int'},
      {'name': 'creator_id', 'type': 'String', 'isIndexed': true},
      {'name': 'delete_at', 'type': 'int'},
      {'name': 'display_name', 'type': 'String'},
      {'name': 'is_group_constrained', 'type': 'bool'},
      {'name': 'name', 'type': 'String', 'isIndexed': true},
      {'name': 'shared', 'type': 'bool'},
      {'name': 'team_id', 'type': 'String', 'isIndexed': true},
      {'name': 'type', 'type': 'String'},
      {'name': 'update_at', 'type': 'int'},
    ],
  };
}
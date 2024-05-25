// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types.dart';

final String tableName = 'team';

final Map<String, dynamic> tableSchema = {
  'name': tableName,
  'columns': [
    {'name': 'allowed_domains', 'type': 'String'},
    {'name': 'description', 'type': 'String'},
    {'name': 'display_name', 'type': 'String'},
    {'name': 'is_allow_open_invite', 'type': 'bool'},
    {'name': 'is_group_constrained', 'type': 'bool'},
    {'name': 'last_team_icon_updated_at', 'type': 'int'},
    {'name': 'name', 'type': 'String'},
    {'name': 'type', 'type': 'String'},
    {'name': 'update_at', 'type': 'int'},
    {'name': 'invite_id', 'type': 'String'},
  ],
};

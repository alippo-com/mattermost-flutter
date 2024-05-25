// Copyright (c) 2023 Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/database.dart';

const String postTableName = 'post';

class PostSchema {
  static final columns = [
    {'name': 'channel_id', 'type': 'String', 'isIndexed': true},
    {'name': 'create_at', 'type': 'int'},
    {'name': 'delete_at', 'type': 'int'},
    {'name': 'edit_at', 'type': 'int'},
    {'name': 'is_pinned', 'type': 'bool'},
    {'name': 'message', 'type': 'String'},
    {'name': 'message_source', 'type': 'String'},
    {'name': 'metadata', 'type': 'String', 'isOptional': true},
    {'name': 'original_id', 'type': 'String'},
    {'name': 'pending_post_id', 'type': 'String', 'isIndexed': true},
    {'name': 'previous_post_id', 'type': 'String'},
    {'name': 'props', 'type': 'String'},
    {'name': 'root_id', 'type': 'String'},
    {'name': 'type', 'type': 'String'},
    {'name': 'update_at', 'type': 'int'},
    {'name': 'user_id', 'type': 'String', 'isIndexed': true},
  ];
}
// Copyright (c) 1995-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/nozbe/watermelondb.dart';
import 'package:mattermost_flutter/types/constants/database.dart';

final draft = tableSchema({
  'name': DRAFT,
  'columns': [
    {'name': 'channel_id', 'type': 'String', 'isIndexed': true},
    {'name': 'files', 'type': 'String'},
    {'name': 'message', 'type': 'String'},
    {'name': 'root_id', 'type': 'String', 'isIndexed': true},
    {'name': 'metadata', 'type': 'String', 'isOptional': true},
  ],
});
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types.dart';

const String tableName = 'REACTION';

final Map<String, dynamic> tableSchema = {
    'name': tableName,
    'columns': [
        {'name': 'create_at', 'type': 'int'},
        {'name': 'emoji_name', 'type': 'String'},
        {'name': 'post_id', 'type': 'String', 'isIndexed': true},
        {'name': 'user_id', 'type': 'String', 'isIndexed': true},
    ],
};

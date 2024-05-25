// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/constants.dart'; // Adjusted import for Dart/Flutter

class FileSchema {
  static final tableName = SERVER_TABLES.FILE;

  static final columns = [
    {'name': 'extension', 'type': 'String'},
    {'name': 'height', 'type': 'int'},
    {'name': 'image_thumbnail', 'type': 'String'},
    {'name': 'local_path', 'type': 'String', 'isOptional': true},
    {'name': 'mime_type', 'type': 'String'},
    {'name': 'name', 'type': 'String'},
    {'name': 'post_id', 'type': 'String', 'isIndexed': true},
    {'name': 'size', 'type': 'int'},
    {'name': 'width', 'type': 'int'},
  ];
}
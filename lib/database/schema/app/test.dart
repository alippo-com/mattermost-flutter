// Copyright (c) 2020-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types.dart';

final Map<String, dynamic> MM_TABLES = {
  'APP': {
    'INFO': 'info',
    'GLOBAL': 'global',
    'SERVERS': 'servers',
  }
};

class AppSchema {
  static const schema = {
    'version': 1,
    'tables': {
      MM_TABLES['APP']['INFO']: {
        'name': MM_TABLES['APP']['INFO'],
        'columns': {
          'build_number': {'name': 'build_number', 'type': 'String'},
          'created_at': {'name': 'created_at', 'type': 'int'},
          'version_number': {'name': 'version_number', 'type': 'String'},
        },
        'columnArray': [
          {'name': 'build_number', 'type': 'String'},
          {'name': 'created_at', 'type': 'int'},
          {'name': 'version_number', 'type': 'String'},
        ],
      },
      MM_TABLES['APP']['GLOBAL']: {
        'name': MM_TABLES['APP']['GLOBAL'],
        'columns': {
          'value': {'name': 'value', 'type': 'String'},
        },
        'columnArray': [
          {'name': 'value', 'type': 'String'},
        ],
      },
      MM_TABLES['APP']['SERVERS']: {
        'name': MM_TABLES['APP']['SERVERS'],
        'columns': {
          'db_path': {'name': 'db_path', 'type': 'String'},
          'display_name': {'name': 'display_name', 'type': 'String'},
          'identifier': {'name': 'identifier', 'type': 'String', 'isIndexed': true},
          'last_active_at': {'name': 'last_active_at', 'type': 'int', 'isIndexed': true},
          'url': {'name': 'url', 'type': 'String', 'isIndexed': true},
        },
        'columnArray': [
          {'name': 'db_path', 'type': 'String'},
          {'name': 'display_name', 'type': 'String'},
          {'name': 'identifier', 'type': 'String', 'isIndexed': true},
          {'name': 'last_active_at', 'type': 'int', 'isIndexed': true},
          {'name': 'url', 'type': 'String', 'isIndexed': true},
        ],
      },
    },
  };
}

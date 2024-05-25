// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/watermelondb.dart';
import 'package:mattermost_flutter/constants/database.dart';

class ChannelInfoSchema {
  static const String tableName = MM_TABLES.SERVER.CHANNEL_INFO;

  static final List<Map<String, dynamic>> columns = [
    {'name': 'guest_count', 'type': 'int'},
    {'name': 'header', 'type': 'String'},
    {'name': 'member_count', 'type': 'int'},
    {'name': 'pinned_post_count', 'type': 'int'},
    {'name': 'files_count', 'type': 'int'},
    {'name': 'purpose', 'type': 'String'},
  ];
}
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types.dart';

class Column {
  final String name;
  final String type;

  Column({required this.name, required this.type});
}

class ChannelInfoSchema {
  static final tableName = 'channel_info';
  static final List<Column> columns = [
    Column(name: 'guest_count', type: 'int'),
    Column(name: 'header', type: 'String'),
    Column(name: 'member_count', type: 'int'),
    Column(name: 'pinned_post_count', type: 'int'),
    Column(name: 'files_count', type: 'int'),
    Column(name: 'purpose', type: 'String'),
  ];

  // Additional methods for querying and updates can be added here to align with Flutter's reactive and widget lifecycle patterns.
}
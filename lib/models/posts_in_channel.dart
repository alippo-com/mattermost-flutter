// Copyright (c) 2023 Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:moor/moor.dart';
import '../types/mm_tables.dart';

@DataClassName('PostsInChannel')
class PostsInChannel extends Table {
  TextColumn get channelId => text().indexed()();
  IntColumn get earliest => integer()();
  IntColumn get latest => integer()();

  @override
  Set<Column> get primaryKey => {channelId};
}
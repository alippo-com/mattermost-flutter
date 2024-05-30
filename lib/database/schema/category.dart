// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:mattermost_flutter/types/constants.dart';

final String tableCategory = MM_TABLES['SERVER']['CATEGORY'];

class Category {
  bool collapsed;
  String displayName;
  bool muted;
  int sortOrder;
  String sorting;
  String teamId;
  String type;

  Category({
    required this.collapsed,
    required this.displayName,
    required this.muted,
    required this.sortOrder,
    required this.sorting,
    required this.teamId,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'collapsed': collapsed ? 1 : 0,
      'display_name': displayName,
      'muted': muted ? 1 : 0,
      'sort_order': sortOrder,
      'sorting': sorting,
      'team_id': teamId,
      'type': type,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      collapsed: map['collapsed'] == 1,
      displayName: map['display_name'],
      muted: map['muted'] == 1,
      sortOrder: map['sort_order'],
      sorting: map['sorting'],
      teamId: map['team_id'],
      type: map['type'],
    );
  }
}

void createTableCategory(sqflite.DatabaseExecutor db) {
  db.execute("""
    CREATE TABLE $tableCategory (
      collapsed BOOLEAN NOT NULL,
      display_name TEXT NOT NULL,
      muted BOOLEAN NOT NULL,
      sort_order INTEGER NOT NULL,
      sorting TEXT NOT NULL,
      team_id TEXT NOT NULL,
      type TEXT NOT NULL,
      PRIMARY KEY (team_id)
    )
  """);
}
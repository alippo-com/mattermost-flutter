// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:mattermost_flutter/server/table_schemas.dart';

class ServerSchema {
  static const int version = 3;
  static const String databaseName = 'mattermost.db';

  static final List<String> tables = [
    CategorySchema.tableName,
    CategoryChannelSchema.tableName,
    ChannelInfoSchema.tableName,
    ChannelMembershipSchema.tableName,
    ChannelSchema.tableName,
    ConfigSchema.tableName,
    CustomEmojiSchema.tableName,
    DraftSchema.tableName,
    FileSchema.tableName,
    GroupSchema.tableName,
    GroupChannelSchema.tableName,
    GroupMembershipSchema.tableName,
    GroupTeamSchema.tableName,
    MyChannelSchema.tableName,
    MyChannelSettingsSchema.tableName,
    MyTeamSchema.tableName,
    PostInThreadSchema.tableName,
    PostSchema.tableName,
    PostsInChannelSchema.tableName,
    PreferenceSchema.tableName,
    ReactionSchema.tableName,
    RoleSchema.tableName,
    SystemSchema.tableName,
    TeamChannelHistorySchema.tableName,
    TeamMembershipSchema.tableName,
    TeamSchema.tableName,
    TeamSearchHistorySchema.tableName,
    TeamThreadsSyncSchema.tableName,
    ThreadSchema.tableName,
    ThreadInTeamSchema.tableName,
    ThreadParticipantSchema.tableName,
    UserSchema.tableName,
  ];

  static Future<Database> open() async {
    return openDatabase(
      databaseName,
      version: version,
      onCreate: (db, version) async {
        for (var table in tables) {
          await db.execute(table);
        }
      },
    );
  }
}

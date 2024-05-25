// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/channel_model.dart';
import 'package:mattermost_flutter/types/group_interface.dart';
import 'package:mattermost_flutter/types/team_model.dart';
import 'package:mattermost_flutter/types/user_model.dart';

/**
 * A Group is a collection of users that can be associated with a team or a channel
 */
class GroupModel extends Model implements GroupInterface {
  /** table (name) : Group */
  static const tableName = MM_TABLES_SERVER.GROUP;

  /** associations : Describes every relationship to this table. */
  static final associations = {
    /** Groups are associated with Channels (relationship N:N) through GROUP_CHANNEL */
    MM_TABLES_SERVER.GROUP_CHANNEL: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.hasMany,
      foreignKey: 'group_id',
    ),

    /** Groups are associated with Members (Users) (relationship N:N) through GROUP_MEMBERSHIP */
    MM_TABLES_SERVER.GROUP_MEMBERSHIP: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.hasMany,
      foreignKey: 'group_id',
    ),

    /** Groups are associated with Teams (relationship N:N) through GROUP_TEAM */
    MM_TABLES_SERVER.GROUP_TEAM: WatermelonDBAssociation(
      type: WatermelonDBAssociationType.hasMany,
      foreignKey: 'group_id',
    ),
  };

  /** name : The name for the group */
  @Field('name')
  late final String name;

  /** display_name : The display name for the group */
  @Field('display_name')
  late final String displayName;

  /** description : The display name for the group */
  @Field('description')
  late final String description;

  /** remote_id : The source for the group (i.e. custom) */
  @Field('source')
  late final String source;

  /** remote_id : The remote id for the group (i.e. in a shared channel) */
  @Field('remote_id')
  late final String remoteId;

  /** member_count : The number of members in the group */
  @Field('member_count')
  late final int memberCount;

  /** created_at : The creation date for this row */
  @Field('created_at')
  late final int createdAt;

  /** updated_at : The update date for this row */
  @Field('updated_at')
  late final int updatedAt;

  /** deleted_at : The delete date for this row */
  @Field('deleted_at')
  late final int deletedAt;

  /** channels : Retrieves all the channels that are associated to this group */
  @Lazy
  Future<List<ChannelModel>> get channels async {
    return (await collections.get<ChannelModel>(MM_TABLES_SERVER.CHANNEL)).query(
      Query.on(MM_TABLES_SERVER.GROUP_CHANNEL, 'group_id', id),
    );
  }

  /** teams : Retrieves all the teams that are associated to this group */
  @Lazy
  Future<List<TeamModel>> get teams async {
    return (await collections.get<TeamModel>(MM_TABLES_SERVER.TEAM)).query(
      Query.on(MM_TABLES_SERVER.GROUP_TEAM, 'group_id', id),
    );
  }

  /** members : Retrieves all the members that are associated to this group */
  @Lazy
  Future<List<UserModel>> get members async {
    return (await collections.get<UserModel>(MM_TABLES_SERVER.USER)).query(
      Query.on(MM_TABLES_SERVER.GROUP_MEMBERSHIP, 'group_id', id),
    );
  }
}

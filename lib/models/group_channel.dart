// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/group.dart';

/**
 * The GroupChannel model represents the 'association table' where many groups have channels and many channels are in
 * groups (relationship type N:N)
 */
class GroupChannelModel extends Model {
  /** table (name) : GroupChannel */
  static const String table = 'group_channels';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Associations> associations = {
    'groups': Associations.belongsTo('groups', 'group_id'),
    'channels': Associations.belongsTo('channels', 'channel_id'),
  };

  /** group_id : The foreign key to the related Group record */
  final String groupId;

  /** channel_id : The foreign key to the related Channel record */
  final String channelId;

  /** created_at : The timestamp for when it was created */
  final int createdAt;

  /** updated_at : The timestamp for when it was updated */
  final int updatedAt;

  /** deleted_at : The timestamp for when it was deleted */
  final int deletedAt;

  /** group : The related group */
  Relation<GroupModel> get group => relation('group_id');

  /** channel : The related channel */
  Relation<ChannelModel> get channel => relation('channel_id');

  GroupChannelModel({
    required this.groupId,
    required this.channelId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });
}

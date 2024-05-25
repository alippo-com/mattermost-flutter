// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/user.dart';

/**
 * The ChannelMembership model represents the 'association table' where many channels have users and many users are on
 * channels (relationship type N:N)
 */
class ChannelMembershipModel extends Model {
  /** table (name) : ChannelMembership */
  static const String table = 'channel_memberships';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Associations> associations = {
    'channels': Associations.belongsTo('channels', 'channel_id'),
    'users': Associations.belongsTo('users', 'user_id'),
  };

  /** channel_id : The foreign key to the related Channel record */
  final String channelId;

  /** user_id : The foreign key to the related User record */
  final String userId;

  /** scheme_admin : Determines if the user is an admin of the channel */
  final bool schemeAdmin;

  /** memberChannel : The related channel this member belongs to */
  Relation<ChannelModel> get memberChannel => relation('channel_id');

  /** memberUser : The related member belonging to the channel */
  Relation<UserModel> get memberUser => relation('user_id');

  /** getAllChannelsForUser - Retrieves all the channels that the user is part of */
  Query<ChannelModel> get getAllChannelsForUser => (database.collections.get<ChannelModel>('channels') as Query<ChannelModel>).query();

  /** getAllUsersInChannel - Retrieves all the users who are part of this channel */
  Query<UserModel> get getAllUsersInChannel => (database.collections.get<UserModel>('users') as Query<UserModel>).query();

  ChannelMembershipModel({
    required this.channelId,
    required this.userId,
    required this.schemeAdmin,
  });
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel_membership_interface.dart';

/**
 * The ChannelMembership model represents the 'association table' where many channels have users and many users are on
 * channels (relationship type N:N)
 */
class ChannelMembershipModel extends Model implements ChannelMembershipModelInterface {
  static String table = 'channel_membership';

  static final Map<String, Association> associations = {
    'channels': Association.belongsTo('channels', 'channel_id'),
    'users': Association.belongsTo('users', 'user_id'),
  };

  @Field('channel_id')
  String channelId;

  @Field('user_id')
  String userId;

  @Field('scheme_admin')
  bool schemeAdmin;

  @immutableRelation('channels', 'channel_id')
  final memberChannel = HasOne<ChannelModel>();

  @immutableRelation('users', 'user_id')
  final memberUser = HasOne<UserModel>();

  @lazy
  Query<ChannelModel> get getAllChannelsForUser => collections?.get<ChannelModel>('channels').query(Q.on('users', 'id', userId));

  @lazy
  Query<UserModel> get getAllUsersInChannel => collections?.get<UserModel>('users').query(Q.on('channels', 'id', channelId));
}

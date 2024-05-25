// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/channel.dart';
import 'package:mattermost_flutter/types/team.dart';
import 'package:mattermost_flutter/types/user.dart';

/**
 * A Group is a collection of users, associated to teams and/or channels
 */
class GroupModel extends Model {
  static String table = "Group";

  static final Map<String, Association> associations = {
    'channels': Association.hasMany('channels'),
    'teams': Association.hasMany('teams'),
    'members': Association.hasMany('members'),
  };

  String name;
  String displayName;
  String description;
  String source;
  String remoteId;
  int createdAt;
  int updatedAt;
  int deletedAt;
  int memberCount;

  @lazy
  Query<ChannelModel> get channels => (hasMany<ChannelModel>());
  @lazy
  Query<TeamModel> get teams => (hasMany<TeamModel>());
  @lazy
  Query<UserModel> get members => (hasMany<UserModel>());
}

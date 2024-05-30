// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/types/database/models/servers/group.dart';
import 'package:mattermost_flutter/types/database/models/servers/group_membership_interface.dart';

/**
 * The GroupMembership model represents the 'association table' where many groups have users and many users are in
 * groups (relationship type N:N)
 */
class GroupMembershipModel extends Model implements GroupMembershipInterface {
  static String table = 'group_membership';

  static final Map<String, Association> associations = {
    'groups': Association.belongsTo('groups', 'group_id'),
    'users': Association.belongsTo('users', 'user_id'),
  };

  @Field('group_id')
  String groupId;

  @Field('user_id')
  String userId;

  @Field('created_at')
  int createdAt;

  @Field('updated_at')
  int updatedAt;

  @Field('deleted_at')
  int deletedAt;

  @immutableRelation('groups', 'group_id')
  final group = HasOne<GroupModel>();

  @immutableRelation('users', 'user_id')
  final member = HasOne<UserModel>();
}


// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/group.dart';
import 'package:mattermost_flutter/types/user.dart';

/**
 * The GroupMembership model represents the 'association table' where many groups have users and many users are in
 * groups (relationship type N:N)
 */
class GroupMembershipModel extends Model {
  /** table (name) : GroupMembership */
  static const String table = 'group_memberships';

  /** associations : Describes every relationship to this table. */
  static final Map<String, Associations> associations = {
    'groups': Associations.belongsTo('groups', 'group_id'),
    'users': Associations.belongsTo('users', 'user_id'),
  };

  /** group_id : The foreign key to the related Group record */
  final String groupId;

  /** user_id : The foreign key to the related User record */
  final String userId;

  /** created_at : The timestamp for when it was created */
  final int createdAt;

  /** updated_at : The timestamp for when it was updated */
  final int updatedAt;

  /** deleted_at : The timestamp for when it was deleted */
  final int deletedAt;

  /** group : The related group */
  Relation<GroupModel> get group => relation('group_id');

  /** user : The related user */
  Relation<UserModel> get member => relation('user_id');

  GroupMembershipModel({
    required this.groupId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });
}

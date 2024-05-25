// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/thread.dart';
import 'package:mattermost_flutter/types/user.dart';

class ThreadParticipantsModel extends Model {
  static const String table = 'thread_participants';

  static final Map<String, Associations> associations = {
    'threads': Associations.belongsTo('threads', 'thread_id'),
    'users': Associations.belongsTo('users', 'user_id'),
  };

  final String threadId;
  final String userId;

  Relation<ThreadModel> get thread => relation('thread_id');
  Relation<UserModel> get user => relation('user_id');

  ThreadParticipantsModel({
    required this.threadId,
    required this.userId,
  });
}

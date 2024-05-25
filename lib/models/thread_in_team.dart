// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/relations.dart';
import 'package:mattermost_flutter/types/thread.dart';
import 'package:mattermost_flutter/types/team.dart';

class ThreadInTeamModel extends Model {
  static const String table = 'ThreadsInTeam';

  static final Map<String, Associations> associations = {
    'threads': Associations.belongsTo('threads', 'thread_id'),
    'teams': Associations.belongsTo('teams', 'team_id'),
  };

  final String threadId;
  final String teamId;

  Relation<ThreadModel> get thread => relation('thread_id');
  Relation<TeamModel> get team => relation('team_id');

  ThreadInTeamModel({
    required this.threadId,
    required this.teamId,
  });
}

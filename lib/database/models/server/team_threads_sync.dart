// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';

const TEAM = MM_TABLES.SERVER['TEAM'];
const TEAM_THREADS_SYNC = MM_TABLES.SERVER['TEAM_THREADS_SYNC'];

/**
 * ThreadInTeam model helps us to sync threads without creating any gaps between the threads
 * by keeping track of the latest and earliest last_replied_at timestamps loaded for a team.
 */
class TeamThreadsSyncModel extends Model with TeamThreadsSyncModelInterface {
  /** table (name) : TeamThreadsSync */
  static final String tableName = TEAM_THREADS_SYNC;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    TEAM: Association(type: AssociationType.belongsTo, key: 'id'),
  };

  /** earliest: Oldest last_replied_at loaded through infinite loading */
  @Field('earliest')
  late int earliest;

  /** latest: Newest last_replied_at loaded during app init / navigating to global threads / pull to refresh */
  @Field('latest')
  late int latest;

  @ImmutableRelation(TEAM, 'id')
  late Relation<TeamModel> team;
}

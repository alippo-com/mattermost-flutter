// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/decorators.dart';
import 'package:mattermost_flutter/constants/database.dart';

const TEAM = MM_TABLES.SERVER['TEAM'];
const TEAM_SEARCH_HISTORY = MM_TABLES.SERVER['TEAM_SEARCH_HISTORY'];

/**
 * The TeamSearchHistory model holds the term searched within a team. The searches are performed
 * at team level in the app.
 */
class TeamSearchHistoryModel extends Model with TeamSearchHistoryModelInterface {
  /** table (name) : TeamSearchHistory */
  static final String tableName = TEAM_SEARCH_HISTORY;

  /** associations : Describes every relationship to this table. */
  static final Map<String, Association> associations = {
    /** A TEAM can have multiple search terms */
    TEAM: Association(type: AssociationType.belongsTo, key: 'team_id'),
  };

  /** created_at : The timestamp at which this search was performed */
  @Field('created_at')
  late int createdAt;

  /** team_id : The foreign key to the parent Team model */
  @Field('team_id')
  late String teamId;

  /** display_term : The term that we display to the user */
  @Field('display_term')
  late String displayTerm;

  /** term : The term that is sent to the server to perform the search */
  @Field('term')
  late String term;

  /** team : The related record to the parent team model */
  @ImmutableRelation(TEAM, 'team_id')
  late Relation<TeamModel> team;
}

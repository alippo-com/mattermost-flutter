// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/Relation.dart';

class TeamSearchHistoryModel extends Model {
  static final table = 'TeamSearchHistory';

  static final associations = {
    'team': 'belongs_to',
  };

  int createdAt;
  String teamId;
  String displayTerm;
  String term;
  Relation<TeamModel> team;

  TeamSearchHistoryModel({
    required this.createdAt,
    required this.teamId,
    required this.displayTerm,
    required this.term,
    required this.team,
  });

  // Implement additional methods if needed
}

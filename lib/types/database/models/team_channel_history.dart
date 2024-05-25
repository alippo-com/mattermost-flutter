// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/types/database/models/team.dart';

/**
 * The TeamChannelHistoryModel class helps keeping track of the last channel visited
 * by the user.
 */
class TeamChannelHistoryModel extends Model {
  static const String table = 'TeamChannelHistory';

  // An array containing the last 5 channels visited within this team order by recency
  List<String> channelIds;

  // The related record from the parent Team model
  Relation<TeamModel> team;

  TeamChannelHistoryModel({
    required this.channelIds,
    required this.team,
  });
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/team.dart'; // Adjusted import for Flutter
import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/associations.dart';

/**
 * The TeamChannelHistory model helps keeping track of the last channel visited
 * by the user.
 */
class TeamChannelHistoryModel extends Model {
  /** table (name) : TeamChannelHistory */
  static const String tableName = 'TeamChannelHistory';

  /** channel_ids : An array containing the last 5 channels visited within this team order by recency */
  List<String> channelIds;

  /** team : The related record from the parent Team model */
  final team = HasOne<TeamModel>();

  TeamChannelHistoryModel({
    required this.channelIds,
  });
}

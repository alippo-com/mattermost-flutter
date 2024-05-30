// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';
import 'package:mattermost_flutter/utils/log.dart';

const int MAXIMUM_RECENT_EMOJI = 27;

Future<List<String>> addRecentReaction(String serverUrl, List<String> emojiNames, {bool prepareRecordsOnly = false}) async {
  if (emojiNames.isEmpty) {
    return [];
  }

  try {
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseOperator.database;
    final operator = databaseOperator.operator;

    List<String> recent = await getRecentReactions(database);
    Set<String> recentEmojis = Set<String>.from(recent);
    List<String> aliases = emojiNames.map((e) => getEmojiFirstAlias(e)).toList();

    for (String alias in aliases) {
      recentEmojis.remove(alias);
    }

    recent = recentEmojis.toList();

    for (String alias in aliases) {
      recent.insert(0, alias);
    }

    return operator.handleSystem({
      'systems': [{
        'id': SYSTEM_IDENTIFIERS.RECENT_REACTIONS,
        'value': recent.sublist(0, MAXIMUM_RECENT_EMOJI).toString(),
      }],
      'prepareRecordsOnly': prepareRecordsOnly,
    });
  } catch (error) {
    logError('Failed addRecentReaction', error);
    return [];
  }
}

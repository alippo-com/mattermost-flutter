// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'dart:convert';
import 'package:mattermost_flutter/database/manager.dart';

Future<void> handleAddCustomEmoji(String serverUrl, WebSocketMessage msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final emoji = jsonDecode(msg.data['emoji']) as CustomEmoji;
    await operator.handleCustomEmojis(
      prepareRecordsOnly: false,
      emojis: [emoji],
    );
  } catch (e) {
    // Do nothing
  }
}

Future<void> handleReactionAddedToPostEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final reaction = jsonDecode(msg.data['reaction']) as Reaction;
    await operator.handleReactions(
      prepareRecordsOnly: false,
      skipSync: true,
      postsReactions: [
        PostReaction(
          post_id: reaction.post_id,
          reactions: [reaction],
        ),
      ],
    );
  } catch (e) {
    // Do nothing
  }
}

Future<void> handleReactionRemovedFromPostEvent(String serverUrl, WebSocketMessage msg) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final msgReaction = jsonDecode(msg.data['reaction']) as Reaction;
    final reaction = await queryReaction(database, msgReaction.emoji_name, msgReaction.post_id, msgReaction.user_id).fetch();

    if (reaction.isNotEmpty) {
      await database.write(() async {
        await reaction.first.destroyPermanently();
      });
    }
  } catch (e) {
    // Do nothing
  }
}

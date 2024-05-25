// Dart Code: ./mattermost_flutter/lib/queries/servers/reaction.dart

import 'package:nozbe_watermelondb/database.dart';
import 'package:nozbe_watermelondb/query.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/reaction.dart';

class ReactionQueries {
  static const String REACTION = MM_TABLES['SERVER']['REACTION'];

  static Future<List<ReactionModel>> queryReaction(Database database, String emojiName, String postId, String userId) {
    return database.get<ReactionModel>(REACTION).query(
      Query.where('emoji_name', emojiName),
      Query.where('post_id', postId),
      Query.where('user_id', userId),
    ).fetch();
  }

  static Future<List<ReactionModel>> queryReactionsForPost(Database database, String postId) {
    return database.get<ReactionModel>(REACTION).query(
      Query.where('post_id', postId),
    ).fetch();
  }

  static Stream<List<ReactionModel>> observeReactionsForPost(Database database, String postId) {
    return queryReactionsForPost(database, postId).asStream();
  }
}

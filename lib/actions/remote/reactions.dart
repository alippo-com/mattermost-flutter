// Converted Dart code from TypeScript

import 'package:mattermost_flutter/actions/local/reactions.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/utils/emoji/helpers.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';


Future<bool> getIsReactionAlreadyAddedToPost(String serverUrl, String postId, String emojiName) async {
  try {
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final currentUserId = await getCurrentUserId(databaseOperator.database);
    final emojiAlias = getEmojiFirstAlias(emojiName);
    return await queryReaction(databaseOperator.database, emojiAlias, postId, currentUserId).fetchCount() > 0;
  } catch (error) {
    logDebug('error on getIsReactionAlreadyAddedToPost', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<dynamic> toggleReaction(String serverUrl, String postId, String emojiName) async {
  try {
    final isReactionAlreadyAddedToPost = await getIsReactionAlreadyAddedToPost(serverUrl, postId, emojiName);
    if (isReactionAlreadyAddedToPost) {
      return removeReaction(serverUrl, postId, emojiName);
    }
    return addReaction(serverUrl, postId, emojiName);
  } catch (error) {
    logDebug('error on toggleReaction', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<dynamic> addReaction(String serverUrl, String postId, String emojiName) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final currentUserId = await getCurrentUserId(databaseOperator.database);
    final emojiAlias = getEmojiFirstAlias(emojiName);
    final reacted = await queryReaction(databaseOperator.database, emojiAlias, postId, currentUserId).fetchCount() > 0;
    if (!reacted) {
      final reaction = await client.addReaction(currentUserId, postId, emojiAlias);
      final models = <Model>[];

      final reactions = await databaseOperator.operator.handleReactions({
        'postsReactions': [
          {
            'post_id': postId,
            'reactions': [reaction],
          }
        ],
        'prepareRecordsOnly': true,
        'skipSync': true,  // this prevents the handler from deleting previous reactions
      });
      models.addAll(reactions);

      final recent = await addRecentReaction(serverUrl, [emojiName], true);
      models.addAll(recent);
    
      await databaseOperator.operator.batchRecords(models, 'addReaction');

      return {'reaction': reaction};
    }
    return {
      'reaction': {
        'user_id': currentUserId,
        'post_id': postId,
        'emoji_name': emojiAlias,
        'create_at': 0,
      }
    };
  } catch (error) {
    logDebug('error on addReaction', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<dynamic> removeReaction(String serverUrl, String postId, String emojiName) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final currentUserId = await getCurrentUserId(databaseOperator.database);
    final emojiAlias = getEmojiFirstAlias(emojiName);
    await client.removeReaction(currentUserId, postId, emojiAlias);

    final reaction = await queryReaction(databaseOperator.database, emojiAlias, postId, currentUserId).fetch();

    if (reaction.isNotEmpty) {
      await databaseOperator.database.write(() async {
        await reaction[0].destroyPermanently();
      });
    }

    return {'reaction': reaction};
  } catch (error) {
    logDebug('error on removeReaction', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<dynamic> handleReactionToLatestPost(String serverUrl, String emojiName, bool add, {String? rootId}) async {
  try {
    final databaseOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    List<PostModel> posts;
    if (rootId != null) {
      posts = await getRecentPostsInThread(databaseOperator.database, rootId);
    } else {
      final channelId = await getCurrentChannelId(databaseOperator.database);
      posts = await getRecentPostsInChannel(databaseOperator.database, channelId);
    }

    if (add) {
      return addReaction(serverUrl, posts[0].id, emojiName);
    }
    return removeReaction(serverUrl, posts[0].id, emojiName);
  } catch (error) {
    return {'error': error};
  }
}

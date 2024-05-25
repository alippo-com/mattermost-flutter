// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/database/operator/utils/post.dart';
import 'package:mattermost_flutter/database/operator/utils/reaction.dart';
import 'package:mattermost_flutter/types/mock.dart';
import 'package:test/test.dart';

void main() {
  group('DataOperator: Utils tests', () {
    test('=> sanitizePosts: should filter between ordered and unordered posts', () {
      final postsOrdered = sanitizePosts(
        posts: mockedPosts.posts.values.toList(),
        orders: mockedPosts.order,
      ).postsOrdered;
      final postsUnordered = sanitizePosts(
        posts: mockedPosts.posts.values.toList(),
        orders: mockedPosts.order,
      ).postsUnordered;

      expect(postsOrdered.length, 4);
      expect(postsUnordered.length, 2);
    });

    test('=> createPostsChain: should link posts amongst each other based on order array', () {
      final previousPostId = 'prev_xxyuoxmehne';
      final chainedOfPosts = createPostsChain(
        order: mockedPosts.order,
        posts: mockedPosts.posts.values.toList(),
        previousPostId: previousPostId,
      );

      final post1 = chainedOfPosts.firstWhere((post) => post.id == '8swgtrrdiff89jnsiwiip3y1eoe', orElse: () => null);
      expect(post1, isNotNull);
      expect(post1?.prevPostId, '8fcnk3p1jt8mmkaprgajoxz115a');

      final post2 = chainedOfPosts.firstWhere((post) => post.id == '8fcnk3p1jt8mmkaprgajoxz115a', orElse: () => null);
      expect(post2, isNotNull);
      expect(post2?.prevPostId, '3y3w3a6gkbg73bnj3xund9o5ic');

      final post3 = chainedOfPosts.firstWhere((post) => post.id == '3y3w3a6gkbg73bnj3xund9o5ic', orElse: () => null);
      expect(post3, isNotNull);
      expect(post3?.prevPostId, '4btbnmticjgw7ewd3qopmpiwqw');

      final post4 = chainedOfPosts.firstWhere((post) => post.id == '4btbnmticjgw7ewd3qopmpiwqw', orElse: () => null);
      expect(post4, isNotNull);
      expect(post4?.prevPostId, previousPostId);
    });

    test('=> sanitizeReactions: should triage between reactions that needs creation/deletion and emojis to be created', () async {
      const dbName = 'server_schema_connection';
      const serverUrl = 'https://appv2.mattermost.com';
      final server = await DatabaseManager.createServerDatabase(
        config: DatabaseConfig(
          dbName: dbName,
          serverUrl: serverUrl,
        ),
      );

      expect(server, isNotNull);

      // we commit one Reaction to our database
      final prepareRecords = await server.operator.handleReactions(
        postsReactions: [
          PostReaction(
            postId: '8ww8kb1dbpf59fu4d5xhu5nf5w',
            reactions: [
              Reaction(
                userId: 'beqkgo4wzbn98kjzjgc1p5n91o',
                postId: '8ww8kb1dbpf59fu4d5xhu5nf5w',
                emojiName: 'tada_will_be_removed',
                createAt: 1601558322701,
              ),
            ],
          )
        ],
        prepareRecordsOnly: true,
      );

      await server.database.write((writer) async {
        await writer.batch(prepareRecords);
      });

      final result = await sanitizeReactions(
        database: server.database,
        postId: '8ww8kb1dbpf59fu4d5xhu5nf5w',
        rawReactions: mockedReactions,
      );

      // The reaction with emojiName 'tada_will_be_removed' will be in the deleteReactions array. This implies that the user who reacted on that post later removed the reaction.
      expect(result.deleteReactions.length, 1);
      expect(result.deleteReactions[0].emojiName, 'tada_will_be_removed');

      expect(result.createReactions.length, 3);
    });
  });
}

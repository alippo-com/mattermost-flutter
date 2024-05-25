// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/models/post.dart';

/// sanitizePosts: Creates arrays of ordered and unordered posts.  Unordered posts are those posts that are not
/// present in the orders array
/// @param {SanitizePostsArgs} sanitizePosts
/// @param {Post[]} sanitizePosts.posts
/// @param {String[]} sanitizePosts.orders
Map<String, List<Post>> sanitizePosts({
  required List<Post> posts,
  required List<String> orders,
}) {
  final orderedPosts = <Post>[];
  final unOrderedPosts = <Post>[];
  final ordersSet = orders.toSet();

  for (final post in posts) {
    if (post.id != null && ordersSet.contains(post.id)) {
      orderedPosts.add(post);
    } else {
      unOrderedPosts.add(post);
    }
  }

  return {
    'postsOrdered': orderedPosts,
    'postsUnordered': unOrderedPosts,
  };
}

/// createPostsChain: Basically creates the 'chain of posts' using the 'orders' array; each post is linked to the other
/// by the previous_post_id field.
/// @param {ChainPostsArgs} chainPosts
/// @param {String[]} chainPosts.order
/// @param {Post[]} chainPosts.posts
/// @param {String} chainPosts.previousPostId
/// @returns {Post[]}
List<Post> createPostsChain({
  List<String> order = const [],
  required List<Post> posts,
  String previousPostId = '',
}) {
  final postsByIds = {for (var p in posts) p.id!: p};
  
  return order.asMap().entries.map((entry) {
    final id = entry.value;
    final index = entry.key;
    final post = postsByIds[id];

    if (post != null) {
      if (index == order.length - 1) {
        return post.copyWith(prevPostId: previousPostId);
      } else {
        return post.copyWith(prevPostId: order[index + 1]);
      }
    }
  }).whereType<Post>().toList().reversed.toList();
}

PostListEdges getPostListEdges(List<Post> posts) {
  // Sort a clone of 'posts' list by create_at
  final sortedPosts = [...posts]..sort((a, b) => a.createAt.compareTo(b.createAt));

  // The first element (beginning of chain)
  final firstPost = sortedPosts.first;
  final lastPost = sortedPosts.last;

  return PostListEdges(firstPost: firstPost, lastPost: lastPost);
}

class PostListEdges {
  final Post firstPost;
  final Post lastPost;

  PostListEdges({
    required this.firstPost,
    required this.lastPost,
  });
}

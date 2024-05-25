// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/utils/helpers.dart';
import 'package:mattermost_flutter/client/rest/constants.dart';
import 'package:mattermost_flutter/client/rest/base.dart';
import 'package:mattermost_flutter/types/post.dart';

abstract class ClientPostsMix {
  Future<Post> createPost(Post post);
  Future<Post> updatePost(Post post);
  Future<Post> getPost(String postId);
  Future<Post> patchPost(Post postPatch);
  Future<void> deletePost(String postId);
  Future<PostResponse> getPostThread(String postId, FetchPaginatedThreadOptions options);
  Future<PostResponse> getPosts(String channelId, {int page = 0, int perPage = PER_PAGE_DEFAULT, bool collapsedThreads = false, bool collapsedThreadsExtended = false});
  Future<PostResponse> getPostsSince(String channelId, int since, {bool collapsedThreads = false, bool collapsedThreadsExtended = false});
  Future<PostResponse> getPostsBefore(String channelId, {String postId = '', int page = 0, int perPage = PER_PAGE_DEFAULT, bool collapsedThreads = false, bool collapsedThreadsExtended = false});
  Future<PostResponse> getPostsAfter(String channelId, String postId, {int page = 0, int perPage = PER_PAGE_DEFAULT, bool collapsedThreads = false, bool collapsedThreadsExtended = false});
  Future<List<FileInfo>> getFileInfosForPost(String postId);
  Future<PostResponse> getSavedPosts(String userId, {String channelId = '', String teamId = '', int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<PostResponse> getPinnedPosts(String channelId);
  Future<void> markPostAsUnread(String userId, String postId);
  Future<void> pinPost(String postId);
  Future<void> unpinPost(String postId);
  Future<Reaction> addReaction(String userId, String postId, String emojiName);
  Future<void> removeReaction(String userId, String postId, String emojiName);
  Future<void> getReactionsForPost(String postId);
  Future<SearchPostResponse> searchPostsWithParams(String teamId, PostSearchParams params);
  Future<SearchPostResponse> searchPosts(String teamId, String terms, bool isOrSearch);
  Future<void> doPostAction(String postId, String actionId, {String selectedOption = ''});
  Future<void> doPostActionWithCookie(String postId, String actionId, String actionCookie, {String selectedOption = ''});
  Future<PostAcknowledgement> acknowledgePost(String postId, String userId);
  Future<void> unacknowledgePost(String postId, String userId);
}

class ClientPosts<TBase extends ClientBase> extends TBase implements ClientPostsMix {
  @override
  Future<Post> createPost(Post post) async {
    this.analytics?.trackAPI('api_posts_create', {'channel_id': post.channelId});

    if (post.rootId != null && post.rootId.isNotEmpty) {
      this.analytics?.trackAPI('api_posts_replied', {'channel_id': post.channelId});
    }

    return this.doFetch(
      '${this.getPostsRoute()}',
      {'method': 'post', 'body': post, 'noRetry': true},
    );
  }

  @override
  Future<Post> updatePost(Post post) async {
    this.analytics?.trackAPI('api_posts_update', {'channel_id': post.channelId});

    return this.doFetch(
      '${this.getPostRoute(post.id)}',
      {'method': 'put', 'body': post},
    );
  }

  @override
  Future<Post> getPost(String postId) async {
    return this.doFetch(
      '${this.getPostRoute(postId)}',
      {'method': 'get'},
    );
  }

  @override
  Future<Post> patchPost(Post postPatch) async {
    this.analytics?.trackAPI('api_posts_patch', {'channel_id': postPatch.channelId});

    return this.doFetch(
      '${this.getPostRoute(postPatch.id)}/patch',
      {'method': 'put', 'body': postPatch},
    );
  }

  @override
  Future<void> deletePost(String postId) async {
    this.analytics?.trackAPI('api_posts_delete');

    return this.doFetch(
      '${this.getPostRoute(postId)}',
      {'method': 'delete'},
    );
  }

  @override
  Future<PostResponse> getPostThread(String postId, FetchPaginatedThreadOptions options) async {
    final fetchThreads = options.fetchThreads ?? true;
    final collapsedThreads = options.collapsedThreads ?? false;
    final collapsedThreadsExtended = options.collapsedThreadsExtended ?? false;
    final direction = options.direction ?? 'up';
    final fetchAll = options.fetchAll ?? false;
    final perPage = fetchAll ? null : PER_PAGE_DEFAULT;

    return this.doFetch(
      '${this.getPostRoute(postId)}/thread${buildQueryString({'skipFetchThreads': !fetchThreads, 'collapsedThreads': collapsedThreads, 'collapsedThreadsExtended': collapsedThreadsExtended, 'direction': direction, 'perPage': perPage, ...options.toJson()})}',
      {'method': 'get'},
    );
  }

  @override
  Future<PostResponse> getPosts(String channelId, {int page = 0, int perPage = PER_PAGE_DEFAULT, bool collapsedThreads = false, bool collapsedThreadsExtended = false}) async {
    return this.doFetch(
      '${this.getChannelRoute(channelId)}/posts${buildQueryString({'page': page, 'per_page': perPage, 'collapsedThreads': collapsedThreads, 'collapsedThreadsExtended': collapsedThreadsExtended})}',
      {'method': 'get'},
    );
  }

  @override
  Future<PostResponse> getPostsSince(String channelId, int since, {bool collapsedThreads = false, bool collapsedThreadsExtended = false}) async {
    return this.doFetch(
      '${this.getChannelRoute(channelId)}/posts${buildQueryString({'since': since, 'collapsedThreads': collapsedThreads, 'collapsedThreadsExtended': collapsedThreadsExtended})}',
      {'method': 'get'},
    );
  }

  @override
  Future<PostResponse> getPostsBefore(String channelId, {String postId = '', int page = 0, int perPage = PER_PAGE_DEFAULT, bool collapsedThreads = false, bool collapsedThreadsExtended = false}) async {
    this.analytics?.trackAPI('api_posts_get_before', {'channel_id': channelId});

    return this.doFetch(
      '${this.getChannelRoute(channelId)}/posts${buildQueryString({'before': postId, 'page': page, 'per_page': perPage, 'collapsedThreads': collapsedThreads, 'collapsedThreadsExtended': collapsedThreadsExtended})}',
      {'method': 'get'},
    );
  }

  @override
  Future<PostResponse> getPostsAfter(String channelId, String postId, {int page = 0, int perPage = PER_PAGE_DEFAULT, bool collapsedThreads = false, bool collapsedThreadsExtended = false}) async {
    this.analytics?.trackAPI('api_posts_get_after', {'channel_id': channelId});

    return this.doFetch(
      '${this.getChannelRoute(channelId)}/posts${buildQueryString({'after': postId, 'page': page, 'per_page': perPage, 'collapsedThreads': collapsedThreads, 'collapsedThreadsExtended': collapsedThreadsExtended})}',
      {'method': 'get'},
    );
  }

  @override
  Future<List<FileInfo>> getFileInfosForPost(String postId) async {
    return this.doFetch(
      '${this.getPostRoute(postId)}/files/info',
      {'method': 'get'},
    );
  }

  @override
  Future<PostResponse> getSavedPosts(String userId, {String channelId = '', String teamId = '', int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    this.analytics?.trackAPI('api_posts_get_flagged', {'team_id': teamId});

    return this.doFetch(
      '${this.getUserRoute(userId)}/posts/flagged${buildQueryString({'channel_id': channelId, 'team_id': teamId, 'page': page, 'per_page': perPage})}',
      {'method': 'get'},
    );
  }

  @override
  Future<PostResponse> getPinnedPosts(String channelId) async {
    this.analytics?.trackAPI('api_posts_get_pinned', {'channel_id': channelId});
    return this.doFetch(
      '${this.getChannelRoute(channelId)}/pinned',
      {'method': 'get'},
    );
  }

  @override
  Future<void> markPostAsUnread(String userId, String postId) async {
    this.analytics?.trackAPI('api_post_set_unread_post');

    // collapsed_threads_supported is not based on user preferences but to know if "CLIENT" supports CRT
    final body = {'collapsed_threads_supported': true};

    return this.doFetch(
      '${this.getUserRoute(userId)}/posts/$postId/set_unread',
      {'method': 'post', 'body': body},
    );
  }

  @override
  Future<void> pinPost(String postId) async {
    this.analytics?.trackAPI('api_posts_pin');

    return this.doFetch(
      '${this.getPostRoute(postId)}/pin',
      {'method': 'post'},
    );
  }

  @override
  Future<void> unpinPost(String postId) async {
    this.analytics?.trackAPI('api_posts_unpin');

    return this.doFetch(
      '${this.getPostRoute(postId)}/unpin',
      {'method': 'post'},
    );
  }

  @override
  Future<Reaction> addReaction(String userId, String postId, String emojiName) async {
    this.analytics?.trackAPI('api_reactions_save', {'post_id': postId});

    return this.doFetch(
      '${this.getReactionsRoute()}',
      {'method': 'post', 'body': {'user_id': userId, 'post_id': postId, 'emoji_name': emojiName}},
    );
  }

  @override
  Future<void> removeReaction(String userId, String postId, String emojiName) async {
    this.analytics?.trackAPI('api_reactions_delete', {'post_id': postId});

    return this.doFetch(
      '${this.getUserRoute(userId)}/posts/$postId/reactions/$emojiName',
      {'method': 'delete'},
    );
  }

  @override
  Future<void> getReactionsForPost(String postId) async {
    return this.doFetch(
      '${this.getPostRoute(postId)}/reactions',
      {'method': 'get'},
    );
  }

  @override
  Future<SearchPostResponse> searchPostsWithParams(String teamId, PostSearchParams params) async {
    this.analytics?.trackAPI('api_posts_search');
    final endpoint = teamId.isNotEmpty ? '${this.getTeamRoute(teamId)}/posts/search' : '${this.getPostsRoute()}/search';
    return this.doFetch(endpoint, {'method': 'post', 'body': params});
  }

  @override
  Future<SearchPostResponse> searchPosts(String teamId, String terms, bool isOrSearch) async {
    return this.searchPostsWithParams(teamId, PostSearchParams(terms: terms, isOrSearch: isOrSearch));
  }

  @override
  Future<void> doPostAction(String postId, String actionId, {String selectedOption = ''}) async {
    return this.doPostActionWithCookie(postId, actionId, '', selectedOption: selectedOption);
  }

  @override
  Future<void> doPostActionWithCookie(String postId, String actionId, String actionCookie, {String selectedOption = ''}) async {
    if (selectedOption.isNotEmpty) {
      this.analytics?.trackAPI('api_interactive_messages_menu_selected');
    } else {
      this.analytics?.trackAPI('api_interactive_messages_button_clicked');
    }

    final msg = {
      'selected_option': selectedOption,
      if (actionCookie.isNotEmpty) 'cookie': actionCookie,
    };

    return this.doFetch(
      '${this.getPostRoute(postId)}/actions/${Uri.encodeComponent(actionId)}',
      {'method': 'post', 'body': msg},
    );
  }

  @override
  Future<PostAcknowledgement> acknowledgePost(String postId, String userId) async {
    return this.doFetch(
      '${this.getUserRoute(userId)}/posts/$postId/ack',
      {'method': 'post'},
    );
  }

  @override
  Future<void> unacknowledgePost(String postId, String userId) async {
    return this.doFetch(
      '${this.getUserRoute(userId)}/posts/$postId/ack',
      {'method': 'delete'},
    );
  }
}

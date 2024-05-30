// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/database/models/servers/post.dart';

class ViewableItemsChanged {
  final List<ViewToken> viewableItems;
  final List<ViewToken> changed;

  ViewableItemsChanged({required this.viewableItems, required this.changed});
}

typedef ViewableItemsChangedListenerEvent = void Function(List<ViewToken> viewableItems);

typedef ScrollEndIndexListener = Function(Function(int endIndex) fn);
typedef ViewableItemsListener = Function(Function(List<ViewToken> viewableItems) fn);

class PostWithPrevAndNext {
  final PostModel currentPost;
  final PostModel? nextPost;
  final PostModel? previousPost;
  final bool? isSaved;

  PostWithPrevAndNext({required this.currentPost, this.nextPost, this.previousPost, this.isSaved});
}

class PostListItem {
  final String type; // 'post'
  final PostWithPrevAndNext value;

  PostListItem({required this.type, required this.value});
}

class PostListOtherItem {
  final String type; // 'date' | 'thread-overview' | 'start-of-new-messages' | 'user-activity'
  final String value;

  PostListOtherItem({required this.type, required this.value});
}

typedef PostList = List<dynamic>; // List<PostListItem | PostListOtherItem]

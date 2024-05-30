
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/file.dart';
import 'package:mattermost_flutter/queries/post.dart';
import 'package:mattermost_flutter/queries/reaction.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/thread.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/utils/post.dart';
import 'package:mattermost_flutter/components/post.dart';
import 'package:mattermost_flutter/types/models/servers/post.dart';
import 'package:mattermost_flutter/types/models/servers/posts_in_thread.dart';
import 'package:mattermost_flutter/types/models/servers/user.dart';

class PostComponent extends StatelessWidget {
  final Database database;
  final UserModel? currentUser;
  final bool? isCRTEnabled;
  final PostModel? nextPost;
  final PostModel post;
  final PostModel? previousPost;
  final String location;

  PostComponent({
    required this.database,
    this.currentUser,
    this.isCRTEnabled,
    required this.nextPost,
    required this.post,
    required this.previousPost,
    required this.location,
  });

  Stream<bool> observeShouldHighlightReplyBar(Database database, UserModel currentUser, PostModel post, PostsInThreadModel postsInThread) {
    final myPostsCount = queryPostsBetween(database, postsInThread.earliest, postsInThread.latest, null, currentUser.id, '', post.rootId ?? post.id).observeCount();
    final root = observePost(database, post.rootId);

    return CombineLatestStream.list([myPostsCount, root]).switchMap(([mpc, r]) {
      final threadRepliedToByCurrentUser = mpc > 0;
      bool threadCreatedByCurrentUser = false;
      if (r?.userId == currentUser.id) {
        threadCreatedByCurrentUser = true;
      }
      String commentsNotifyLevel = Preferences.COMMENTS_NEVER;
      if (currentUser.notifyProps?.comments != null) {
        commentsNotifyLevel = currentUser.notifyProps.comments;
      }

      final notCurrentUser = post.userId != currentUser.id || post.props?['from_webhook'] != null;
      if (notCurrentUser) {
        if (commentsNotifyLevel == Preferences.COMMENTS_ANY && (threadCreatedByCurrentUser || threadRepliedToByCurrentUser)) {
          return Stream.value(true);
        } else if (commentsNotifyLevel == Preferences.COMMENTS_ROOT && threadCreatedByCurrentUser) {
          return Stream.value(true);
        }
      }

      return Stream.value(false);
    });
  }

  Stream<bool> observeHasReplies(Database database, PostModel post) {
    if (post.rootId == null) {
      return post.postsInThread.observe().switchMap((c) => Stream.value(c.length > 0));
    }

    return observePost(database, post.rootId).switchMap((r) {
      if (r != null) {
        return r.postsInThread.observe().switchMap((c) => Stream.value(c.length > 0));
      }
      return Stream.value(false);
    });
  }

  bool isFirstReply(PostModel post, [PostModel? previousPost]) {
    if (post.rootId != null) {
      if (previousPost != null) {
        return post.rootId != previousPost.id && post.rootId != previousPost.rootId;
      }
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLastReply = BehaviorSubject<bool>.seeded(true);
    final isPostAddChannelMember = BehaviorSubject<bool>.seeded(false);
    final isOwner = currentUser?.id == post.userId;
    final author = post.userId != null ? observePostAuthor(database, post) : BehaviorSubject<UserModel?>.seeded(null);
    final canDelete = observePermissionForPost(database, post, currentUser, isOwner ? Permissions.DELETE_POST : Permissions.DELETE_OTHERS_POSTS, false);
    final isEphemeral = BehaviorSubject<bool>.seeded(isPostEphemeral(post));

    if (post.props?['add_channel_member'] != null && isPostEphemeral(post) && currentUser != null) {
      isPostAddChannelMember.addStream(observeCanManageChannelMembers(database, post.channelId, currentUser));
    }

    final highlightReplyBar = BehaviorSubject<bool>.seeded(false);
    if (!isCRTEnabled! && location == Screens.CHANNEL) {
      post.postsInThread.observe().switchMap((postsInThreads) {
        if (postsInThreads.isNotEmpty && currentUser != null) {
          return observeShouldHighlightReplyBar(database, currentUser!, post, postsInThreads[0]);
        }
        return Stream.value(false);
      }).distinct().listen(highlightReplyBar.add);
    }

    bool differentThreadSequence = true;
    if (post.rootId != null) {
      differentThreadSequence = previousPost?.rootId != null ? previousPost!.rootId != post.rootId : previousPost?.id != post.rootId;
      isLastReply.add(!(nextPost?.rootId == post.rootId));
    }

    final hasReplies = observeHasReplies(database, post);
    final isConsecutivePost = author.switchMap((user) => Stream.value(post != null && previousPost != null && user?.isBot != true && areConsecutivePosts(post, previousPost))).distinct();
    final hasFiles = queryFilesForPost(database, post.id).observeCount().switchMap((c) => Stream.value(c > 0)).distinct();
    final hasReactions = queryReactionsForPost(database, post.id).observeCount().switchMap((c) => Stream.value(c > 0)).distinct();

    return Post(
      canDelete: canDelete,
      differentThreadSequence: Stream.value(differentThreadSequence),
      hasFiles: hasFiles,
      hasReplies: hasReplies,
      highlightReplyBar: highlightReplyBar,
      isConsecutivePost: isConsecutivePost,
      isEphemeral: isEphemeral,
      isFirstReply: Stream.value(isFirstReply(post, previousPost)),
      isLastReply: isLastReply,
      isPostAddChannelMember: isPostAddChannelMember,
      isPostPriorityEnabled: observeIsPostPriorityEnabled(database),
      post: post.observe(),
      thread: isCRTEnabled! ? observeThreadById(database, post.id) : Stream.value(null),
      hasReactions: hasReactions,
    );
  }
}

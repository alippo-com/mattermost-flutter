import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/permissions.dart';
import 'package:mattermost_flutter/queries/post.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/utils/post_list.dart';
import 'package:mattermost_flutter/components/combined_user_activity.dart';

class CombinedUserActivityContainer extends StatelessWidget {
  final Database database;
  final String postId;

  CombinedUserActivityContainer({
    required this.database,
    required this.postId,
  });

  Stream<bool> get currentUserId => observeCurrentUserId(database);

  Stream<UserModel?> get currentUser => currentUserId.switchMap((value) => observeUser(database, value));

  List<String> get postIds => getPostIdsForCombinedUserActivityPost(postId);

  Stream<List<PostModel>> get posts => queryPostsById(database, postIds).observeWithColumns(['props', 'message']);

  Stream<PostModel?> get post => posts.map((ps) => ps.isNotEmpty ? generateCombinedPost(postId, ps) : null);

  Stream<bool> get canDelete => CombineLatestStream.list([posts, currentUser])
      .switchMap(([ps, u]) => ps.isNotEmpty ? observePermissionForPost(database, ps[0], u!, Permissions.DELETE_OTHERS_POSTS, false) : Stream.value(false));

  Stream<Map<String, String>> get usernamesById => post.switchMap((p) {
    if (p == null) {
      return Stream.value({});
    }
    return queryUsersByIdsOrUsernames(database, p.props.user_activity.allUserIds, p.props.user_activity.allUsernames)
        .observeWithColumns(['username'])
        .switchMap((users) {
      return Stream.value(users.fold<Map<String, String>>({}, (acc, user) {
        acc[user.id] = user.username;
        return acc;
      }));
    });
  });

  @override
  Widget build(BuildContext context) {
    return CombinedUserActivity(
      canDelete: canDelete,
      currentUserId: currentUserId,
      post: post,
      usernamesById: usernamesById,
    );
  }
}

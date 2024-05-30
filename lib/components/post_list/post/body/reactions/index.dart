import 'package:flutter/material.dart';
import 'package:mattermost_flutter/typings/database/models/servers/post.dart';
import 'package:mattermost_flutter/typings/database/database.dart';
import 'package:mattermost_flutter/utils/permissions.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/components/reactions.dart';
import 'package:rxdart/rxdart.dart';

class ReactionsContainer extends StatelessWidget {
  final PostModel post;

  ReactionsContainer({
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context).database;

    final currentUserId = observeCurrentUserId(database);
    final currentUser = currentUserId.switchMap((id) => observeUser(database, id));
    final channel = observeChannel(database, post.channelId);
    final experimentalTownSquareIsReadOnly = observeConfigBooleanValue(database, 'ExperimentalTownSquareIsReadOnly');
    final disabled = Rx.combineLatest3(
      currentUser,
      channel,
      experimentalTownSquareIsReadOnly,
      (u, c, readOnly) => (c != null && c.deleteAt > 0) || (c?.name == General.DEFAULT_CHANNEL && !isSystemAdmin(u?.roles ?? '') && readOnly),
    );

    final canAddReaction = currentUser.switchMap((u) => observePermissionForPost(database, post, u, Permissions.ADD_REACTION, true));
    final canRemoveReaction = currentUser.switchMap((u) => observePermissionForPost(database, post, u, Permissions.REMOVE_REACTION, true));

    return Reactions(
      canAddReaction: canAddReaction,
      canRemoveReaction: canRemoveReaction,
      currentUserId: currentUserId,
      disabled: disabled,
      postId: post.id,
      reactions: observeReactionsForPost(database, post.id),
    );
  }
}

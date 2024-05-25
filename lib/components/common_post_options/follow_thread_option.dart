import 'package:flutter/material.dart';
import 'package:mattermost_flutter/actions/remote/thread.dart';
import 'package:mattermost_flutter/components/common_post_options.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class FollowThreadOption extends StatelessWidget {
  final AvailableScreens bottomSheetId;
  final ThreadModel thread;
  final String? teamId;

  FollowThreadOption({required this.bottomSheetId, required this.thread, this.teamId});

  Future<void> handleToggleFollow(BuildContext context) async {
    if (teamId == null) {
      return;
    }
    final serverUrl = useServerUrl(context);
    await dismissBottomSheet(context, bottomSheetId);
    updateThreadFollowing(serverUrl, teamId!, thread.id, !thread.isFollowing, true);
  }

  @override
  Widget build(BuildContext context) {
    String id;
    String defaultMessage;
    String icon;

    if (thread.isFollowing) {
      icon = 'message-minus-outline';
      if (thread.replyCount > 0) {
        id = t('threads.unfollowThread');
        defaultMessage = 'Unfollow Thread';
      } else {
        id = t('threads.unfollowMessage');
        defaultMessage = 'Unfollow Message';
      }
    } else {
      icon = 'message-plus-outline';
      if (thread.replyCount > 0) {
        id = t('threads.followThread');
        defaultMessage = 'Follow Thread';
      } else {
        id = t('threads.followMessage');
        defaultMessage = 'Follow Message';
      }
    }

    final followThreadOptionTestId = thread.isFollowing ? 'post_options.following_thread.option' : 'post_options.follow_thread.option';

    return BaseOption(
      i18nId: id,
      defaultMessage: defaultMessage,
      testID: followThreadOptionTestId,
      iconName: icon,
      onPress: () => handleToggleFollow(context),
    );
  }
}

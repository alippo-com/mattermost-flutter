
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/user_avatars_stack.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/typings/database/models/servers/thread.dart';
import 'package:mattermost_flutter/typings/database/models/servers/user.dart';

class Footer extends StatelessWidget {
  final String channelId;
  final String location;
  final List<UserModel> participants;
  final String? teamId;
  final ThreadModel thread;

  Footer({
    required this.channelId,
    required this.location,
    required this.participants,
    this.teamId,
    required this.thread,
  });

  BoxDecoration getFollowingButtonContainerBase(ThemeData theme) {
    return BoxDecoration(
      justifyContent: BoxFit.center,
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: 12),
    );
  }

  BoxDecoration getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(
        flexDirection: BoxFit.row,
        alignItems: BoxFit.center,
        minHeight: 40,
      ),
      'avatarsContainer': BoxDecoration(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(vertical: 8),
      ),
      'replyIconContainer': BoxDecoration(
        top: -1,
        margin: EdgeInsets.only(right: 5),
      ),
      'replies': TextStyle(
        alignSelf: BoxFit.center,
        color: changeOpacity(theme.centerChannelColor, 0.64),
        margin: EdgeInsets.only(right: 12),
        ...typography('Heading', 75),
      ),
      'notFollowingButtonContainer': BoxDecoration(
        ...getFollowingButtonContainerBase(theme),
        paddingLeft: 0,
      ),
      'notFollowing': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.64),
        ...typography('Heading', 75),
      ),
      'followingButtonContainer': BoxDecoration(
        ...getFollowingButtonContainerBase(theme),
        backgroundColor: changeOpacity(theme.buttonBg, 0.08),
        borderRadius: 4,
      ),
      'following': TextStyle(
        color: theme.buttonBg,
        ...typography('Heading', 75),
      ),
      'followSeparator': BoxDecoration(
        backgroundColor: changeOpacity(theme.centerChannelColor, 0.16),
        height: 16,
        margin: EdgeInsets.only(right: 12),
        width: 1,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final serverUrl = useServerUrl();
    final theme = useTheme();
    final styles = getStyleSheet(theme);

    final toggleFollow = preventDoubleTap(() {
      if (teamId == null) {
        return;
      }
      updateThreadFollowing(serverUrl, teamId!, thread.id, !thread.isFollowing, true);
    });

    Widget? repliesComponent;
    Widget? followButton;

    if (thread.replyCount != null && thread.replyCount! > 0) {
      repliesComponent = Row(
        children: [
          Container(
            decoration: styles['replyIconContainer'],
            child: CompassIcon(
              name: 'reply-outline',
              size: 18,
              color: changeOpacity(theme.centerChannelColor, 0.64),
            ),
          ),
          FormattedText(
            style: styles['replies'],
            id: 'threads.replies',
            defaultMessage: '{count} {count, plural, one {reply} other {replies}}',
            values: {'count': thread.replyCount},
          ),
        ],
      );
    }

    if (thread.isFollowing) {
      followButton = GestureDetector(
        onTap: toggleFollow,
        child: Container(
          decoration: styles['followingButtonContainer'],
          child: FormattedText(
            id: 'threads.following',
            defaultMessage: 'Following',
            style: styles['following'],
          ),
        ),
      );
    } else {
      followButton = Row(
        children: [
          Container(decoration: styles['followSeparator']),
          GestureDetector(
            onTap: toggleFollow,
            child: Container(
              decoration: styles['notFollowingButtonContainer'],
              child: FormattedText(
                id: 'threads.follow',
                defaultMessage: 'Follow',
                style: styles['notFollowing'],
              ),
            ),
          ),
        ],
      );
    }

    final participantsList = useMemo(() {
      if (participants.isNotEmpty) {
        final orderedParticipantsList = List<UserModel>.from(participants).reversed.toList();
        return orderedParticipantsList;
      }
      return [];
    }, [participants.length]);

    Widget? userAvatarsStack;
    if (participantsList.isNotEmpty) {
      userAvatarsStack = UserAvatarsStack(
        channelId: channelId,
        location: location,
        style: styles['avatarsContainer'],
        users: participantsList,
      );
    }

    return Container(
      decoration: styles['container'],
      child: Row(
        children: [
          if (userAvatarsStack != null) userAvatarsStack,
          if (repliesComponent != null) repliesComponent,
          followButton,
        ],
      );
    );
  }
}

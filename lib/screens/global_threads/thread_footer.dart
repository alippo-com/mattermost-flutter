// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/user_avatars_stack.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class ThreadFooter extends StatelessWidget {
  final UserModel? author;
  final String channelId;
  final String location;
  final List<UserModel> participants;
  final String testID;
  final ThreadModel thread;

  const ThreadFooter({
    Key? key,
    this.author,
    required this.channelId,
    required this.location,
    required this.participants,
    required this.testID,
    required this.thread,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = _getStyleSheet(theme);

    Widget? repliesComponent;
    if (thread.unreadReplies != null && thread.unreadReplies! > 0) {
      repliesComponent = FormattedText(
        id: 'threads.newReplies',
        defaultMessage: '{count} new {count, plural, one {reply} other {replies}}',
        style: style.unreadReplies,
        testID: '$testID.unread_replies',
        values: {'count': thread.unreadReplies},
      );
    } else if (thread.replyCount != null && thread.replyCount! > 0) {
      repliesComponent = FormattedText(
        id: 'threads.replies',
        defaultMessage: '{count} {count, plural, one {reply} other {replies}}',
        style: style.replies,
        testID: '$testID.reply_count',
        values: {'count': thread.replyCount},
      );
    }

    final participantsList = useMemo(() {
      if (author != null && participants.isNotEmpty) {
        final filteredParticipantsList = participants.where((participant) => participant.id != author!.id).toList().reversed.toList();
        filteredParticipantsList.insert(0, author!);
        return filteredParticipantsList;
      }
      return <UserModel>[];
    }, [participants, author]);

    Widget? userAvatarsStack;
    if (author != null && participantsList.isNotEmpty) {
      userAvatarsStack = UserAvatarsStack(
        channelId: channelId,
        location: location,
        style: style.avatarsContainer,
        users: participantsList,
      );
    }

    return Row(
      children: [
        if (userAvatarsStack != null) userAvatarsStack,
        if (repliesComponent != null) repliesComponent,
      ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        flexDirection: 'row',
        alignItems: 'center',
        minHeight: 40,
      ),
      'avatarsContainer': TextStyle(
        marginRight: 12,
        paddingVertical: 8,
      ),
      'replies': TextStyle(
        alignSelf: 'center',
        color: changeOpacity(theme.centerChannelColor, 0.64),
        marginRight: 12,
        ...typography('Body', 75, 'SemiBold'),
      ),
      'unreadReplies': TextStyle(
        alignSelf: 'center',
        color: theme.sidebarTextActiveBorder,
        marginRight: 12,
        ...typography('Body', 75, 'SemiBold'),
      ),
    };
  }
}

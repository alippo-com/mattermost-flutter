
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/avatars.dart';
import 'package:mattermost_flutter/theme.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class GroupMessage extends StatelessWidget {
  final String currentUserId;
  final String? displayName;
  final List<ChannelMembershipModel> members;

  GroupMessage({
    required this.currentUserId,
    this.displayName,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final theme = useTheme();
    final styles = _getStyleSheet(theme);
    final userIds = members.where((cm) => cm.userId != currentUserId).map((cm) => cm.userId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupAvatars(userIds: userIds),
        Text(
          displayName ?? '',
          style: styles['title'],
          key: Key('channel_info.title.group_message.display_name'),
        ),
      ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'title': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 16.0,  // Adjusted for a standard font size
        fontWeight: FontWeight.w600,  // Adjusted for semi-bold weight
      ),
    };
  }
}

class ChannelMembershipModel {
  final String userId;

  ChannelMembershipModel({required this.userId});
}

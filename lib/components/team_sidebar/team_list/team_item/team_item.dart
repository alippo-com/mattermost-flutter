
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/actions/remote/team.dart';
import 'package:mattermost_flutter/components/badge.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/server.dart';
import 'package:mattermost_flutter/context/theme.dart';

import 'team_icon.dart';

class TeamItem extends StatelessWidget {
  final TeamModel? team;
  final bool hasUnreads;
  final int mentionCount;
  final bool selected;

  const TeamItem({
    Key? key,
    this.team,
    required this.hasUnreads,
    required this.mentionCount,
    required this.selected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final serverUrl = useServerUrl(context);
    final styles = _getStyleSheet(theme);

    if (team == null) {
      return SizedBox.shrink();
    }

    final hasBadge = mentionCount > 0 || hasUnreads;
    var badgeStyle = styles['unread'];
    var value = mentionCount;
    if (mentionCount == 0 && hasUnreads) {
      value = -1;
    }

    if (value > 99) {
      badgeStyle = styles['mentionsThreeDigits'];
    } else if (value > 9) {
      badgeStyle = styles['mentionsTwoDigits'];
    } else if (value > 0) {
      badgeStyle = styles['mentionsOneDigit'];
    }

    final teamItem = 'team_sidebar.team_list.team_item.${team!.id}';
    final teamItemTestId = selected ? '$teamItem.selected' : '$teamItem.not_selected';

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: selected ? Border.all(width: 3, color: theme.sidebarTextActiveBorder) : null,
          ),
          margin: const EdgeInsets.symmetric(vertical: 3),
          child: TouchableWithFeedback(
            onPress: () => handleTeamChange(serverUrl, team!.id),
            type: TouchableWithFeedbackType.opacity,
            testID: teamItemTestId,
            child: TeamIcon(
              displayName: team!.displayName,
              id: team!.id,
              lastIconUpdate: team!.lastTeamIconUpdatedAt,
              selected: selected,
              testID: '$teamItem.team_icon',
            ),
          ),
        ),
        if (hasBadge && !selected)
          Badge(
            borderColor: theme.sidebarHeaderBg,
            visible: true,
            style: badgeStyle,
            value: value,
          ),
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(ThemeData theme) {
    return {
      'container': {
        'height': 54.0,
        'width': 54.0,
        'flex': 0,
        'padding': 3.0,
        'borderRadius': 10.0,
        'marginVertical': 3.0,
        'overflow': 'hidden',
      },
      'containerSelected': {
        'borderWidth': 3.0,
        'borderRadius': 14.0,
        'borderColor': theme.sidebarTextActiveBorder,
      },
      'unread': {
        'left': 43.0,
        'top': 3.0,
      },
      'mentionsOneDigit': {
        'top': 1.0,
        'left': 31.0,
      },
      'mentionsTwoDigits': {
        'top': 1.0,
        'left': 30.0,
      },
      'mentionsThreeDigits': {
        'top': 1.0,
        'left': 28.0,
      },
    };
  }
}

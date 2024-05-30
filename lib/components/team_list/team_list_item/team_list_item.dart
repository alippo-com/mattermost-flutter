
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/team_sidebar/team_list/team_item/team_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:mattermost_flutter/types/models/servers/team.dart';

const double itemHeight = 56.0;

class TeamListItem extends StatelessWidget {
  final TeamModel team;
  final String? textColor;
  final String? iconTextColor;
  final String? iconBackgroundColor;
  final String? selectedTeamId;
  final void Function(String) onPress;

  const TeamListItem({
    Key? key,
    required this.team,
    this.textColor,
    this.iconTextColor,
    this.iconBackgroundColor,
    this.selectedTeamId,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    final displayName = team.displayName;
    final lastTeamIconUpdateAt = team.lastTeamIconUpdatedAt;
    final teamListItemTestId = 'team_sidebar.team_list.team_list_item.${team.id}';

    return TouchableWithFeedback(
      onPress: () => onPress(team.id),
      type: 'opacity',
      style: styles['touchable']!,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            child: TeamIcon(
              id: team.id,
              displayName: displayName,
              lastIconUpdate: lastTeamIconUpdateAt,
              selected: false,
              textColor: iconTextColor ?? theme.centerChannelColor,
              backgroundColor: iconBackgroundColor ?? changeOpacity(theme.centerChannelColor, 0.16),
              testID: '${teamListItemTestId}.team_icon',
            ),
          ),
          Expanded(
            child: Text(
              displayName,
              style: [
                styles['text']!,
                if (textColor != null) TextStyle(color: textColor),
              ].reduce((value, element) => value.merge(element)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              key: Key('${teamListItemTestId}.team_display_name'),
            ),
          ),
          if (team.id == selectedTeamId)
            Container(
              child: CompassIcon(
                color: theme.buttonBg,
                name: 'check',
                size: 24,
              ),
            ),
        ],
      ),
    );
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'touchable': BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
      ),
      'text': TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        marginLeft: 16.0,
        flex: 1,
        fontSize: 14.0, // Assuming 'Body' with size 200 corresponds to fontSize 14
      ),
    };
  }
}

ThemeData useTheme(BuildContext context) {
  // Placeholder for theme context usage, replace with actual theme context retrieval logic
  return Theme.of(context);
}

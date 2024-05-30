
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/team_sidebar/team_icon.dart';
import 'package:mattermost_flutter/components/touchable_with_feedback.dart';
import 'package:mattermost_flutter/utils/theme.dart';

const MENU_DOWN_ICON_SIZE = 24.0;
const NO_TEAMS_HEIGHT = 392.0;

class TeamPickerIcon extends StatelessWidget {
  final double size;
  final bool divider;
  final List<TeamModel> teams;
  final Function(String) setTeamId;
  final String teamId;

  TeamPickerIcon({
    this.size = 24.0,
    this.divider = false,
    required this.teams,
    required this.setTeamId,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final selectedTeam = teams.firstWhere((t) => t.id == teamId, orElse: () => null);
    final title = Intl.message('Select a team to search', name: 'mobile.search.team.select');

    final handleTeamChange = preventDoubleTap(() {
      final renderContent = () {
        return BottomSheetTeamList(
          setTeamId: setTeamId,
          teams: teams,
          teamId: teamId,
          title: title,
        );
      };

      final snapPoints = [
        1.0,
        teams.length > 0 ? (bottomSheetSnapPoint(Math.min(3, teams.length), ITEM_HEIGHT, bottom) + TITLE_HEIGHT) : NO_TEAMS_HEIGHT,
      ];

      if (teams.length > 3) {
        snapPoints.add(0.8);
      }

      bottomSheet(
        context: context,
        closeButtonId: 'close-team_list',
        renderContent: renderContent,
        snapPoints: snapPoints,
        theme: theme,
        title: title,
      );
    });

    return selectedTeam != null
        ? TouchableWithFeedback(
            onPress: handleTeamChange,
            type: TouchableType.opacity,
            testID: 'team_picker.button',
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      TeamIcon(
                        displayName: selectedTeam.displayName,
                        id: selectedTeam.id,
                        lastIconUpdate: selectedTeam.lastTeamIconUpdatedAt,
                        textColor: theme.colorScheme.onSurface,
                        backgroundColor: theme.colorScheme.onSurface.withOpacity(0.16),
                        selected: false,
                        testID: 'team_picker.${selectedTeam.id}.team_icon',
                        smallText: true,
                      ),
                      CompassIcon(
                        color: theme.colorScheme.onSurface.withOpacity(0.56),
                        name: Icons.arrow_drop_down,
                        size: MENU_DOWN_ICON_SIZE,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container();
  }
}

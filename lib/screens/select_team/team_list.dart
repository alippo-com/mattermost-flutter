
// Converted from ./mattermost-mobile/app/screens/select_team/team_list.tsx

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/team_list.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TeamList extends StatelessWidget {
  final List<Team> teams;
  final VoidCallback onEndReached;
  final ValueChanged<String> onPress;
  final bool loading;

  TeamList({
    required this.teams,
    required this.onEndReached,
    required this.onPress,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheet(theme);
    final intl = AppLocalizations.of(context)!;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    final containerStyle = isTablet
        ? styles['container']!.copyWith(maxWidth: 600, alignment: Alignment.center)
        : styles['container'];

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            child: Column(
              children: [
                Text(
                  intl.select_team_title,
                  style: styles['title'],
                ),
                Text(
                  intl.select_team_description,
                  style: styles['description'],
                ),
              ],
            ),
          ),
          // TODO: Uncomment when the feature is ready
          // canCreateTeam ? Column(
          //   children: [
          //     AddTeamItem(),
          //     Divider(
          //       color: changeOpacity(theme.sidebarText, 0.08),
          //       thickness: 1,
          //       height: 16,
          //     ),
          //   ],
          // ) : Container(),
          TeamFlatList(
            teams: teams,
            textColor: theme.sidebarText,
            iconBackgroundColor: changeOpacity(theme.sidebarText, 0.16),
            iconTextColor: theme.sidebarText,
            onPress: onPress,
            onEndReached: onEndReached,
            loading: loading,
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'container': TextStyle(
        color: theme.sidebarBg,
      ),
      'title': TextStyle(
        color: theme.sidebarHeaderTextColor,
        marginTop: 40,
        ...typography('Heading', 800),
      ),
      'description': TextStyle(
        color: changeOpacity(theme.sidebarText, 0.72),
        marginTop: 12,
        marginBottom: 25,
        ...typography('Body', 200, 'Regular'),
      ),
    };
  }
}

class Team {
  // Define the properties and constructor of the Team class
}

typedef TeamFlatList = Widget Function({
  required List<Team> teams,
  required Color textColor,
  required Color iconBackgroundColor,
  required Color iconTextColor,
  required ValueChanged<String> onPress,
  required VoidCallback onEndReached,
  required bool loading,
});

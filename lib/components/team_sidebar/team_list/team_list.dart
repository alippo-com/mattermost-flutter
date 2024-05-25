import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'team_item.dart';
import 'package:mattermost_flutter/types/my_team_model.dart';

class TeamList extends StatelessWidget {
  final List<MyTeamModel> myOrderedTeams;
  final String? testID;

  TeamList({required this.myOrderedTeams, this.testID});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    return Container(
      constraints: BoxConstraints(
        minHeight: 0, // equivalent to flexShrink: 1 in React Native
      ),
      child: ListView.builder(
        itemCount: myOrderedTeams.length,
        itemBuilder: (context, index) {
          return TeamItem(myTeam: myOrderedTeams[index]);
        },
        padding: EdgeInsets.symmetric(vertical: 6).copyWith(bottom: 10),
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
      ),
    );
  }

  ThemeData useTheme(BuildContext context) {
    // Assume we have a method to get theme data
    return Theme.of(context);
  }

  Map<String, dynamic> getStyleSheet(ThemeData theme) {
    return {
      'container': BoxDecoration(),
      'contentContainer': BoxDecoration(
        alignItems: Alignment.center,
        margin: EdgeInsets.symmetric(vertical: 6),
        padding: EdgeInsets.only(bottom: 10),
      ),
    };
  }
}

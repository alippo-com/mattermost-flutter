
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/team_list.dart';
import 'package:mattermost_flutter/hooks/device.dart';
import 'package:mattermost_flutter/screens/bottom_sheet/content.dart';
import 'package:mattermost_flutter/screens/navigation.dart';
import 'package:mattermost_flutter/types/database/models/servers/team.dart';

class BottomSheetTeamList extends StatelessWidget {
  final List<TeamModel> teams;
  final String teamId;
  final ValueChanged<String> setTeamId;
  final String title;

  BottomSheetTeamList({
    required this.teams,
    required this.teamId,
    required this.setTeamId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = useIsTablet(context);
    final showTitle = !isTablet && teams.isNotEmpty;

    void onPress(String newTeamId) {
      setTeamId(newTeamId);
      dismissBottomSheet();
    }

    return BottomSheetContent(
      showButton: false,
      showTitle: showTitle,
      testID: 'search.select_team_slide_up',
      title: title,
      child: TeamList(
        selectedTeamId: teamId,
        teams: teams,
        onPress: onPress,
        testID: 'search.select_team_slide_up.team_list',
        type: isTablet ? 'FlatList' : 'BottomSheetFlatList',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/screens.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/option_item.dart';
import 'package:mattermost_flutter/utils/general.dart';
import 'package:provider/provider.dart';

class TeamSelector extends StatelessWidget {
  final List<Team> commonTeams;
  final Function(Team) onSelectTeam;
  final String? selectedTeamId;

  const TeamSelector({
    Key? key,
    required this.commonTeams,
    required this.onSelectTeam,
    this.selectedTeamId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final styles = _getStyleFromTheme(theme);
    final intl = Intl.of(context);

    final label = intl.formatMessage('channel_info.convert_gm_to_channel.team_selector.label', 'Team');
    final placeholder = intl.formatMessage('channel_info.convert_gm_to_channel.team_selector.placeholder', 'Select a Team');

    final selectedTeam = commonTeams.firstWhere((team) => team.id == selectedTeamId, orElse: () => null);

    void selectTeam(String teamId) {
      final team = commonTeams.firstWhere((team) => team.id == teamId, orElse: () => null);
      if (team != null) {
        onSelectTeam(team);
      }
    }

    void goToTeamSelectorList() async {
      await dismissBottomSheet(context);
      final title = intl.formatMessage('channel_info.convert_gm_to_channel.team_selector_list.title', 'Select Team');
      goToScreen(
        context,
        Screens.TEAM_SELECTOR_LIST,
        title,
        {'teams': commonTeams, 'selectTeam': selectTeam, 'selectedTeamId': selectedTeamId},
      );
    }

    return OptionItem(
      action: preventDoubleTap(goToTeamSelectorList),
      containerStyle: styles.teamSelector,
      label: label,
      type: Platform.isIOS ? 'arrow' : 'default',
      info: selectedTeam != null ? selectedTeam.displayName : placeholder,
      labelContainerStyle: styles.labelContainerStyle,
    );
  }

  Map<String, dynamic> _getStyleFromTheme(Theme theme) {
    return {
      'teamSelector': {
        'borderTopWidth': 1,
        'borderBottomWidth': 1,
        'borderColor': changeOpacity(theme.centerChannelColor, 0.08),
      },
      'labelContainerStyle': {
        'flexShrink': 0,
      },
    };
  }
}

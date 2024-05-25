
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/search_bar.dart';
import 'package:mattermost_flutter/components/team_list.dart';
import 'package:mattermost_flutter/utils/tap.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/navigation.dart';
import 'package:provider/provider.dart';
import 'package:lodash/lodash.dart';

class TeamSelectorList extends StatefulWidget {
  final List<Team> teams;
  final Function(String) selectTeam;

  TeamSelectorList({required this.teams, required this.selectTeam});

  @override
  _TeamSelectorListState createState() => _TeamSelectorListState();
}

class _TeamSelectorListState extends State<TeamSelectorList> {
  late List<Team> filteredTeams;

  @override
  void initState() {
    super.initState();
    filteredTeams = widget.teams;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final color = changeOpacity(theme.centerChannelColor, 0.72);

    void handleOnChangeSearchText(String searchTerm) {
      debounce(() {
        if (searchTerm == '') {
          setState(() {
            filteredTeams = widget.teams;
          });
        } else {
          setState(() {
            filteredTeams = widget.teams
                .where((team) => team.displayName.contains(searchTerm) || team.name.contains(searchTerm))
                .toList();
          });
        }
      }, 200)();
    }

    void handleOnPress(String teamId) {
      preventDoubleTap(() {
        widget.selectTeam(teamId);
        popTopScreen(context);
      })();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SearchBar(
              autoCapitalize: TextCapitalization.none,
              autoFocus: true,
              keyboardAppearance: getKeyboardAppearanceFromTheme(theme),
              placeholderTextColor: color,
              searchIconColor: color,
              testID: 'convert_gm_to_channel_team_search_bar',
              onChangeText: handleOnChangeSearchText,
            ),
            SizedBox(height: 12),
            Expanded(
              child: TeamList(
                teams: filteredTeams,
                onPress: handleOnPress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic> _getStyleFromTheme(Theme theme) {
  return {
    'container': {
      'padding': 12.0,
    },
    'listContainer': {
      'marginTop': 12.0,
    },
  };
}

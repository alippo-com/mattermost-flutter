import 'package:flutter/material.dart';

import 'modifiers.dart';
import 'recent_searches.dart';
import 'package:mattermost_flutter/types/search_ref.dart';
import 'package:mattermost_flutter/types/team.dart';
import 'package:mattermost_flutter/types/team_search_history.dart';

class Initial extends StatelessWidget {
    final List<TeamSearchHistory> recentSearches;
    final ValueNotifier<bool> scrollEnabled;
    final String? searchValue;
    final ValueNotifier<String> setRecentValue;
    final SearchRef searchRef;
    final ValueNotifier<String> setSearchValue;
    final ValueNotifier<String> setTeamId;
    final String teamId;
    final String teamName;
    final List<Team> teams;

    Initial({
        required this.recentSearches,
        required this.scrollEnabled,
        this.searchValue,
        required this.setRecentValue,
        required this.searchRef,
        required this.setSearchValue,
        required this.setTeamId,
        required this.teamId,
        required this.teamName,
        required this.teams,
    });

    @override
    Widget build(BuildContext context) {
        return Column(
            children: [
                Modifiers(
                    searchValue: searchValue,
                    searchRef: searchRef,
                    setSearchValue: setSearchValue,
                    setTeamId: setTeamId,
                    teamId: teamId,
                    teams: teams,
                    scrollEnabled: scrollEnabled,
                ),
                if (recentSearches.isNotEmpty)
                    RecentSearches(
                        recentSearches: recentSearches,
                        setRecentValue: setRecentValue,
                        teamName: teamName,
                    ),
            ],
        );
    }
}

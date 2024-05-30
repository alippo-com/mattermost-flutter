// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/i18n/default_locale.dart';
import 'package:mattermost_flutter/types/base.dart';

Team? selectDefaultTeam(List<Team> teams, [String locale = DEFAULT_LOCALE, String userTeamOrderPreference = '', String primaryTeam = '']) {
  Team? defaultTeam;

  if (teams.isEmpty) {
    return defaultTeam;
  }

  if (primaryTeam.isNotEmpty) {
    defaultTeam = teams.firstWhere(
      (t) => t.name.toLowerCase() == primaryTeam.toLowerCase(),
      orElse: () => null,
    );
  }

  if (defaultTeam == null) {
    defaultTeam = sortTeamsByUserPreference(teams, locale, userTeamOrderPreference).first;
  }

  return defaultTeam;
}

List<Team> sortTeamsByUserPreference(List<Team> teams, String locale, [String teamsOrder = '']) {
  if (teams.isEmpty) {
    return [];
  }

  var teamsOrderArray = teamsOrder.split(',').where((t) => t.isNotEmpty).toList();
  var teamsOrderList = Set.from(teamsOrderArray);

  if (teamsOrderList.isEmpty) {
    return List.from(teams)..sort(sortTeamsWithLocale(locale));
  }

  var customSortedTeams = teams.where((team) => teamsOrderList.contains(team.id)).toList()
    ..sort((a, b) => teamsOrderArray.indexOf(a.id) - teamsOrderArray.indexOf(b.id));

  var otherTeams = teams.where((team) => !teamsOrderList.contains(team.id)).toList()
    ..sort(sortTeamsWithLocale(locale));

  return [...customSortedTeams, ...otherTeams];
}

int Function(Team, Team) sortTeamsWithLocale(String locale) {
  return (a, b) {
    var aDisplayName = a.displayName ?? a.display_name;
    var bDisplayName = b.displayName ?? b.display_name;

    if (aDisplayName.toLowerCase() != bDisplayName.toLowerCase()) {
      return aDisplayName.toLowerCase().compareTo(bDisplayName.toLowerCase());
    }

    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  };
}

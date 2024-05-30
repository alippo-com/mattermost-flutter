
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/models/team.dart';
import 'package:mattermost_flutter/screens/initial.dart';
import 'package:mattermost_flutter/queries/team_queries.dart';

class EnhanceProps {
  final Database database;
  final String teamId;

  EnhanceProps({required this.database, required this.teamId});
}

class EnhancedInitial extends StatelessWidget {
  final EnhanceProps props;

  EnhancedInitial({required this.props});

  @override
  Widget build(BuildContext context) {
    final recentSearchesStream = queryTeamSearchHistoryByTeamId(props.database, props.teamId).asStream();
    final teamNameStream = observeTeam(props.database, props.teamId).switchMap((team) {
      return Stream.value(team?.displayName ?? '');
    }).distinct();

    return MultiProvider(
      providers: [
        StreamProvider<List<SearchHistory>>.value(value: recentSearchesStream, initialData: []),
        StreamProvider<String>.value(value: teamNameStream, initialData: ''),
      ],
      child: Initial(),
    );
  }
}

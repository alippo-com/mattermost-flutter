// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/components/team_sidebar/team_list/team_list.dart';
import 'package:watermelon_db/watermelon_db.dart';

class TeamListWithTeams extends StatelessWidget {
  final Database database;

  TeamListWithTeams({required this.database});

  @override
  Widget build(BuildContext context) {
    final myTeams = queryMyTeams(database).observe();
    final teamIds = queryJoinedTeams(database).observe().map(
          (ts) => ts.map((t) => {'id': t.id, 'displayName': t.displayName}).toList(),
        );
    final order = queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.TEAMS_ORDER)
        .observeWithColumns(['value']).switchMap(
          (p) => p.isNotEmpty ? Stream.value(p[0].value.split(',')) : Stream.value([]),
        );

    final myOrderedTeams = Rx.combineLatest3(myTeams, order, teamIds, (ts, o, tids) {
      List<String> ids = o;
      if (o.isEmpty) {
        ids = tids
            .map((t) => t['displayName'])
            .toList()
            .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))
            .map((t) => t['id'])
            .toList();
      }

      final Map<String, int> indexes = {};
      final Map<String, int> originalIndexes = {};
      ids.asMap().forEach((i, v) => indexes[v] = i);
      ts.asMap().forEach((i, t) => originalIndexes[t.id] = i);

      return ts
        ..sort((a, b) {
          if (indexes[a.id] != null || indexes[b.id] != null) {
            return (indexes[a.id] ?? tids.length) - (indexes[b.id] ?? tids.length);
          }
          return originalIndexes[a.id] - originalIndexes[b.id];
        });
    });

    return StreamBuilder(
      stream: myOrderedTeams,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TeamList(teams: snapshot.data!);
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

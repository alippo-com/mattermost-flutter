
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/screens/select_team/select_team.dart';
import 'package:rxdart/rxdart.dart';

class EnhancedSelectTeam extends StatelessWidget {
  final Database database;

  EnhancedSelectTeam({required this.database});

  @override
  Widget build(BuildContext context) {
    final myTeams = queryMyTeams(database).asObservable();
    final nTeams = myTeams.switchMap((mm) => Observable.just(mm.length));
    final firstTeamId = myTeams.switchMap((mm) => Observable.just(mm.isNotEmpty ? mm.first.id : null));

    return SelectTeam(
      nTeams: nTeams,
      firstTeamId: firstTeamId,
    );
  }
}

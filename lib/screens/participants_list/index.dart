// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/observers.dart';
import 'package:mattermost_flutter/types/participants_list.dart';
import 'package:mattermost_flutter/types/servers/user.dart';
import 'package:sqflite/sqflite.dart';

class ParticipantsListScreen extends StatelessWidget {
  final Observable<Map<String, dynamic>> sessionsDict;
  final Observable<String> teammateNameDisplay;

  ParticipantsListScreen({
    required this.sessionsDict,
    required this.teammateNameDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return ParticipantsList(
      sessionsDict: sessionsDict,
      teammateNameDisplay: teammateNameDisplay,
    );
  }
}

Observable<String> observeTeammateNameDisplay(Database db) {
  // Your implementation to observe teammate name display from the database
}

Observable<Map<String, dynamic>> observeCurrentSessionsDict() {
  // Your implementation to observe current sessions dictionary
}

class EnhancedParticipantsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teammateNameDisplay = observeCallDatabase().switchMap((db) {
      return db != null ? observeTeammateNameDisplay(db) : Observable.just('');
    }).distinct();

    return ParticipantsListScreen(
      sessionsDict: observeCurrentSessionsDict(),
      teammateNameDisplay: teammateNameDisplay,
    );
  }
}

Observable<Database?> observeCallDatabase() {
  // Your implementation to observe call database
}

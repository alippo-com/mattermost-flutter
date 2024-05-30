// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/calls/observers.dart';
import 'package:mattermost_flutter/calls/screens/participants_list/participants_list.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';

class EnhancedParticipantsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teammateNameDisplay = observeCallDatabase().switchMap((db) {
      return db != null ? observeTeammateNameDisplay(db) : Stream.value('');
    }).distinct();

    return ParticipantsList(
      sessionsDict: observeCurrentSessionsDict(),
      teammateNameDisplay: teammateNameDisplay,
    );
  }
}

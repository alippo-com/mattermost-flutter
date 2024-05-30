
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';

class EnhancedCreateDirectMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final restrictDirectMessage = observeConfigValue(database, 'RestrictDirectMessage').map(
      (v) => v != General.RESTRICT_DIRECT_MESSAGE_ANY,
    );

    return StreamBuilder(
      stream: restrictDirectMessage,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final restrictDirectMessageValue = snapshot.data;

        // Other observables
        final teammateNameDisplay = observeTeammateNameDisplay(database);
        final currentUserId = observeCurrentUserId(database);
        final currentTeamId = observeCurrentTeamId(database);
        final tutorialWatched = observeTutorialWatched(Tutorial.PROFILE_LONG_PRESS);

        return MultiProvider(
          providers: [
            StreamProvider.value(value: teammateNameDisplay, initialData: ''),
            StreamProvider.value(value: currentUserId, initialData: ''),
            StreamProvider.value(value: currentTeamId, initialData: ''),
            StreamProvider.value(value: tutorialWatched, initialData: false),
            Provider.value(value: restrictDirectMessageValue),
          ],
          child: CreateDirectMessage(),
        );
      },
    );
  }
}

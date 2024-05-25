
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/components/mark_unread_option.dart';
import 'package:mattermost_flutter/types/database.dart';

class MarkUnreadOptionWrapper extends StatelessWidget {
  final Database database;

  MarkUnreadOptionWrapper({required this.database});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CombineLatestStream.list([
        observeCurrentTeamId(database),
        observeIsCRTEnabled(database)
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final teamId = snapshot.data[0];
        final isCRTEnabled = snapshot.data[1];

        return MarkAsUnreadOption(
          teamId: teamId,
          isCRTEnabled: isCRTEnabled,
        );
      },
    );
  }
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/convert_gm_to_channel/convert_gm_to_channel.dart';

class ConvertGMToChannelContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = DatabaseProvider.of(context);

    return StreamBuilder(
      stream: Rx.combineLatest2(
        observeCurrentUserId(database),
        observeTeammateNameDisplay(database),
        (currentUserId, teammateNameDisplay) {
          return {
            'currentUserId': currentUserId,
            'teammateNameDisplay': teammateNameDisplay,
          };
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;
        return ConvertGMToChannel(
          currentUserId: data['currentUserId'],
          teammateNameDisplay: data['teammateNameDisplay'],
        );
      },
    );
  }
}

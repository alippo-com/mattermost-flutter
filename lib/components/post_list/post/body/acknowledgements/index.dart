// Dart Code
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:watermelondb/observable.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/components/post_list/post/body/acknowledgements/acknowledgements.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class EnhancedAcknowledgements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final currentUser = observeCurrentUser(database);

    return StreamBuilder(
      stream: Rx.combineLatest2(
        currentUser.switchMap((c) => Stream.value(c?.id)),
        currentUser.switchMap((c) => Stream.value(c?.timezone)),
        (currentUserId, currentUserTimezone) => {
          'currentUserId': currentUserId,
          'currentUserTimezone': currentUserTimezone,
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data as Map<String, dynamic>;

        return Acknowledgements(
          currentUserId: data['currentUserId'],
          currentUserTimezone: data['currentUserTimezone'],
        );
      },
    );
  }
}

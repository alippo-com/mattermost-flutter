// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:rxdart/rxdart.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/calls/observers.dart';
import 'package:mattermost_flutter/calls/screens/call_screen.dart';
import 'package:mattermost_flutter/calls/state.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';

class CallScreenEnhanced extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final micPermissionsGranted = observeGlobalCallsState().switchMap((gs) => Observable.just(gs.micPermissionsGranted)).distinct().asBroadcastStream();
    final teammateNameDisplay = observeCallDatabase().switchMap((db) => db != null ? observeTeammateNameDisplay(db) : Observable.just('')).distinct().asBroadcastStream();

    return StreamBuilder(
      stream: CombineLatestStream.combine2(
        observeCurrentCall(),
        observeCurrentSessionsDict(),
        (currentCall, sessionsDict) {
          return {
            'currentCall': currentCall,
            'sessionsDict': sessionsDict,
            'micPermissionsGranted': micPermissionsGranted,
            'teammateNameDisplay': teammateNameDisplay,
          };
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data;
        return CallScreen(
          currentCall: data['currentCall'],
          sessionsDict: data['sessionsDict'],
          micPermissionsGranted: data['micPermissionsGranted'],
          teammateNameDisplay: data['teammateNameDisplay'],
        );
      },
    );
  }
}

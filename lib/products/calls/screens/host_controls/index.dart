
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/observers.dart';
import 'package:mattermost_flutter/types/state.dart';
import 'package:mattermost_flutter/types/queries.dart';
import 'package:mattermost_flutter/screens/host_controls/host_controls.dart';

class HostControlsProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teammateNameDisplay = observeCallDatabase().switchMap((db) {
      return db != null ? observeTeammateNameDisplay(db) : BehaviorSubject.seeded('');
    }).distinct();

    final hideGuestTags = observeCallDatabase().switchMap((db) {
      return db != null ? observeConfigBooleanValue(db, 'HideGuestTags') : BehaviorSubject.seeded(false);
    }).distinct();

    return StreamBuilder(
      stream: Rx.combineLatest4(
        observeCurrentCall(),
        observeCurrentSessionsDict(),
        teammateNameDisplay,
        hideGuestTags,
        (currentCall, sessionsDict, teammateNameDisplay, hideGuestTags) {
          return {
            'currentCall': currentCall,
            'sessionsDict': sessionsDict,
            'teammateNameDisplay': teammateNameDisplay,
            'hideGuestTags': hideGuestTags,
          };
        },
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final data = snapshot.data;
        return HostControls(
          currentCall: data['currentCall'],
          sessionsDict: data['sessionsDict'],
          teammateNameDisplay: data['teammateNameDisplay'],
          hideGuestTags: data['hideGuestTags'],
        );
      },
    );
  }
}

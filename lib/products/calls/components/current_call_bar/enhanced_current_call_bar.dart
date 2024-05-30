import 'package:flutter/material.dart';
import 'package:flutter_rx/observables.dart';
import 'package:mattermost_flutter/types/calls/observers.dart';
import 'package:mattermost_flutter/types/calls/state.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/types/servers/channel.dart';
import 'package:mattermost_flutter/types/servers/user.dart';
import 'current_call_bar.dart';

class EnhancedCurrentCallBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentCall = observeCurrentCall();

    final ccServerUrl = currentCall.switchMap((call) => Observable.just(call?.serverUrl ?? '')).distinctUntilChanged();

    final ccChannelId = currentCall.switchMap((call) => Observable.just(call?.channelId ?? '')).distinctUntilChanged();

    final database = ccServerUrl.switchMap((url) => Observable.just(DatabaseManager.serverDatabases[url]?.database));

    final displayName = Observable.combineLatest2(
      database,
      ccChannelId,
      (db, id) => db != null && id != null ? observeChannel(db, id) : Observable.just(null),
    ).switchMap((c) => Observable.just(c?.displayName ?? '')).distinctUntilChanged();

    final teammateNameDisplay = database.switchMap((db) => db != null ? observeTeammateNameDisplay(db) : Observable.just('')).distinctUntilChanged();

    final micPermissionsGranted = observeGlobalCallsState().switchMap((gs) => Observable.just(gs.micPermissionsGranted)).distinctUntilChanged();

    return CurrentCallBar(
      displayName: displayName,
      currentCall: currentCall,
      sessionsDict: observeCurrentSessionsDict(),
      teammateNameDisplay: teammateNameDisplay,
      micPermissionsGranted: micPermissionsGranted,
    );
  }
}

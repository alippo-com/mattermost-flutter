// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/observers/call_state_observer.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'thread.dart';

class EnhanceProps {
  final String serverUrl;
  final String rootId;
  final Database database;

  EnhanceProps({required this.serverUrl, required this.rootId, required this.database});
}

class EnhancedThread extends StatelessWidget {
  final EnhanceProps props;

  EnhancedThread(this.props);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<String>(
          create: (_) {
            final rId = props.rootId.isNotEmpty ? props.rootId : EphemeralStore.getCurrentThreadId();
            final rootPost = observePost(props.database, rId);

            final channelId = rootPost.switchMap((r) => Stream.value(r?.channelId ?? '').distinct());

            return observeIsCRTEnabled(props.database)
                .combineLatest(observeCallStateInChannel(props.serverUrl, props.database, channelId), (isCRTEnabled, callState) {
              return {
                'isCRTEnabled': isCRTEnabled,
                ...callState,
                'rootId': rId,
                'rootPost': rootPost,
              };
            });
          },
          initialData: {},
        ),
      ],
      child: Thread(),
    );
  }
}

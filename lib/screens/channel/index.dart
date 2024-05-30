import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/utils/database.dart'; // Custom database utilities
// Constants for preferences
import 'package:mattermost_flutter/context/server.dart'; // Custom server context
import 'package:mattermost_flutter/observers/call.dart'; // Custom call state observer
import 'package:mattermost_flutter/components/channel.dart'; // The Channel component

class EnhancedChannel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final serverUrl = Provider.of<String>(context);
    
    final channelId = observeCurrentChannelId(database);
    final dismissedGMasDMNotice = queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.SYSTEM_NOTICE, Preferences.NOTICES.GM_AS_DM).asStream();
    final channelType = observeCurrentChannel(database).switchMap((c) => Stream.value(c?.type));
    final currentUserId = observeCurrentUserId(database);
    final hasGMasDMFeature = observeHasGMasDMFeature(database);
    
    return StreamProvider(
      create: (context) => CombineLatestStream.list([
        channelId,
        observeCallStateInChannel(serverUrl, database, channelId),
        observeIsCallsEnabledInChannel(database, serverUrl, channelId),
        dismissedGMasDMNotice,
        channelType,
        currentUserId,
        hasGMasDMFeature,
      ]).map((values) {
        return {
          'channelId': values[0],
          'callState': values[1],
          'isCallsEnabledInChannel': values[2],
          'dismissedGMasDMNotice': values[3],
          'channelType': values[4],
          'currentUserId': values[5],
          'hasGMasDMFeature': values[6],
        };
      }),
      initialData: {
        'channelId': null,
        'callState': null,
        'isCallsEnabledInChannel': null,
        'dismissedGMasDMNotice': null,
        'channelType': null,
        'currentUserId': null,
        'hasGMasDMFeature': null,
      },
      child: Channel(),
    );
  }
}

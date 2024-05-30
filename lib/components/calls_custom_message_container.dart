// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:rx_dart/rx_dart.dart';
import 'package:mattermost_flutter/components/calls_custom_message.dart';
import 'package:mattermost_flutter/observers/calls_observers.dart';
import 'package:mattermost_flutter/state/calls_state.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';

class CallsCustomMessageContainer extends HookWidget {
  final String serverUrl;
  final PostModel post;

  CallsCustomMessageContainer({required this.serverUrl, required this.post});

  @override
  Widget build(BuildContext context) {
    final database = useDatabase();
    final currentUser = useStream(observeCurrentUser(database));
    final author = useStream(observeUser(database, post.userId));
    final isMilitaryTime = useStream(
      queryDisplayNamePreferences(database)
          .observeWithColumns(['value'])
          .switchMap((preferences) => Stream.value(getDisplayNamePreferenceAsBool(preferences, Preferences.USE_MILITARY_TIME))),
    );

    if (post.props.endAt != null) {
      return CallsCustomMessage(
        currentUser: currentUser,
        author: author,
        isMilitaryTime: isMilitaryTime,
      );
    }

    final ccChannelId = useStream(
      observeCurrentCall().switchMap((call) => Stream.value(call?.channelId)).distinct(),
    );

    return CallsCustomMessage(
      currentUser: currentUser,
      author: author,
      isMilitaryTime: isMilitaryTime,
      teammateNameDisplay: useStream(observeTeammateNameDisplay(database)),
      limitRestrictedInfo: useStream(observeIsCallLimitRestricted(database, serverUrl, post.channelId)),
      ccChannelId: ccChannelId,
    );
  }
}

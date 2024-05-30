// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mattermost_flutter/database/queries/channel.dart';
import 'package:mattermost_flutter/database/queries/custom_emoji.dart';
import 'package:mattermost_flutter/database/queries/system.dart';
import 'package:mattermost_flutter/database/queries/user.dart';
import 'package:mattermost_flutter/utils/emoji_helpers.dart';
import 'results.dart';

class ResultsScreen extends HookWidget {
  final List<String> fileChannelIds;

  ResultsScreen({required this.fileChannelIds});

  @override
  Widget build(BuildContext context) {
    final database = useDatabase();

    final fileChannels = useObservable(queryChannelsById(database, fileChannelIds).watch().map((channels) {
      return channels.map((channel) => channel.displayName).toList();
    }));

    final currentUser = useObservable(observeCurrentUser(database));
    final appsEnabled = useObservable(observeConfigBooleanValue(database, 'FeatureFlagAppsEnabled'));
    final currentTimezone = useObservable(currentUser.map((user) => getTimezone(user?.timezone)));
    final customEmojiNames = useObservable(queryAllCustomEmojis(database).watch().map((customEmojis) {
      return mapCustomEmojiNames(customEmojis);
    }));
    final canDownloadFiles = useObservable(observeCanDownloadFiles(database));
    final publicLinkEnabled = useObservable(observeConfigBooleanValue(database, 'EnablePublicLink'));

    return Results(
      appsEnabled: appsEnabled,
      currentTimezone: currentTimezone,
      customEmojiNames: customEmojiNames,
      fileChannels: fileChannels,
      canDownloadFiles: canDownloadFiles,
      publicLinkEnabled: publicLinkEnabled,
    );
  }
}

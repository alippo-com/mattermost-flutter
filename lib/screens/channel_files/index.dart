
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/screens/channel_files/channel_files.dart';
import 'package:provider/provider.dart';

class ChannelFilesScreen extends StatelessWidget {
  final String channelId;

  const ChannelFilesScreen({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: observeChannel(database, channelId),
          initialData: null,
        ),
        StreamProvider.value(
          value: observeCanDownloadFiles(database),
          initialData: false,
        ),
        StreamProvider.value(
          value: observeConfigBooleanValue(database, 'EnablePublicLink'),
          initialData: false,
        ),
      ],
      child: ChannelFiles(),
    );
  }
}

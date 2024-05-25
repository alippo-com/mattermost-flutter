import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/components/create_or_edit_channel.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class CreateOrEditChannelScreen extends StatelessWidget {
  final String? channelId;

  CreateOrEditChannelScreen({this.channelId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    final channel = channelId != null ? observeChannel(database, channelId!) : Stream.value(null);
    final channelInfo = channelId != null ? observeChannelInfo(database, channelId!) : Stream.value(null);

    return StreamBuilder(
      stream: Rx.combineLatest2(channel, channelInfo, (ch, chInfo) => {'channel': ch, 'channelInfo': chInfo}),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data as Map<String, dynamic>;
        return CreateOrEditChannel(
          channel: data['channel'],
          channelInfo: data['channelInfo'],
        );
      },
    );
  }
}

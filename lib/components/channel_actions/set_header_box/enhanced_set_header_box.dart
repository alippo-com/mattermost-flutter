
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/channel_actions/set_header_box/set_header.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class EnhancedSetHeaderBox extends StatelessWidget {
  final String channelId;

  EnhancedSetHeaderBox({required this.channelId});

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    // Observable to check if header is set
    final isHeaderSet = database.observeChannelInfo(channelId)
      .switchMap((channel) => Stream.value(channel?.header != null))
      .distinct();

    return StreamBuilder<bool>(
      stream: isHeaderSet,
      builder: (context, snapshot) {
        final headerSet = snapshot.data ?? false;

        return SetHeaderBox(
          channelId: channelId,
          isHeaderSet: headerSet,
        );
      },
    );
  }
}

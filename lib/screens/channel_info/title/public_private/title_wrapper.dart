import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/screens/channel_info/title/public_private/public_private.dart';

class TitleWrapper extends StatefulWidget {
  final String channelId;

  TitleWrapper({required this.channelId});

  @override
  _TitleWrapperState createState() => _TitleWrapperState();
}

class _TitleWrapperState extends State<TitleWrapper> {
  late Stream<String?> purposeStream;

  @override
  void initState() {
    super.initState();
    purposeStream = observeChannelInfo(database, widget.channelId)
        .switchMap((channelInfo) => Stream.value(channelInfo?.purpose));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: purposeStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return PublicPrivate(
          channelId: widget.channelId,
          purpose: snapshot.data,
        );
      },
    );
  }
}

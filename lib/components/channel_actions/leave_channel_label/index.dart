import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/components/channel_actions/leave_channel_label.dart';
import 'package:rxdart/rxdart.dart';

class EnhancedLeaveChannelLabel extends StatefulWidget {
  final String channelId;
  final Database database;

  const EnhancedLeaveChannelLabel({
    Key? key,
    required this.channelId,
    required this.database,
  }) : super(key: key);

  @override
  _EnhancedLeaveChannelLabelState createState() => _EnhancedLeaveChannelLabelState();
}

class _EnhancedLeaveChannelLabelState extends State<EnhancedLeaveChannelLabel> {
  late Stream<bool> canLeaveStream;
  late Stream<String?> displayNameStream;
  late Stream<String?> typeStream;

  @override
  void initState() {
    super.initState();

    final currentUserStream = observeCurrentUser(widget.database);
    final channelStream = observeChannel(widget.database, widget.channelId);

    canLeaveStream = Rx.combineLatest2(
      channelStream,
      currentUserStream,
      (channel, user) {
        final isDefaultChannel = channel?.name == General.DEFAULT_CHANNEL;
        return !isDefaultChannel || (isDefaultChannel && user?.isGuest == true);
      },
    );

    displayNameStream = channelStream.map((channel) => channel?.displayName);
    typeStream = channelStream.map((channel) => channel?.type);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: CombineLatestStream.combine3(
        canLeaveStream,
        displayNameStream,
        typeStream,
        (bool canLeave, String? displayName, String? type) {
          return {'canLeave': canLeave, 'displayName': displayName, 'type': type};
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active && snapshot.hasData) {
          final data = snapshot.data!;
          return LeaveChannelLabel(
            canLeave: data['canLeave'],
            displayName: data['displayName'],
            type: data['type'],
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

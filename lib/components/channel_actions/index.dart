import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/channel.dart';
import 'package:mattermost_flutter/queries/role.dart';
import 'package:mattermost_flutter/queries/user.dart';
import 'package:mattermost_flutter/components/channel_actions.dart';
import 'package:rxdart/rxdart.dart';

class EnhancedChannelActions extends StatefulWidget {
  final String channelId;
  final Database database;

  const EnhancedChannelActions({
    Key? key,
    required this.channelId,
    required this.database,
  }) : super(key: key);

  @override
  _EnhancedChannelActionsState createState() => _EnhancedChannelActionsState();
}

class _EnhancedChannelActionsState extends State<EnhancedChannelActions> {
  late Stream<String?> channelTypeStream;
  late Stream<bool> canManageMembersStream;

  @override
  void initState() {
    super.initState();

    channelTypeStream = observeChannel(widget.database, widget.channelId)
        .switchMap((channel) => Stream.value(channel?.type));

    canManageMembersStream = observeCurrentUser(widget.database).switchMap(
      (user) {
        if (user != null) {
          return observeCanManageChannelMembers(
              widget.database, widget.channelId, user);
        } else {
          return Stream.value(false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: CombineLatestStream.combine2(
        channelTypeStream,
        canManageMembersStream,
        (String? channelType, bool canManageMembers) {
          return {'channelType': channelType, 'canManageMembers': canManageMembers};
        },
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active &&
            snapshot.hasData) {
          final data = snapshot.data!;
          return ChannelActions(
            channelType: data['channelType'],
            canManageMembers: data['canManageMembers'],
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

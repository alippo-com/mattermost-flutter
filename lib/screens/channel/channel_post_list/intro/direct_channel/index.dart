import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/features.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/user.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/intro/direct_channel/direct_channel.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';

class EnhancedDirectChannel extends StatelessWidget {
  final ChannelModel channel;

  const EnhancedDirectChannel({Key? key, required this.channel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final currentUserIdStream = observeCurrentUserId(database);
    final membersStream = observeChannelMembers(database, channel.id);
    final hasGMasDMFeatureStream = observeHasGMasDMFeature(database);
    final channelNotifyPropsStream = observeNotifyPropsByChannels(database, [channel]).switchMap((v) {
      return Stream.value(v[channel.id]);
    });
    final userNotifyPropsStream = observeCurrentUser(database).switchMap((v) {
      return Stream.value(v?.notifyProps);
    });

    Stream<bool> isBotStream = Stream.value(false);
    if (channel.type == General.DM_CHANNEL) {
      isBotStream = currentUserIdStream.switchMap((userId) {
        final otherUserId = getUserIdFromChannelName(userId, channel.name);
        return observeUser(database, otherUserId).switchMap(observeIsBot);
      });
    }

    return MultiProvider(
      providers: [
        StreamProvider<String>(create: (_) => currentUserIdStream, initialData: ),
        StreamProvider<bool>(create: (_) => isBotStream, initialData: false),
        StreamProvider<dynamic>(create: (_) => membersStream, initialData: null),
        StreamProvider<bool>(create: (_) => hasGMasDMFeatureStream, initialData: false),
        StreamProvider<dynamic>(create: (_) => channelNotifyPropsStream, initialData: null),
        StreamProvider<dynamic>(create: (_) => userNotifyPropsStream, initialData: null),
      ],
      child: DirectChannel(channel: channel),
    );
  }
}

Stream<bool> observeIsBot(UserModel? user) => Stream.value(user?.isBot ?? false);

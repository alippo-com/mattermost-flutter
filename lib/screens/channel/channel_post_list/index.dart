import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/post.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/screens/channel/channel_post_list/channel_post_list.dart';

class EnhancedChannelPostList extends StatelessWidget {
  final String channelId;

  const EnhancedChannelPostList({Key? key, required this.channelId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final isCRTEnabledStream = observeIsCRTEnabled(database);
    final postsInChannelStream = queryPostsInChannel(database, channelId).observeWithColumns(['earliest', 'latest']);

    final combinedStream = CombineLatestStream.combine2(
      isCRTEnabledStream,
      postsInChannelStream,
      (isCRTEnabled, postsInChannel) {
        if (postsInChannel.isEmpty) {
          return Stream.value([]);
        }
        final earliest = postsInChannel[0]['earliest'];
        final latest = postsInChannel[0]['latest'];
        return queryPostsBetween(database, earliest, latest, Q.desc, '', channelId, isCRTEnabled ? '' : null).observe();
      },
    );

    final lastViewedAtStream = observeMyChannel(database, channelId).switchMap((myChannel) {
      return Stream.value(myChannel?.viewedAt);
    }).distinct();

    final shouldShowJoinLeaveMessagesStream = queryAdvanceSettingsPreferences(database, Preferences.ADVANCED_FILTER_JOIN_LEAVE)
        .observeWithColumns(['value'])
        .switchMap((preferences) {
      return Stream.value(getAdvanceSettingPreferenceAsBool(preferences, Preferences.ADVANCED_FILTER_JOIN_LEAVE, true));
    }).distinct();

    return MultiProvider(
      providers: [
        StreamProvider<bool>(create: (_) => isCRTEnabledStream, initialData: false),
        StreamProvider<DateTime?>(create: (_) => lastViewedAtStream, initialData: null),
        StreamProvider<List<Map<String, dynamic>>>(create: (_) => combinedStream, initialData: []),
        StreamProvider<bool>(create: (_) => shouldShowJoinLeaveMessagesStream, initialData: true),
      ],
      child: ChannelPostList(channelId: channelId),
    );
  }
}

import 'package:nozbe_watermelondb/database.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/types/models/servers/channel.dart';
import 'package:mattermost_flutter/types/models/servers/my_channel.dart';

class MM_TABLES {
  static const SERVER = {
    'CHANNEL': 'channel',
    'MY_CHANNEL': 'my_channel',
  };
}

Stream<List<ChannelModel>> retrieveChannels(
    Database database, List<MyChannelModel> myChannels, {bool orderedByLastViewedAt = false}) {
  final ids = myChannels.map((m) => m.id).toList();
  if (ids.isNotEmpty) {
    final idsStr = "'${ids.join("','")}'";
    final order = orderedByLastViewedAt ? 'ORDER BY my.last_viewed_at DESC' : '';
    return database.collections
        .get<ChannelModel>(MM_TABLES.SERVER['CHANNEL']!)
        .query(
          Q.unsafeSqlQuery(
            '''SELECT DISTINCT c.* FROM ${MM_TABLES.SERVER['MY_CHANNEL']} my
            INNER JOIN ${MM_TABLES.SERVER['CHANNEL']} c ON c.id=my.id AND c.id IN ($idsStr)
            $order''',
          ),
        )
        .observe();
  }

  return Stream.value([]);
}

List<ChannelModel> removeChannelsFromArchivedTeams(
    List<ChannelModel> recentChannels, Set<String> teamIds) {
  return recentChannels.where((channel) {
    if (channel.teamId == null) {
      return true;
    }
    return teamIds.contains(channel.teamId);
  }).toList();
}

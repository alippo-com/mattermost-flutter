// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/team.dart';
import 'package:mattermost_flutter/queries/servers/thread.dart';
import 'package:mattermost_flutter/types/channel_notify_props.dart';

class MyChannelModel {
  // Define MyChannelModel properties and methods as needed
}

class UnreadObserverArgs {
  final List<MyChannelModel> myChannels;
  final Map<String, ChannelNotifyProps>? settings;
  final bool? threadUnreads;
  final int threadMentionCount;

  UnreadObserverArgs({
    required this.myChannels,
    this.settings,
    this.threadUnreads,
    required this.threadMentionCount,
  });
}

typedef ServerUnreadObserver = void Function(String serverUrl, UnreadObserverArgs args);
typedef UnreadObserver = void Function(UnreadObserverArgs args);

StreamSubscription? subscribeServerUnreadAndMentions(String serverUrl, UnreadObserver observer) {
  final server = DatabaseManager.serverDatabases[serverUrl];
  StreamSubscription? subscription;

  if (server?.database != null) {
    final database = server!.database;

    subscription = database.query('MY_CHANNEL', where: 'delete_at = 0').asStream()
        .combineLatest(
      observeAllMyChannelNotifyProps(database).asStream(),
          (myChannels, settings) => [myChannels, settings],
    )
        .combineLatest(
      observeUnreadsAndMentionsInTeam(database, null, true).asStream(),
          ([myChannels, settings], {unreads, mentions}) => UnreadObserverArgs(
        myChannels: myChannels,
        settings: settings,
        threadUnreads: unreads,
        threadMentionCount: mentions,
      ),
    )
        .listen(observer);
  }

  return subscription;
}

StreamSubscription? subscribeMentionsByServer(String serverUrl, ServerUnreadObserver observer) {
  final server = DatabaseManager.serverDatabases[serverUrl];
  StreamSubscription? subscription;

  if (server?.database != null) {
    final database = server!.database;

    subscription = database.query('MY_CHANNEL', where: 'delete_at = 0').asStream()
        .combineLatest(
      observeThreadMentionCount(database, null, true).asStream(),
          (myChannels, threadMentionCount) => UnreadObserverArgs(
        myChannels: myChannels,
        threadMentionCount: threadMentionCount,
      ),
    )
        .listen((args) => observer(serverUrl, args));
  }

  return subscription;
}

StreamSubscription? subscribeUnreadAndMentionsByServer(String serverUrl, ServerUnreadObserver observer) {
  final server = DatabaseManager.serverDatabases[serverUrl];
  StreamSubscription? subscription;

  if (server?.database != null) {
    final database = server!.database;

    subscription = database.query('MY_CHANNEL', where: 'delete_at = 0').asStream()
        .combineLatest(
      observeAllMyChannelNotifyProps(database).asStream(),
          (myChannels, settings) => [myChannels, settings],
    )
        .combineLatest(
      observeUnreadsAndMentionsInTeam(database, null, true).asStream(),
          ([myChannels, settings], {unreads, mentions}) => UnreadObserverArgs(
        myChannels: myChannels,
        settings: settings,
        threadUnreads: unreads,
        threadMentionCount: mentions,
      ),
    )
        .listen((args) => observer(serverUrl, args));
  }

  return subscription;
}

Future<int> getTotalMentionsForServer(String serverUrl) async {
  final server = DatabaseManager.serverDatabases[serverUrl];
  int count = 0;

  if (server?.database != null) {
    final database = server!.database;

    final myChannels = await database.query('MY_CHANNEL', where: 'delete_at = 0 AND mentions_count > 0').toList();
    for (final mc in myChannels) {
      count += mc['mentions_count'];
    }

    final isCRTEnabled = await getIsCRTEnabled(database);
    if (isCRTEnabled) {
      bool includeDmGm = true;
      final myTeamIds = await queryMyTeams(database).fetchIds();
      for (final teamId in myTeamIds) {
        final threads = await queryThreads(database, teamId, false, includeDmGm)
            .where('unread_mentions > 0')
            .toList();
        includeDmGm = false;
        for (final t in threads) {
          count += t['unread_mentions'];
        }
      }
    }
  }

  return count;
}
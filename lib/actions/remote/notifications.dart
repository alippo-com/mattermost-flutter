
import 'dart:io';

import 'package:mattermost_flutter/actions/local/category.dart';
import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/actions/local/post.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/actions/remote/team.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/notification.dart';
import 'package:mattermost_flutter/utils/post.dart';

Future<Map<String, dynamic>> fetchNotificationData(String serverUrl, Map<String, dynamic> notification, {bool skipEvents = false}) async {
  final channelId = notification['payload']?['channel_id'];

  if (channelId == null) {
    return {'error': 'No channel Id was specified'};
  }

  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final currentTeamId = await getCurrentTeamId(database);
    var teamId = notification['payload']?['team_id'];
    var isDirectChannel = false;

    if (teamId == null) {
      isDirectChannel = true;
      teamId = currentTeamId;
    }

    final myChannel = await getMyChannel(database, channelId);
    final myTeam = await getMyTeamById(database, teamId);

    if (myTeam == null) {
      final teamsReq = await fetchMyTeam(serverUrl, teamId, false);
      if (teamsReq.error || teamsReq.memberships?.isEmpty == true) {
        if (!skipEvents) {
          emitNotificationError('Team');
        }
        return {'error': teamsReq.error ?? 'Team'};
      }
    }

    if (myChannel == null) {
      final channelReq = await fetchMyChannel(serverUrl, teamId, channelId);
      if (channelReq.error ||
          channelReq.channels?.any((c) => c.id == channelId && c.deleteAt == 0) != true ||
          channelReq.memberships?.any((m) => m.channelId == channelId) != true) {
        if (!skipEvents) {
          emitNotificationError('Channel');
        }
        return {'error': channelReq.error ?? 'Channel'};
      }

      if (isDirectChannel) {
        final channel = await getChannelById(database, channelId);
        if (channel != null) {
          fetchDirectChannelsInfo(serverUrl, [channel]);
        }
      }
    }

    if (Platform.isAndroid) {
      final isCRTEnabled = await getIsCRTEnabled(database);
      final isThreadNotification = isCRTEnabled && notification['payload']?['root_id'] != null;
      if (isThreadNotification) {
        fetchPostThread(serverUrl, notification['payload']!['root_id']!);
      } else {
        fetchPostsForChannel(serverUrl, channelId);
      }
    }
    return {};
  } catch (error) {
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error.toString()};
  }
}

Future<void> backgroundNotification(String serverUrl, Map<String, dynamic> notification) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final channelId = notification['payload']?['channel_id'];
    var teamId = notification['payload']?['team_id'];
    if (channelId == null) {
      throw Exception('No channel Id was specified');
    }

    if (teamId == null) {
      final currentTeamId = await getCurrentTeamId(database);
      teamId = currentTeamId;
    }
    if (notification['payload']?['data'] != null) {
      final data = notification['payload']!['data'];
      final isCRTEnabled = notification['payload']?['isCRTEnabled'] == true;
      final channel = data['channel'];
      final myChannel = data['myChannel'];
      final team = data['team'];
      final myTeam = data['myTeam'];
      final posts = data['posts'];
      final users = data['users'];
      final threads = data['threads'];
      final List<dynamic> models = [];

      if (posts != null) {
        final postsData = processPostsFetched(posts);
        final isThreadNotification = isCRTEnabled && notification['payload']?['root_id'] != null;
        final actionType = isThreadNotification ? ActionType.POSTS.RECEIVED_IN_THREAD : ActionType.POSTS.RECEIVED_IN_CHANNEL;

        if (team != null || myTeam != null) {
          final teamPromises = prepareMyTeams(DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator, team != null ? [team] : [], myTeam != null ? [myTeam] : []);
          if (teamPromises.isNotEmpty) {
            final teamModels = await Future.wait(teamPromises);
            models.addAll(teamModels.expand((element) => element));
          }
        }

        await storeMyChannelsForTeam(
          serverUrl,
          teamId,
          channel != null ? [channel] : [],
          myChannel != null ? [myChannel] : [],
          false,
          isCRTEnabled,
        );

        if (data['categoryChannels']?.isNotEmpty == true && channel != null) {
          final categoryModels = await addChannelToDefaultCategory(serverUrl, channel, true);
          if (categoryModels.isNotEmpty) {
            models.addAll(categoryModels);
          }
        } else if (data['categories']?.categories != null) {
          final categoryModels = await storeCategories(serverUrl, data['categories']['categories'], false, true);
          if (categoryModels.isNotEmpty) {
            models.addAll(categoryModels);
          }
        }

        await storePostsForChannel(
          serverUrl,
          channelId,
          postsData.posts,
          postsData.order,
          postsData.previousPostId ?? '',
          actionType,
          users ?? [],
        );

        if (isThreadNotification && threads?.isNotEmpty == true) {
          final threadModels = await DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator.handleThreads(
            threads: threads.map((t) => {...t, 'lastFetchedAt': [t['post']['create_at'], t['post']['update_at'], t['post']['delete_at']].reduce((a, b) => a > b ? a : b)}).toList(),
            teamId,
            prepareRecordsOnly: true,
          );

          if (threadModels.isNotEmpty) {
            models.addAll(threadModels);
          }
        }
      }

      if (models.isNotEmpty) {
        await DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator.batchRecords(models, 'backgroundNotification');
      }
    }
  } catch (error) {
    logWarning('backgroundNotification', error);
  }
}

Future<Map<String, dynamic>> openNotification(String serverUrl, Map<String, dynamic> notification) async {
  await Future.delayed(Duration(milliseconds: 500));

  if (EphemeralStore.getProcessingNotification() == notification['identifier']) {
    return {};
  }

  EphemeralStore.setNotificationTapped(true);

  final channelId = notification['payload']!['channel_id']!;
  final rootId = notification['payload']!['root_id']!;
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final isCRTEnabled = await getIsCRTEnabled(database);
    final isThreadNotification = isCRTEnabled && rootId != null;

    final currentTeamId = await getCurrentTeamId(database);
    final currentServerUrl = await DatabaseManager.getActiveServerUrl();
    var teamId = notification['payload']?['team_id'];

    if (teamId == null) {
      teamId = currentTeamId;
    }

    if (currentServerUrl != serverUrl) {
      await DatabaseManager.setActiveServerDatabase(serverUrl);
    }

    final myChannel = await getMyChannel(database, channelId);
    final myTeam = await getMyTeamById(database, teamId);

    if (myChannel != null && myTeam != null) {
      if (isThreadNotification) {
        return await fetchAndSwitchToThread(serverUrl, rootId, true);
      }
      return await switchToChannelById(serverUrl, channelId, teamId);
    }

    final result = await fetchNotificationData(serverUrl, notification);
    if (result['error'] != null) {
      return {'error': result['error']};
    }

    if (isThreadNotification) {
      return await fetchAndSwitchToThread(serverUrl, rootId, true);
    }
    return await switchToChannelById(serverUrl, channelId, teamId);
  } catch (error) {
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error.toString()};
  }
}

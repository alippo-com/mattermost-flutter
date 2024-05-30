import 'package:sqflite/sqflite.dart';
import 'package:your_project/actions/local/thread.dart';
import 'package:your_project/actions/remote/post.dart';
import 'package:your_project/constants.dart';
import 'package:your_project/database_manager.dart';
import 'package:your_project/init/push_notifications.dart';
import 'package:your_project/managers/apps_manager.dart';
import 'package:your_project/managers/network_manager.dart';
import 'package:your_project/queries/servers/post.dart';
import 'package:your_project/queries/servers/system.dart';
import 'package:your_project/queries/servers/thread.dart';
import 'package:your_project/queries/servers/user.dart';
import 'package:your_project/utils/errors.dart';
import 'package:your_project/utils/log.dart';
import 'package:your_project/utils/snack_bar.dart';
import 'package:your_project/utils/thread.dart';

import 'session.dart';

enum Direction {
  Up,
  Down,
}

Future<Map<String, dynamic>> fetchAndSwitchToThread(String serverUrl, String rootId, {bool isFromNotification = false}) async {
  final database = DatabaseManager.serverDatabases[serverUrl]?.database;
  if (database == null) {
    return {'error': '$serverUrl database not found'};
  }

  // Load thread before we open the thread modal
  fetchPostThread(serverUrl, rootId);

  // Mark thread as read
  final isCRTEnabled = await getIsCRTEnabled(database);
  if (isCRTEnabled) {
    final post = await getPostById(database, rootId);
    if (post != null) {
      final thread = await getThreadById(database, rootId);
      if (thread?.isFollowing == true) {
        markThreadAsViewed(serverUrl, thread.id);
      }
    }
  }

  await switchToThread(serverUrl, rootId, isFromNotification);

  if (await AppsManager.isAppsEnabled(serverUrl)) {
    // Getting the post again in case we didn't have it at the beginning
    final post = await getPostById(database, rootId);
    final currentChannelId = await getCurrentChannelId(database);

    if (post != null) {
      if (currentChannelId == post.channelId) {
        AppsManager.copyMainBindingsToThread(serverUrl, currentChannelId);
      } else {
        AppsManager.fetchBindings(serverUrl, post.channelId, true);
      }
    }
  }

  return {};
}

Future<Map<String, dynamic>> fetchThread(String serverUrl, String teamId, String threadId, {bool extended = false}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final thread = await client.getThread('me', teamId, threadId, extended);

    await processReceivedThreads(serverUrl, [thread], teamId);

    return {'data': thread};
  } catch (error) {
    logDebug('error on fetchThread', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> updateTeamThreadsAsRead(String serverUrl, String teamId) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final data = await client.updateTeamThreadsAsRead('me', teamId);

    // Update locally
    await markTeamThreadsAsRead(serverUrl, teamId);

    return {'data': data};
  } catch (error) {
    logDebug('error on updateTeamThreadsAsRead', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> markThreadAsRead(String serverUrl, String teamId, String threadId, {bool updateLastViewed = true}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // DM/GM doesn't have a teamId, so we pass the current team id
    var threadTeamId = teamId;
    final data = await client.markThreadAsRead('me', threadTeamId, threadId, timestamp);

    // Update locally
    await updateThread(serverUrl, threadId, {
      'last_viewed_at': updateLastViewed ? timestamp : null,
      'unread_replies': 0,
      'unread_mentions': 0,
    });

    final isCRTEnabled = await getIsCRTEnabled(database);
    final post = await getPostById(database, threadId);
    if (post != null) {
      if (isCRTEnabled) {
        PushNotifications.removeThreadNotifications(serverUrl, threadId);
      } else {
        PushNotifications.removeChannelNotifications(serverUrl, post.channelId);
      }
    }

    return {'data': data};
  } catch (error) {
    logDebug('error on markThreadAsRead', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> markThreadAsUnread(String serverUrl, String teamId, String threadId, String postId) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    // DM/GM doesn't have a teamId, so we pass the current team id
    var threadTeamId = teamId;

    final data = await client.markThreadAsUnread('me', threadTeamId, threadId, postId);

    // Update locally
    final post = await getPostById(database, postId);
    if (post != null) {
      await updateThread(serverUrl, threadId, {
        'last_viewed_at': post.createAt - 1,
        'viewed_at': post.createAt - 1,
      });
    }

    return {'data': data};
  } catch (error) {
    logDebug('error on markThreadAsUnread', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> updateThreadFollowing(String serverUrl, String teamId, String threadId, bool state, bool showSnackBar) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    // DM/GM doesn't have a teamId, so we pass the current team id
    var threadTeamId = teamId;

    final data = await client.updateThreadFollow('me', threadTeamId, threadId, state);

    // Update locally
    await updateThread(serverUrl, threadId, {'is_following': state});

    if (showSnackBar) {
      final onUndo = () => updateThreadFollowing(serverUrl, teamId, threadId, !state, false);
      showThreadFollowingSnackbar(state, onUndo);
    }

    return {'data': data};
  } catch (error) {
    logDebug('error on updateThreadFollowing', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> fetchThreads(
    String serverUrl, String teamId, Map<String, dynamic> options, {Direction direction, int pages}) async {
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    return {'error': '$serverUrl database not found'};
  }
  final database = operator.database;

  var client;
  try {
    client = NetworkManager.getClient(serverUrl);
  } catch (error) {
    return {'error': error};
  }

  final fetchDirection = direction ?? Direction.Up;

  final currentUser = await getCurrentUser(database);
  if (currentUser == null) {
    return {'error': 'currentUser not found'};
  }

  final version = await getConfigValue(database, 'Version');
  final threadsData = <Thread>[];

  var currentPage = 0;
  Future<void> fetchThreadsFunc(Map<String, dynamic> opts) async {
    final before = opts['before'];
    final after = opts['after'];
    final perPage = opts['perPage'] ?? General.CRT_CHUNK_SIZE;
    final deleted = opts['deleted'];
    final unread = opts['unread'];
    final since = opts['since'];

    currentPage++;
    final response = await client.getThreads(currentUser.id, teamId, before, after, perPage, deleted, unread, since, false, version);
    final threads = response['threads'] ?? [];

    if (threads.isNotEmpty) {
      // Mark all fetched threads as following
      for (final thread in threads) {
        thread.isFollowing = thread.isFollowing ?? true;
      }

      threadsData.addAll(threads);

      if (threads.length == perPage && (currentPage < pages)) {
        final newOptions = {
          'perPage': perPage,
          'deleted': deleted,
          'unread': unread,
        };
        if (fetchDirection == Direction.Down) {
          final last = threads.last;
          newOptions['before'] = last.id;
        } else {
          final first = threads.first;
          newOptions['after'] = first.id;
        }
        await fetchThreadsFunc(newOptions);
      }
    }
  }

  try {
    await fetchThreadsFunc(options);
  } catch (error) {
    logDebug('error on fetchThreads', getFullErrorMessage(error));
    if (kDebugMode) {
      throw error;
    }
    return {'error': error};
  }

  return {'error': false, 'threads': threadsData};
}

Future<Map<String, dynamic>> syncTeamThreads(String serverUrl, String teamId, {bool prepareRecordsOnly = false}) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = operator.database;

    final syncData = await getTeamThreadsSyncData(database, teamId);
    final syncDataUpdate = {'id': teamId};

    final threads = <Thread>[];

    // If syncing for the first time,
    // - Get all unread threads to show the right badges
    // - Get latest threads to show by default in the global threads screen
    // Else
    // - Get all threads since last sync
    if (syncData == null || syncData['latest'] == null) {
      final allUnreadThreads = await fetchThreads(serverUrl, teamId, {'unread': true}, direction: Direction.Down);
      final latestThreads = await fetchThreads(serverUrl, teamId, {}, pages: 1);

      if (allUnreadThreads['error'] != null || latestThreads['error'] != null) {
        return {'error': allUnreadThreads['error'] ?? latestThreads['error']};
      }

      if (latestThreads['threads']?.isNotEmpty == true) {
        // We are fetching the threads for the first time. We get "latest" and "earliest" values.
        final edges = getThreadsListEdges(latestThreads['threads']);
        syncDataUpdate['latest'] = edges['latestThread']['last_reply_at'];
        syncDataUpdate['earliest'] = edges['earliestThread']['last_reply_at'];

        threads.addAll(latestThreads['threads']);
      }

      if (allUnreadThreads['threads']?.isNotEmpty == true) {
        threads.addAll(allUnreadThreads['threads']);
      }
    } else {
      final allNewThreads = await fetchThreads(serverUrl, teamId, {'deleted': true, 'since': syncData['latest'] + 1});
      if (allNewThreads['error'] != null) {
        return {'error': allNewThreads['error']};
      }

      if (allNewThreads['threads']?.isNotEmpty == true) {
        // As we are syncing, we get all new threads and we will update the "latest" value.
        final edges = getThreadsListEdges(allNewThreads['threads']);
        syncDataUpdate['latest'] = edges['latestThread']['last_reply_at'];

        threads.addAll(allNewThreads['threads']);
      }
    }

    final models = <Model>[];

    if (threads.isNotEmpty) {
      final result = await processReceivedThreads(serverUrl, threads, teamId, true);
      if (result['error'] != null) {
        return {'error': result['error']};
      }

      models.addAll(result['models'] ?? []);

      if (syncDataUpdate['earliest'] != null || syncDataUpdate['latest'] != null) {
        final updateResult = await updateTeamThreadsSync(serverUrl, syncDataUpdate, true);
        models.addAll(updateResult['models'] ?? []);
      }

      if (!prepareRecordsOnly && models.isNotEmpty) {
        try {
          await operator.batchRecords(models, 'syncTeamThreads');
        } catch (err) {
          if (kDebugMode) {
            throw err;
          }
          return {'error': err};
        }
      }
    }

    return {'error': false, 'models': models};
  } catch (error) {
    return {'error': error};
  }
}

Future<Map<String, dynamic>> loadEarlierThreads(String serverUrl, String teamId, String lastThreadId, {bool prepareRecordsOnly = false}) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);

    // We will fetch one page of old threads and update the sync data with the earliest thread last_reply_at timestamp
    final fetchedThreads = await fetchThreads(serverUrl, teamId, {'before': lastThreadId}, pages: 1);
    if (fetchedThreads['error'] != null) {
      return {'error': fetchedThreads['error']};
    }

    final models = <Model>[];
    final threads = fetchedThreads['threads'] ?? [];

    if (threads.isNotEmpty) {
      final result = await processReceivedThreads(serverUrl, threads, teamId, true);
      if (result['error'] != null) {
        return {'error': result['error']};
      }

      models.addAll(result['models'] ?? []);

      final edges = getThreadsListEdges(threads);
      final syncDataUpdate = {'id': teamId, 'earliest': edges['earliestThread']['last_reply_at']};
      final updateResult = await updateTeamThreadsSync(serverUrl, syncDataUpdate, true);
      models.addAll(updateResult['models'] ?? []);

      if (!prepareRecordsOnly && models.isNotEmpty) {
        try {
          await operator.batchRecords(models, 'loadEarlierThreads');
        } catch (err) {
          if (kDebugMode) {
            throw err;
          }
          return {'error': err};
        }
      }
    }

    return {'models': models, 'threads': threads};
  } catch (error) {
    return {'error': error};
  }
}

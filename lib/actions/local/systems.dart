import 'package:watermelon_db/watermelon_db.dart';
import 'package:deep_equal/deep_equal.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/init/credentials.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/actions/local/post.dart';

import 'package:mattermost_flutter/types/database/models/servers/post.dart';
import 'package:mattermost_flutter/actions/remote/systems.dart';

Future<void> storeConfigAndLicense(String serverUrl, ClientConfig config, ClientLicense license) async {
  try {
    final credentials = await getServerCredentials(serverUrl);
    if (credentials != null) {
      final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
      final currentLicense = await getLicense(dbManager.database);
      final systems = <IdValue>[];

      if (!deepEqual(license, currentLicense)) {
        systems.add(IdValue(
          id: SYSTEM_IDENTIFIERS.LICENSE,
          value: license.toJson(),
        ));
      }

      if (systems.isNotEmpty) {
        await dbManager.operator.handleSystem(systems: systems, prepareRecordsOnly: false);
      }

      await storeConfig(serverUrl, config);
    }
  } catch (error) {
    logError('An error occurred while saving config & license', error);
  }
}

Future<void> storeConfig(String serverUrl, ClientConfig? config, {bool prepareRecordsOnly = false}) async {
  if (config == null) {
    return;
  }

  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final currentConfig = await getConfig(dbManager.database);
    final configsToUpdate = <IdValue>[];
    final configsToDelete = <IdValue>[];

    for (final key in config.keys) {
      if (currentConfig[key] != config[key]) {
        configsToUpdate.add(IdValue(id: key, value: config[key]));
      }
    }

    for (final key in currentConfig.keys) {
      if (config[key] == null) {
        configsToDelete.add(IdValue(id: key, value: currentConfig[key]));
      }
    }

    if (configsToDelete.isNotEmpty || configsToUpdate.isNotEmpty) {
      await dbManager.operator.handleConfigs(
        configs: configsToUpdate,
        configsToDelete: configsToDelete,
        prepareRecordsOnly: prepareRecordsOnly,
      );
    }
  } catch (error) {
    logError('storeConfig', error);
  }
}

Future<void> storeDataRetentionPolicies(String serverUrl, DataRetentionPoliciesRequest data, {bool prepareRecordsOnly = false}) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final systems = <IdValue>[
      IdValue(id: SYSTEM_IDENTIFIERS.DATA_RETENTION_POLICIES, value: data.globalPolicy ?? {}),
      IdValue(id: SYSTEM_IDENTIFIERS.GRANULAR_DATA_RETENTION_POLICIES, value: {
        'team': data.teamPolicies ?? [],
        'channel': data.channelPolicies ?? [],
      })
    ];

    await dbManager.operator.handleSystem(systems: systems, prepareRecordsOnly: prepareRecordsOnly);
  } catch {
    return;
  }
}

Future<void> updateLastDataRetentionRun(String serverUrl, {int? value, bool prepareRecordsOnly = false}) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final systems = <IdValue>[
      IdValue(id: SYSTEM_IDENTIFIERS.LAST_DATA_RETENTION_RUN, value: value ?? DateTime.now().millisecondsSinceEpoch)
    ];

    await dbManager.operator.handleSystem(systems: systems, prepareRecordsOnly: prepareRecordsOnly);
  } catch (error) {
    logError('Failed updateLastDataRetentionRun', error);
  }
}

Future<void> dataRetentionCleanup(String serverUrl) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final lastRunAt = await getLastGlobalDataRetentionRun(dbManager.database);
    final lastCleanedToday = DateTime.fromMillisecondsSinceEpoch(lastRunAt).toIso8601String().split('T').first == DateTime.now().toIso8601String().split('T').first;

    if (lastRunAt != null && lastCleanedToday) {
      return;
    }

    final isDataRetentionEnabled = await getIsDataRetentionEnabled(dbManager.database);
    final result = isDataRetentionEnabled ? await dataRetentionPolicyCleanup(serverUrl) : await dataRetentionWithoutPolicyCleanup(serverUrl);

    if (result == null) {
      await updateLastDataRetentionRun(serverUrl);
    }

    await dbManager.database.unsafeVacuum();
  } catch (error) {
    logError('An error occurred while performing data retention cleanup', error);
  }
}

Future<void> dataRetentionPolicyCleanup(String serverUrl) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final globalPolicy = await getGlobalDataRetentionPolicy(dbManager.database);
    final granularPoliciesData = await getGranularDataRetentionPolicies(dbManager.database);

    var globalRetentionCutoff = 0;
    if (globalPolicy?.messageDeletionEnabled == true) {
      globalRetentionCutoff = globalPolicy.messageRetentionCutoff;
    }

    var teamPolicies = <TeamDataRetentionPolicy>[];
    var channelPolicies = <ChannelDataRetentionPolicy>[];
    if (granularPoliciesData != null) {
      teamPolicies = granularPoliciesData.team;
      channelPolicies = granularPoliciesData.channel;
    }

    final channelsCutoffs = <String, int>{};

    for (final teamPolicy in teamPolicies) {
      final channelIds = await queryAllChannelsForTeam(dbManager.database, teamPolicy.teamId).fetchIds();
      if (channelIds.isNotEmpty) {
        final cutoff = getDataRetentionPolicyCutoff(teamPolicy.postDuration);
        for (final channelId in channelIds) {
          channelsCutoffs[channelId] = cutoff;
        }
      }
    }

    for (final channelPolicy in channelPolicies) {
      channelsCutoffs[channelPolicy.channelId] = getDataRetentionPolicyCutoff(channelPolicy.postDuration);
    }

    final conditions = <String>[];
    final channelIds = channelsCutoffs.keys.toList();
    if (channelIds.isNotEmpty) {
      for (final channelId in channelIds) {
        final cutoff = channelsCutoffs[channelId];
        conditions.add('(channel_id='$channelId' AND create_at < $cutoff)');
      }
      conditions.add('(channel_id NOT IN ('${channelIds.join(,)}') AND create_at < $globalRetentionCutoff)');
    } else {
      conditions.add('create_at < $globalRetentionCutoff');
    }

    final postIds = await dbManager.database.get<PostModel>(POST).query(
      Q.unsafeSqlQuery('SELECT * FROM $POST where ${conditions.join(' OR ')}')
    ).fetchIds();

    await dataRetentionCleanPosts(serverUrl, postIds);
  } catch (error) {
    logError('An error occurred while performing data retention policy cleanup', error);
  }
}

Future<void> dataRetentionWithoutPolicyCleanup(String serverUrl) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final cutoff = getDataRetentionPolicyCutoff(14);

    final postIds = await dbManager.database.get<PostModel>(POST).query(
      Q.where('create_at', Q.lt(cutoff))
    ).fetchIds();

    await dataRetentionCleanPosts(serverUrl, postIds);
  } catch (error) {
    logError('An error occurred while performing data retention without policy cleanup', error);
  }
}

Future<void> dataRetentionCleanPosts(String serverUrl, List<String> postIds) async {
  if (postIds.isNotEmpty) {
    const batchSize = 1000;
    final deletePromises = <Future>[];
    for (var i = 0; i < postIds.length; i += batchSize) {
      final batch = postIds.sublist(i, i + batchSize);
      deletePromises.add(deletePosts(serverUrl, batch));
    }

    final deleteResult = await Future.wait(deletePromises);
    for (final result in deleteResult) {
      if (result.error != null) {
        return;
      }
    }
  }
}

int getDataRetentionPolicyCutoff(int postDuration) {
  final periodDate = DateTime.now().subtract(Duration(days: postDuration));
  return DateTime(periodDate.year, periodDate.month, periodDate.day).millisecondsSinceEpoch;
}

Future<void> setLastServerVersionCheck(String serverUrl, {bool reset = false}) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    await dbManager.operator.handleSystem(systems: [
      IdValue(id: SYSTEM_IDENTIFIERS.LAST_SERVER_VERSION_CHECK, value: reset ? 0 : DateTime.now().millisecondsSinceEpoch)
    ], prepareRecordsOnly: false);
  } catch (error) {
    logError('setLastServerVersionCheck', error);
  }
}

Future<void> setGlobalThreadsTab(String serverUrl, GlobalThreadsTab globalThreadsTab) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    await dbManager.operator.handleSystem(systems: [
      IdValue(id: SYSTEM_IDENTIFIERS.GLOBAL_THREADS_TAB, value: globalThreadsTab)
    ], prepareRecordsOnly: false);
  } catch (error) {
    logError('setGlobalThreadsTab', error);
  }
}

Future<void> dismissAnnouncement(String serverUrl, String announcementText) async {
  try {
    final dbManager = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    await dbManager.operator.handleSystem(systems: [
      IdValue(id: SYSTEM_IDENTIFIERS.LAST_DISMISSED_BANNER, value: announcementText)
    ], prepareRecordsOnly: false);
  } catch (error) {
    logError('An error occurred while dismissing an announcement', error);
  }
}

import 'package:mattermost_flutter/actions/local/category.dart';
import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/actions/local/post.dart';
import 'package:mattermost_flutter/actions/remote/channel.dart';
import 'package:mattermost_flutter/actions/remote/post.dart';
import 'package:mattermost_flutter/actions/remote/role.dart';
import 'package:mattermost_flutter/actions/remote/user.dart';
import 'package:mattermost_flutter/calls/actions/calls.dart';
import 'package:mattermost_flutter/calls/errors.dart';
import 'package:mattermost_flutter/calls/state.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/store/ephemeral_store.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_channel.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:sqflite/sqflite.dart'; // Using sqflite for database operations

// Received when current user created a channel in a different client
Future<void> handleChannelCreatedEvent(String serverUrl, dynamic msg) async {
  final String teamId = msg['data']['team_id'];
  final String channelId = msg['data']['channel_id'];

  if (EphemeralStore.creatingChannel) {
    return; // We probably don't need to handle this WS because we provoked it
  }

  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final channel = await getChannelById(database, channelId);
    if (channel != null) {
      return; // We already have this channel
    }

    final models = <Model>[];
    final response = await fetchMyChannel(serverUrl, teamId, channelId, true);
    final channels = response.channels;
    final memberships = response.memberships;

    if (channels != null && memberships != null) {
      final prepare = await prepareMyChannelsForTeam(operator, teamId, channels, memberships);
      if (prepare.isNotEmpty) {
        final prepareModels = await Future.wait(prepare);
        final flattenedModels = prepareModels.expand((x) => x).toList();
        if (flattenedModels.isNotEmpty) {
          models.addAll(flattenedModels);
        }
        final categoryModels = await addChannelToDefaultCategory(serverUrl, channels[0], true);
        if (categoryModels.models.isNotEmpty) {
          models.addAll(categoryModels.models);
        }
      }
    }
    operator.batchRecords(models, 'handleChannelCreatedEvent');
  } catch (e) {
    // do nothing
  }
}

Future<void> handleChannelUnarchiveEvent(String serverUrl, dynamic msg) async {
  try {
    if (EphemeralStore.isArchivingChannel(msg['data']['channel_id'])) {
      return;
    }

    await setChannelDeleteAt(serverUrl, msg['data']['channel_id'], 0);
  } catch (e) {
    // do nothing
  }
}

Future<void> handleChannelConvertedEvent(String serverUrl, dynamic msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final String channelId = msg['data']['channel_id'];

    if (EphemeralStore.isConvertingChannel(channelId)) {
      return;
    }

    final response = await fetchChannelById(serverUrl, channelId);
    final channel = response.channel;
    if (channel != null) {
      operator.handleChannel(channels: [channel], prepareRecordsOnly: false);
    }
  } catch (e) {
    // do nothing
  }
}

Future<void> handleChannelUpdatedEvent(String serverUrl, dynamic msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final Map<String, dynamic> updatedChannel = msg['data']['channel'];

    if (EphemeralStore.isConvertingChannel(updatedChannel['id'])) {
      return;
    }

    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final existingChannel = await getChannelById(database, updatedChannel['id']);
    final existingChannelType = existingChannel?.type;

    final models = await operator.handleChannel(channels: [updatedChannel], prepareRecordsOnly: true);
    final infoModel = await updateChannelInfoFromChannel(serverUrl, updatedChannel, true);
    if (infoModel.model != null) {
      models.add(infoModel.model);
    }
    operator.batchRecords(models, 'handleChannelUpdatedEvent');

    // This indicates a GM was converted to a private channel
    if (existingChannelType == General.GM_CHANNEL && updatedChannel['type'] == General.PRIVATE_CHANNEL) {
      await handleConvertedGMCategories(serverUrl, updatedChannel['id'], updatedChannel['team_id']);

      final currentChannelId = await getCurrentChannelId(database);
      final currentTeamId = await getCurrentTeamId(database);

      // Making sure user is in the correct team
      if (currentChannelId == updatedChannel['id'] && currentTeamId != updatedChannel['team_id']) {
        await setCurrentTeamId(operator, updatedChannel['team_id']);
      }
    }
  } catch (e) {
    // Do nothing
  }
}

Future<void> handleChannelViewedEvent(String serverUrl, dynamic msg) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final String channelId = msg['data']['channel_id'];
    final activeServerUrl = await DatabaseManager.getActiveServerUrl();
    final currentChannelId = await getCurrentChannelId(database);

    if (activeServerUrl != serverUrl || (currentChannelId != channelId && !EphemeralStore.isSwitchingToChannel(channelId))) {
      await markChannelAsViewed(serverUrl, channelId);
    }
  } catch (e) {
    // do nothing
  }
}

Future<void> handleMultipleChannelsViewedEvent(String serverUrl, dynamic msg) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final channelTimes = msg['data']['channel_times'];
    final activeServerUrl = await DatabaseManager.getActiveServerUrl();
    final currentChannelId = await getCurrentChannelId(database);

    final promises = <Future<void>>[];
    for (final id in channelTimes.keys) {
      if (activeServerUrl == serverUrl && (currentChannelId == id || EphemeralStore.isSwitchingToChannel(id))) {
        continue;
      }
      promises.add(markChannelAsViewed(serverUrl, id, false, true));
    }

    final results = await Future.wait(promises);
    final members = results.whereType<MyChannelModel>().toList();

    if (members.isNotEmpty) {
      operator.batchRecords(members, 'handleMultipleCahnnelViewedEvent');
    }
  } catch (e) {
    // do nothing
  }
}

// This event is triggered by changes in the notify props or in the roles.
Future<void> handleChannelMemberUpdatedEvent(String serverUrl, dynamic msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final models = <Model>[];

    final updatedChannelMember = msg['data']['channelMember'];
    updatedChannelMember['id'] = updatedChannelMember['channel_id'];

    final myMemberModel = await updateMyChannelFromWebsocket(serverUrl, updatedChannelMember, true);
    if (myMemberModel.model != null) {
      models.add(myMemberModel.model);
    }
    models.addAll(await operator.handleMyChannelSettings(settings: [updatedChannelMember], prepareRecordsOnly: true));
    models.addAll(await operator.handleChannelMembership(channelMemberships: [updatedChannelMember], prepareRecordsOnly: true));

    final rolesRequest = await fetchRolesIfNeeded(serverUrl, updatedChannelMember['roles'].split(','), true);
    if (rolesRequest.roles.isNotEmpty) {
      models.addAll(await operator.handleRole(roles: rolesRequest.roles, prepareRecordsOnly: true));
    }
    operator.batchRecords(models, 'handleChannelMemberUpdatedEvent');
  } catch (e) {
    // do nothing
  }
}

Future<void> handleDirectAddedEvent(String serverUrl, dynamic msg) async {
  if (EphemeralStore.creatingDMorGMTeammates.isNotEmpty) {
    List<String>? userList;
    if (msg['data'].containsKey('teammate_ids')) { // GM
      try {
        userList = List<String>.from(msg['data']['teammate_ids']);
      } catch (e) {
        // Do nothing
      }
    } else if (msg['data'].containsKey('teammate_id')) { // DM
      userList = [msg['data']['teammate_id']];
    }
    if (userList != null && userList.length == EphemeralStore.creatingDMorGMTeammates.length) {
      final usersSet = userList.toSet();
      if (EphemeralStore.creatingDMorGMTeammates.every(usersSet.contains)) {
        return; // We are adding this channel
      }
    }
  }

  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final String channelId = msg['broadcast']['channel_id'];
    final channel = await getChannelById(database, channelId);
    if (channel != null) {
      return; // We already have this channel
    }

    final response = await fetchMyChannel(serverUrl, '', channelId, true);
    final channels = response.channels;
    final memberships = response.memberships;
    if (channels == null || memberships == null) {
      return;
    }
    final user = await getCurrentUser(database);
    if (user == null) {
      return;
    }

    final teammateDisplayNameSetting = await getTeammateNameDisplay(database);
    final directChannelsResponse = await fetchMissingDirectChannelsInfo(serverUrl, channels, user.locale, teammateDisplayNameSetting, user.id, true);
    final directChannels = directChannelsResponse.directChannels;
    final users = directChannelsResponse.users;
    if (directChannels.isEmpty) {
      return;
    }

    final models = <Model>[];
    final channelModels = await storeMyChannelsForTeam(serverUrl, '', directChannels, memberships, true);
    if (channelModels.models.isNotEmpty) {
      models.addAll(channelModels.models);
    }
    final categoryModels = await addChannelToDefaultCategory(serverUrl, channels[0], true);
    if (categoryModels.models.isNotEmpty) {
      models.addAll(categoryModels.models);
    }

    if (users.isNotEmpty) {
      final userModels = await operator.handleUsers(users: users, prepareRecordsOnly: true);
      models.addAll(userModels);
    }

    operator.batchRecords(models, 'handleDirectAddedEvent');
  } catch (e) {
    // do nothing
  }
}

Future<void> handleUserAddedToChannelEvent(String serverUrl, dynamic msg) async {
  final String userId = msg['data']['user_id'] ?? msg['broadcast']['userId'];
  final String channelId = msg['data']['channel_id'] ?? msg['broadcast']['channel_id'];
  final String teamId = msg['data']['team_id'];

  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final currentUser = await getCurrentUser(database);
    final models = <Model>[];

    if (userId == currentUser?.id) {
      if (EphemeralStore.isAddingToTeam(teamId) || EphemeralStore.isJoiningChannel(channelId)) {
        return;
      }

      final response = await fetchMyChannel(serverUrl, teamId, channelId, true);
      final channels = response.channels;
      final memberships = response.memberships;
      if (channels != null && memberships != null) {
        final prepare = await prepareMyChannelsForTeam(operator, teamId, channels, memberships);
        if (prepare.isNotEmpty) {
          final prepareModels = await Future.wait(prepare);
          final flattenedModels = prepareModels.expand((x) => x).toList();
          if (flattenedModels.isNotEmpty) {
            await operator.batchRecords(flattenedModels, 'handleUserAddedToChannelEvent - prepareMyChannelsForTeam');
          }
        }

        final categoriesModels = await addChannelToDefaultCategory(serverUrl, channels[0], true);
        if (categoriesModels.models.isNotEmpty) {
          models.addAll(categoriesModels.models);
        }
      }

      final postsResponse = await fetchPostsForChannel(serverUrl, channelId, true);
      final posts = postsResponse.posts;
      final order = postsResponse.order;
      final authors = postsResponse.authors;
      final actionType = postsResponse.actionType;
      final previousPostId = postsResponse.previousPostId;
      if (posts.isNotEmpty && order.isNotEmpty) {
        final prepared = await storePostsForChannel(
          serverUrl, channelId,
          posts, order, previousPostId ?? '',
          actionType, authors, true,
        );

        if (prepared.models.isNotEmpty) {
          models.addAll(prepared.models);
        }
      }

      loadCallForChannel(serverUrl, channelId);
    } else {
      final addedUser = await getUserById(database, userId);
      if (addedUser == null) {
        final usersResponse = await fetchUsersByIds(serverUrl, [userId], true);
        models.addAll(await operator.handleUsers(users: usersResponse.users, prepareRecordsOnly: true));
      }
      final channel = await getChannelById(database, channelId);
      if (channel != null) {
        models.addAll(await operator.handleChannelMembership(channelMemberships: [{'channel_id': channelId, 'user_id': userId}], prepareRecordsOnly: true));
      }
    }

    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'handleUserAddedToChannelEvent');
    }

    await fetchChannelStats(serverUrl, channelId, false);
  } catch (e) {
    // Do nothing
  }
}

Future<void> handleUserRemovedFromChannelEvent(String serverUrl, dynamic msg) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final String userId = msg['data']['user_id'] ?? msg['broadcast']['user_id'];
    final String channelId = msg['data']['channel_id'] ?? msg['broadcast']['channel_id'];

    if (EphemeralStore.isLeavingChannel(channelId)) {
      if (getCurrentCall()?.channelId == channelId) {
        leaveCall(userLeftChannelErr);
      }
      return;
    }

    final user = await getCurrentUser(database);
    if (user == null) {
      return;
    }

    final models = <Model>[];

    if (user.isGuest) {
      final updateVisibleModels = await updateUsersNoLongerVisible(serverUrl, true);
      if (updateVisibleModels.models.isNotEmpty) {
        models.addAll(updateVisibleModels.models);
      }
    }

    if (user.id == userId) {
      final currentChannelId = await getCurrentChannelId(database);
      if (currentChannelId != null && currentChannelId == channelId) {
        await handleKickFromChannel(serverUrl, currentChannelId);
      }

      await removeCurrentUserFromChannel(serverUrl, channelId);

      if (getCurrentCall()?.channelId == channelId) {
        leaveCall(userRemovedFromChannelErr);
      }
    } else {
      final deleteMemberModels = await deleteChannelMembership(operator, userId, channelId, true);
      if (deleteMemberModels.models.isNotEmpty) {
        models.addAll(deleteMemberModels.models);
      }
    }

    operator.batchRecords(models, 'handleUserRemovedFromChannelEvent');
  } catch (e) {
    logDebug('cannot handle user removed from channel websocket event', e);
  }
}

Future<void> handleChannelDeletedEvent(String serverUrl, dynamic msg) async {
  final String channelId = msg['data']['channel_id'];
  final int deleteAt = msg['data']['delete_at'];

  if (EphemeralStore.isLeavingChannel(channelId) || EphemeralStore.isArchivingChannel(channelId)) {
    return;
  }
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;

    final user = await getCurrentUser(database);
    if (user == null) {
      return;
    }

    await setChannelDeleteAt(serverUrl, channelId, deleteAt);
    if (user.isGuest) {
      updateUsersNoLongerVisible(serverUrl);
    }

    final currentChannel = await getCurrentChannel(database);
    final config = await getConfig(database);

    if (config?.ExperimentalViewArchivedChannels != 'true') {
      if (currentChannel != null && currentChannel.id == channelId) {
        await handleKickFromChannel(serverUrl, channelId, Events.CHANNEL_ARCHIVED);
      }
      await removeCurrentUserFromChannel(serverUrl, channelId);
    }
  } catch (e) {
    // Do nothing
  }
}
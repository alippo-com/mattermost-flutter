import 'dart:async';

import 'package:mattermost_flutter/actions/local/channel.dart';
import 'package:mattermost_flutter/actions/local/user.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/helpers/api/general.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/group.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/timezone.dart';


Future<Map<String, dynamic>> fetchMe(String serverUrl, {bool fetchOnly = false}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final resultSettled = await Future.wait([
      client.getMe(),
      client.getStatus('me'),
    ]);
    
    UserProfile? user;
    UserStatus? userStatus;
    
    for (final result in resultSettled) {
      if (result is UserProfile) {
        user = result;
      } else if (result is UserStatus) {
        userStatus = result;
      }
    }

    if (user == null) {
      throw Exception('User not found');
    }

    user.status = userStatus?.status;

    if (!fetchOnly) {
      await operator.handleUsers(users: [user], prepareRecordsOnly: false);
    }

    return {'user': user};
  } catch (error) {
    logDebug('error on fetchMe', getFullErrorMessage(error));
    await forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

Future<void> refetchCurrentUser(String serverUrl, String? currentUserId) async {
  logDebug('re-fetching self');
  final userResponse = await fetchMe(serverUrl);
  final user = userResponse['user'] as UserProfile?;
  
  if (user == null || currentUserId != null) {
    return;
  }

  logDebug('missing currentUserId');
  final operator = DatabaseManager.serverDatabases[serverUrl]?.operator;
  if (operator == null) {
    logDebug('missing operator');
    return;
  }
  
  setCurrentUserId(operator, user.id);
}

Future<Map<String, dynamic>> fetchProfilesInChannel(String serverUrl, String channelId, {String? excludeUserId, GetUsersOptions? options, bool fetchOnly = false}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;

    final users = await client.getProfilesInChannel(channelId, options);
    final uniqueUsers = users.toSet().toList();
    final filteredUsers = uniqueUsers.where((u) => u.id != excludeUserId).toList();
    
    if (!fetchOnly && filteredUsers.isNotEmpty) {
      final modelPromises = <Future<List<Model>>>[];
      final membership = filteredUsers.map((u) => {
        'channel_id': channelId,
        'user_id': u.id,
      }).toList();
      
      modelPromises.add(operator.handleChannelMembership(channelMemberships: membership, prepareRecordsOnly: true));
      modelPromises.add(prepareUsers(operator, filteredUsers));

      final models = await Future.wait(modelPromises);
      await operator.batchRecords(models.expand((element) => element).toList(), 'fetchProfilesInChannel');
    }

    return {'channelId': channelId, 'users': filteredUsers};
  } catch (error) {
    logDebug('error on fetchProfilesInChannel', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'channelId': channelId, 'error': error};
  }
}

// ... (other functions converted similarly)

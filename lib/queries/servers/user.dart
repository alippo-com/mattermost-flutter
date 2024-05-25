// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:watermelondb/watermelondb.dart';
import 'package:rxdart/rxdart.dart';

import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/helpers/database.dart';
import 'package:mattermost_flutter/types/preference.dart';
import 'package:mattermost_flutter/types/user_profile.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator.dart';
import 'package:mattermost_flutter/types/channel_membership.dart';
import 'package:mattermost_flutter/types/team_membership.dart';
import 'package:mattermost_flutter/types/user.dart';

const SERVER = MM_TABLES['SERVER'];
const CHANNEL_MEMBERSHIP = SERVER['CHANNEL_MEMBERSHIP'];
const USER = SERVER['USER'];
const TEAM_MEMBERSHIP = SERVER['TEAM_MEMBERSHIP'];

Future<UserModel?> getUserById(Database database, String userId) async {
  try {
    final userRecord = await database.get<UserModel>(USER).find(userId);
    return userRecord;
  } catch (e) {
    return null;
  }
}

Stream<UserModel?> observeUser(Database database, String userId) {
  return database
      .get<UserModel>(USER)
      .query(Q.where('id', userId), Q.take(1))
      .observe()
      .switchMap((result) => result.isNotEmpty ? result[0].observe() : Stream.value(null));
}

Future<UserModel?> getCurrentUser(Database database) async {
  final currentUserId = await getCurrentUserId(database);
  if (currentUserId != null) {
    return getUserById(database, currentUserId);
  }
  return null;
}

Stream<UserModel?> observeCurrentUser(Database database) {
  return observeCurrentUserId(database).switchMap((id) => observeUser(database, id));
}

Stream<String?> observeCurrentUserRoles(Database database) {
  return observeCurrentUser(database)
      .switchMap((user) => Stream.value(user?.roles))
      .distinct();
}

Query<UserModel> queryAllUsers(Database database) {
  return database.get<UserModel>(USER).query();
}

Query<UserModel> queryUsersById(Database database, List<String> userIds) {
  return database.get<UserModel>(USER).query(Q.where('id', Q.oneOf(userIds)));
}

Query<UserModel> queryUsersByUsername(Database database, List<String> usernames) {
  return database.get<UserModel>(USER).query(Q.where('username', Q.oneOf(usernames)));
}

Future<List<UserModel>> prepareUsers(ServerDataOperator operator, List<UserProfile> users) {
  return operator.handleUsers(users, prepareRecordsOnly: true);
}

Stream<String> observeTeammateNameDisplay(Database database) {
  final lockTeammateNameDisplay = observeConfigValue(database, 'LockTeammateNameDisplay');
  final teammateNameDisplay = observeConfigValue(database, 'TeammateNameDisplay');
  final license = observeLicense(database);
  final preferences = queryDisplayNamePreferences(database).observeWithColumns(['value']);
  return Rx.combineLatest4(lockTeammateNameDisplay, teammateNameDisplay, license, preferences,
      (ltnd, tnd, lcs, prefs) => getTeammateNameDisplaySetting(prefs, ltnd, tnd, lcs));
}

Future<String> getTeammateNameDisplay(Database database) async {
  final config = await getConfig(database);
  final license = await getLicense(database);
  final preferences = await queryDisplayNamePreferences(database).fetch();
  return getTeammateNameDisplaySetting(preferences, config?.lockTeammateNameDisplay, config?.teammateNameDisplay, license);
}

Query<UserModel> queryUsersLike(Database database, String likeUsername) {
  return database.get<UserModel>(USER).query(Q.where('username', Q.like('%${sanitizeLikeString(likeUsername)}%')));
}

Query<UserModel> queryUsersByIdsOrUsernames(Database database, List<String> ids, List<String> usernames) {
  return database.get<UserModel>(USER).query(Q.or(Q.where('id', Q.oneOf(ids)), Q.where('username', Q.oneOf(usernames))));
}

Stream<bool> observeUserIsTeamAdmin(Database database, String userId, String teamId) {
  final id = '$teamId-$userId';
  return database
      .get<TeamMembershipModel>(TEAM_MEMBERSHIP)
      .query(Q.where('id', Q.eq(id)))
      .observeWithColumns(['schemeAdmin'])
      .switchMap((tm) => Stream.value(tm.isNotEmpty ? tm[0].schemeAdmin : false));
}

Stream<bool> observeUserIsChannelAdmin(Database database, String userId, String channelId) {
  final id = '$channelId-$userId';
  return database
      .get<ChannelMembershipModel>(CHANNEL_MEMBERSHIP)
      .query(Q.where('id', Q.eq(id)))
      .observeWithColumns(['schemeAdmin'])
      .switchMap((cm) => Stream.value(cm.isNotEmpty ? cm[0].schemeAdmin : false))
      .distinct();
}

Stream<Map<String, UserModel>> observeDeactivatedUsers(Database database) {
  return database
      .get<UserModel>(USER)
      .query(Q.where('deleteAt', Q.gt(0)))
      .observe()
      .switchMap((users) => Stream.value(Map.fromIterable(users, key: (u) => u.id, value: (u) => u)));
}

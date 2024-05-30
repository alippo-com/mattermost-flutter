// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/error.dart';
import 'package:mattermost_flutter/base.dart';

class ClientUsersMix {
  Future<UserProfile> createUser(UserProfile user, String token, String inviteId);
  Future<UserProfile> patchMe(Map<String, dynamic> userPatch);
  Future<UserProfile> patchUser(Map<String, dynamic> userPatch);
  Future<UserProfile> updateUser(UserProfile user);
  Future<dynamic> demoteUserToGuest(String userId);
  Future<List<String>> getKnownUsers();
  Future<dynamic> sendPasswordResetEmail(String email);
  Future<dynamic> setDefaultProfileImage(String userId);
  Future<UserProfile> login(String loginId, String password, {String token, String deviceId, bool ldapOnly});
  Future<UserProfile> loginById(String id, String password, {String token, String deviceId});
  Future<dynamic> logout();
  Future<List<UserProfile>> getProfiles({int page, int perPage, Map<String, dynamic> options});
  Future<List<UserProfile>> getProfilesByIds(List<String> userIds, {Map<String, dynamic> options});
  Future<List<UserProfile>> getProfilesByUsernames(List<String> usernames);
  Future<List<UserProfile>> getProfilesInTeam(String teamId, {int page, int perPage, String sort, Map<String, dynamic> options});
  Future<List<UserProfile>> getProfilesNotInTeam(String teamId, bool groupConstrained, {int page, int perPage});
  Future<List<UserProfile>> getProfilesWithoutTeam({int page, int perPage, Map<String, dynamic> options});
  Future<List<UserProfile>> getProfilesInChannel(String channelId, {Map<String, dynamic> options});
  Future<Map<String, List<UserProfile>>> getProfilesInGroupChannels(List<String> channelsIds);
  Future<List<UserProfile>> getProfilesNotInChannel(String teamId, String channelId, bool groupConstrained, {int page, int perPage});
  Future<UserProfile> getMe();
  Future<UserProfile> getUser(String userId);
  Future<UserProfile> getUserByUsername(String username);
  Future<UserProfile> getUserByEmail(String email);
  String getProfilePictureUrl(String userId, int lastPictureUpdate);
  String getDefaultProfilePictureUrl(String userId);
  Future<Map<String, dynamic>> autocompleteUsers(String name, String teamId, {String channelId, Map<String, dynamic> options});
  Future<List<Session>> getSessions(String userId);
  Future<Map<String, dynamic>> checkUserMfa(String loginId);
  Future<dynamic> attachDevice(String deviceId);
  Future<List<UserProfile>> searchUsers(String term, Map<String, dynamic> options);
  Future<List<UserStatus>> getStatusesByIds(List<String> userIds);
  Future<UserStatus> getStatus(String userId);
  Future<UserStatus> updateStatus(UserStatus status);
  Future<Map<String, dynamic>> updateCustomStatus(UserCustomStatus customStatus);
  Future<Map<String, dynamic>> unsetCustomStatus();
  Future<Map<String, dynamic>> removeRecentCustomStatus(UserCustomStatus customStatus);
}

class ClientUsers<TBase extends ClientBase> extends TBase implements ClientUsersMix {
  @override
  Future<UserProfile> createUser(UserProfile user, String token, String inviteId) async {
    var queryParams = {};
    if (token.isNotEmpty) {
      queryParams['t'] = token;
    }
    if (inviteId.isNotEmpty) {
      queryParams['iid'] = inviteId;
    }
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString(queryParams)}',
      method: 'post',
      body: user.toJson(),
    );
  }

  @override
  Future<UserProfile> patchMe(Map<String, dynamic> userPatch) async {
    return this.doFetch(
      '\${this.getUserRoute('me')}/patch',
      method: 'put',
      body: userPatch,
    );
  }

  @override
  Future<UserProfile> patchUser(Map<String, dynamic> userPatch) async {
    return this.doFetch(
      '\${this.getUserRoute(userPatch['id'])}/patch',
      method: 'put',
      body: userPatch,
    );
  }

  @override
  Future<UserProfile> updateUser(UserProfile user) async {
    return this.doFetch(
      '\${this.getUserRoute(user.id)}',
      method: 'put',
      body: user.toJson(),
    );
  }

  @override
  Future<dynamic> demoteUserToGuest(String userId) async {
    return this.doFetch(
      '\${this.getUserRoute(userId)}/demote',
      method: 'post',
    );
  }

  @override
  Future<List<String>> getKnownUsers() async {
    return this.doFetch(
      '\${this.getUsersRoute()}/known',
      method: 'get',
    );
  }

  @override
  Future<dynamic> sendPasswordResetEmail(String email) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/password/reset/send',
      method: 'post',
      body: {'email': email},
    );
  }

  @override
  Future<dynamic> setDefaultProfileImage(String userId) async {
    return this.doFetch(
      '\${this.getUserRoute(userId)}/image',
      method: 'delete',
    );
  }

  @override
  Future<UserProfile> login(String loginId, String password, {String token = '', String deviceId = '', bool ldapOnly = false}) async {
    var body = {
      'device_id': deviceId,
      'login_id': loginId,
      'password': password,
      'token': token,
    };
    if (ldapOnly) {
      body['ldap_only'] = 'true';
    }
    var data = await this.doFetch(
      '\${this.getUsersRoute()}/login',
      method: 'post',
      body: body,
      headers: {'Cache-Control': 'no-store'},
      noRetry: true,
    );
    return UserProfile.fromJson(data);
  }

  @override
  Future<UserProfile> loginById(String id, String password, {String token = '', String deviceId = ''}) async {
    var body = {
      'device_id': deviceId,
      'id': id,
      'password': password,
      'token': token,
    };
    var data = await this.doFetch(
      '\${this.getUsersRoute()}/login',
      method: 'post',
      body: body,
      headers: {'Cache-Control': 'no-store'},
      noRetry: true,
    );
    return UserProfile.fromJson(data);
  }

  @override
  Future<dynamic> logout() async {
    return this.doFetch(
      '\${this.getUsersRoute()}/logout',
      method: 'post',
    );
  }

  @override
  Future<List<UserProfile>> getProfiles({int page = 0, int perPage = PER_PAGE_DEFAULT, Map<String, dynamic> options = const {}}) async {
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString({'page': page, 'per_page': perPage, ...options})}',
      method: 'get',
    );
  }

  @override
  Future<List<UserProfile>> getProfilesByIds(List<String> userIds, {Map<String, dynamic> options = const {}}) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/ids\${buildQueryString(options)}',
      method: 'post',
      body: userIds,
    );
  }

  @override
  Future<List<UserProfile>> getProfilesByUsernames(List<String> usernames) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/usernames',
      method: 'post',
      body: usernames,
    );
  }

  @override
  Future<List<UserProfile>> getProfilesInTeam(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT, String sort = '', Map<String, dynamic> options = const {}}) async {
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString({'in_team': teamId, 'page': page, 'per_page': perPage, 'sort': sort, ...options})}',
      method: 'get',
    );
  }

  @override
  Future<List<UserProfile>> getProfilesNotInTeam(String teamId, bool groupConstrained, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    var queryStringObj = {'not_in_team': teamId, 'page': page, 'per_page': perPage};
    if (groupConstrained) {
      queryStringObj['group_constrained'] = true;
    }
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString(queryStringObj)}',
      method: 'get',
    );
  }

  @override
  Future<List<UserProfile>> getProfilesWithoutTeam({int page = 0, int perPage = PER_PAGE_DEFAULT, Map<String, dynamic> options = const {}}) async {
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString({'without_team': 1, 'page': page, 'per_page': perPage, ...options})}',
      method: 'get',
    );
  }

  @override
  Future<List<UserProfile>> getProfilesInChannel(String channelId, {Map<String, dynamic> options = const {}}) async {
    var queryStringObj = {'in_channel': channelId, ...options};
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString(queryStringObj)}',
      method: 'get',
    );
  }

  @override
  Future<Map<String, List<UserProfile>>> getProfilesInGroupChannels(List<String> channelsIds) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/group_channels',
      method: 'post',
      body: channelsIds,
    );
  }

  @override
  Future<List<UserProfile>> getProfilesNotInChannel(String teamId, String channelId, bool groupConstrained, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    var queryStringObj = {'in_team': teamId, 'not_in_channel': channelId, 'page': page, 'per_page': perPage};
    if (groupConstrained) {
      queryStringObj['group_constrained'] = true;
    }
    return this.doFetch(
      '\${this.getUsersRoute()}\${buildQueryString(queryStringObj)}',
      method: 'get',
    );
  }

  @override
  Future<UserProfile> getMe() async {
    return this.doFetch(
      '\${this.getUserRoute('me')}',
      method: 'get',
    );
  }

  @override
  Future<UserProfile> getUser(String userId) async {
    return this.doFetch(
      '\${this.getUserRoute(userId)}',
      method: 'get',
    );
  }

  @override
  Future<UserProfile> getUserByUsername(String username) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/username/\$username',
      method: 'get',
    );
  }

  @override
  Future<UserProfile> getUserByEmail(String email) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/email/\$email',
      method: 'get',
    );
  }

  @override
  String getProfilePictureUrl(String userId, int lastPictureUpdate) {
    var params = {};
    params['_'] = lastPictureUpdate;
      return '\${this.getUserRoute(userId)}/image\${buildQueryString(params)}';
  }

  @override
  String getDefaultProfilePictureUrl(String userId) {
    return '\${this.getUserRoute(userId)}/image/default';
  }

  @override
  Future<Map<String, dynamic>> autocompleteUsers(String name, String teamId, {String channelId, Map<String, dynamic> options = const {'limit': General.AUTOCOMPLETE_LIMIT_DEFAULT}}) async {
    var query = {'in_team': teamId, 'name': name};
    if (channelId.isNotEmpty) {
      query['in_channel'] = channelId;
    }
    if (options.containsKey('limit')) {
      query['limit'] = options['limit'];
    }
    return this.doFetch(
      '\${this.getUsersRoute()}/autocomplete\${buildQueryString(query)}',
      method: 'get',
    );
  }

  @override
  Future<List<Session>> getSessions(String userId) async {
    return this.doFetch(
      '\${this.getUserRoute(userId)}/sessions',
      method: 'get',
      headers: {'Cache-Control': 'no-store'},
    );
  }

  @override
  Future<Map<String, dynamic>> checkUserMfa(String loginId) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/mfa',
      method: 'post',
      body: {'login_id': loginId},
      headers: {'Cache-Control': 'no-store'},
    );
  }

  @override
  Future<dynamic> attachDevice(String deviceId) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/sessions/device',
      method: 'put',
      body: {'device_id': deviceId},
    );
  }

  @override
  Future<List<UserProfile>> searchUsers(String term, Map<String, dynamic> options) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/search',
      method: 'post',
      body: {'term': term, ...options},
    );
  }

  @override
  Future<List<UserStatus>> getStatusesByIds(List<String> userIds) async {
    return this.doFetch(
      '\${this.getUsersRoute()}/status/ids',
      method: 'post',
      body: userIds,
    );
  }

  @override
  Future<UserStatus> getStatus(String userId) async {
    return this.doFetch(
      '\${this.getUserRoute(userId)}/status',
      method: 'get',
    );
  }

  @override
  Future<UserStatus> updateStatus(UserStatus status) async {
    return this.doFetch(
      '\${this.getUserRoute(status.userId)}/status',
      method: 'put',
      body: status.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> updateCustomStatus(UserCustomStatus customStatus) async {
    return this.doFetch(
      '\${this.getUserRoute('me')}/status/custom',
      method: 'put',
      body: customStatus.toJson(),
    );
  }

  @override
  Future<Map<String, dynamic>> unsetCustomStatus() async {
    return this.doFetch(
      '\${this.getUserRoute('me')}/status/custom',
      method: 'delete',
    );
  }

  @override
  Future<Map<String, dynamic>> removeRecentCustomStatus(UserCustomStatus customStatus) async {
    return this.doFetch(
      '\${this.getUserRoute('me')}/status/custom/recent/delete',
      method: 'post',
      body: customStatus.toJson(),
    );
  }
}

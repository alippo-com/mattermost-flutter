// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.


import '../base.dart';

abstract class ClientChannelsMix {
  Future<dynamic> getAllChannels({int page = 0, int perPage = PER_PAGE_DEFAULT, String notAssociatedToGroup = '', bool excludeDefaultChannels = false, bool includeTotalCount = false});
  Future<Channel> createChannel(Channel channel);
  Future<Channel> createDirectChannel(List<String> userIds);
  Future<Channel> createGroupChannel(List<String> userIds);
  Future<dynamic> deleteChannel(String channelId);
  Future<Channel> unarchiveChannel(String channelId);
  Future<Channel> updateChannel(Channel channel);
  Future<Channel> convertChannelToPrivate(String channelId);
  Future<Channel> updateChannelPrivacy(String channelId, dynamic privacy);
  Future<Channel> patchChannel(String channelId, ChannelPatch channelPatch);
  Future<dynamic> updateChannelNotifyProps(ChannelNotifyProps props);
  Future<Channel> getChannel(String channelId);
  Future<Channel> getChannelByName(String teamId, String channelName, {bool includeDeleted = false});
  Future<Channel> getChannelByNameAndTeamName(String teamName, String channelName, {bool includeDeleted = false});
  Future<List<Channel>> getChannels(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<List<Channel>> getArchivedChannels(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<List<Channel>> getSharedChannels(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<List<Channel>> getMyChannels(String teamId, {bool includeDeleted = false, int lastDeleteAt = 0});
  Future<ChannelMembership> getMyChannelMember(String channelId);
  Future<List<ChannelMembership>> getMyChannelMembers(String teamId);
  Future<List<ChannelMembership>> getChannelMembers(String channelId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
  Future<List<String>> getChannelTimezones(String channelId);
  Future<ChannelMembership> getChannelMember(String channelId, String userId);
  Future<List<ChannelMembership>> getChannelMembersByIds(String channelId, List<String> userIds);
  Future<ChannelMembership> addToChannel(String userId, String channelId, {String postRootId = ''});
  Future<dynamic> removeFromChannel(String userId, String channelId);
  Future<ChannelStats> getChannelStats(String channelId);
  Future<List<ChannelMemberCountByGroup>> getChannelMemberCountsByGroup(String channelId, bool includeTimezones);
  Future<dynamic> viewMyChannel(String channelId, {String prevChannelId});
  Future<List<Channel>> autocompleteChannels(String teamId, String name);
  Future<List<Channel>> autocompleteChannelsForSearch(String teamId, String name);
  Future<List<Channel>> searchChannels(String teamId, String term);
  Future<List<Channel>> searchArchivedChannels(String teamId, String term);
  Future<List<Channel>> searchAllChannels(String term, List<String> teamIds, {bool archivedOnly = false});
  Future<dynamic> updateChannelMemberSchemeRoles(String channelId, String userId, bool isSchemeUser, bool isSchemeAdmin);
  Future<ChannelMembership> getMemberInChannel(String channelId, String userId);
  Future<List<Team>> getGroupMessageMembersCommonTeams(String channelId);
  Future<Channel> convertGroupMessageToPrivateChannel(String channelId, String teamId, String displayName, String name);
}

mixin ClientChannels<T extends ClientBase> on ClientBase {
  Future<dynamic> getAllChannels({int page = 0, int perPage = PER_PAGE_DEFAULT, String notAssociatedToGroup = '', bool excludeDefaultChannels = false, bool includeTotalCount = false}) async {
    final queryData = {
      'page': page,
      'per_page': perPage,
      'not_associated_to_group': notAssociatedToGroup,
      'exclude_default_channels': excludeDefaultChannels,
      'include_total_count': includeTotalCount,
    };
    return doFetch<dynamic>(
      '${getChannelsRoute()}${buildQueryString(queryData)}',
      method: 'get',
    );
  }

  Future<Channel> createChannel(Channel channel) async {
    analytics?.trackAPI('api_channels_create', {'team_id': channel.teamId});

    return doFetch<Channel>(
      '${getChannelsRoute()}',
      method: 'post',
      body: channel,
    );
  }

  Future<Channel> createDirectChannel(List<String> userIds) async {
    analytics?.trackAPI('api_channels_create_direct');

    return doFetch<Channel>(
      '${getChannelsRoute()}/direct',
      method: 'post',
      body: userIds,
    );
  }

  Future<Channel> createGroupChannel(List<String> userIds) async {
    analytics?.trackAPI('api_channels_create_group');

    return doFetch<Channel>(
      '${getChannelsRoute()}/group',
      method: 'post',
      body: userIds,
    );
  }

  Future<dynamic> deleteChannel(String channelId) async {
    analytics?.trackAPI('api_channels_delete', {'channel_id': channelId});

    return doFetch<dynamic>(
      '${getChannelRoute(channelId)}',
      method: 'delete',
    );
  }

  Future<Channel> unarchiveChannel(String channelId) async {
    analytics?.trackAPI('api_channels_unarchive', {'channel_id': channelId});

    return doFetch<Channel>(
      '${getChannelRoute(channelId)}/restore',
      method: 'post',
    );
  }

  Future<Channel> updateChannel(Channel channel) async {
    analytics?.trackAPI('api_channels_update', {'channel_id': channel.id});

    return doFetch<Channel>(
      '${getChannelRoute(channel.id)}',
      method: 'put',
      body: channel,
    );
  }

  Future<Channel> convertChannelToPrivate(String channelId) async {
    return updateChannelPrivacy(channelId, 'P');
  }

  Future<Channel> updateChannelPrivacy(String channelId, dynamic privacy) async {
    analytics?.trackAPI('api_channels_update_privacy', {'channel_id': channelId, 'privacy': privacy});

    return doFetch<Channel>(
      '${getChannelRoute(channelId)}/privacy',
      method: 'put',
      body: {'privacy': privacy},
    );
  }

  Future<Channel> patchChannel(String channelId, ChannelPatch channelPatch) async {
    analytics?.trackAPI('api_channels_patch', {'channel_id': channelId});

    return doFetch<Channel>(
      '${getChannelRoute(channelId)}/patch',
      method: 'put',
      body: channelPatch,
    );
  }

  Future<dynamic> updateChannelNotifyProps(ChannelNotifyProps props) async {
    analytics?.trackAPI('api_users_update_channel_notifications', {'channel_id': props.channelId});

    return doFetch<dynamic>(
      '${getChannelMemberRoute(props.channelId, props.userId)}/notify_props',
      method: 'put',
      body: props,
    );
  }

  Future<Channel> getChannel(String channelId) async {
    analytics?.trackAPI('api_channel_get', {'channel_id': channelId});

    return doFetch<Channel>(
      '${getChannelRoute(channelId)}',
      method: 'get',
    );
  }

  Future<Channel> getChannelByName(String teamId, String channelName, {bool includeDeleted = false}) async {
    return doFetch<Channel>(
      '${getTeamRoute(teamId)}/channels/name/$channelName?include_deleted=$includeDeleted',
      method: 'get',
    );
  }

  Future<Channel> getChannelByNameAndTeamName(String teamName, String channelName, {bool includeDeleted = false}) async {
    analytics?.trackAPI('api_channel_get_by_name_and_teamName', {'channel_name': channelName, 'team_name': teamName, 'include_deleted': includeDeleted});

    return doFetch<Channel>(
      '${getTeamNameRoute(teamName)}/channels/name/$channelName?include_deleted=$includeDeleted',
      method: 'get',
    );
  }

  Future<List<Channel>> getChannels(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return doFetch<List<Channel>>(
      '${getTeamRoute(teamId)}/channels${buildQueryString({'page': page, 'per_page': perPage})}',
      method: 'get',
    );
  }

  Future<List<Channel>> getArchivedChannels(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return doFetch<List<Channel>>(
      '${getTeamRoute(teamId)}/channels/deleted${buildQueryString({'page': page, 'per_page': perPage})}',
      method: 'get',
    );
  }

  Future<List<Channel>> getSharedChannels(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return doFetch<List<Channel>>(
      '${getSharedChannelsRoute()}/$teamId${buildQueryString({'page': page, 'per_page': perPage})}',
      method: 'get',
    );
  }

  Future<List<Channel>> getMyChannels(String teamId, {bool includeDeleted = false, int lastDeleteAt = 0}) async {
    return doFetch<List<Channel>>(
      '${getUserRoute('me')}/teams/$teamId/channels${buildQueryString({
        'include_deleted': includeDeleted,
        'last_delete_at': lastDeleteAt,
      })}',
      method: 'get',
    );
  }

  Future<ChannelMembership> getMyChannelMember(String channelId) async {
    return doFetch<ChannelMembership>(
      '${getChannelMemberRoute(channelId, 'me')}',
      method: 'get',
    );
  }

  Future<List<ChannelMembership>> getMyChannelMembers(String teamId) async {
    return doFetch<List<ChannelMembership>>(
      '${getUserRoute('me')}/teams/$teamId/channels/members',
      method: 'get',
    );
  }

  Future<List<ChannelMembership>> getChannelMembers(String channelId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
    return doFetch<List<ChannelMembership>>(
      '${getChannelMembersRoute(channelId)}${buildQueryString({'page': page, 'per_page': perPage})}',
      method: 'get',
    );
  }

  Future<List<String>> getChannelTimezones(String channelId) async {
    return doFetch<List<String>>(
      '${getChannelRoute(channelId)}/timezones',
      method: 'get',
    );
  }

  Future<ChannelMembership> getChannelMember(String channelId, String userId) async {
    return doFetch<ChannelMembership>(
      '${getChannelMemberRoute(channelId, userId)}',
      method: 'get',
    );
  }

  Future<List<ChannelMembership>> getChannelMembersByIds(String channelId, List<String> userIds) async {
    return doFetch<List<ChannelMembership>>(
      '${getChannelMembersRoute(channelId)}/ids',
      method: 'post',
      body: userIds,
    );
  }

  Future<ChannelMembership> addToChannel(String userId, String channelId, {String postRootId = ''}) async {
    analytics?.trackAPI('api_channels_add_member', {'channel_id': channelId});

    final member = {'user_id': userId, 'channel_id': channelId, 'post_root_id': postRootId};
    return doFetch<ChannelMembership>(
      '${getChannelMembersRoute(channelId)}',
      method: 'post',
      body: member,
    );
  }

  Future<dynamic> removeFromChannel(String userId, String channelId) async {
    analytics?.trackAPI('api_channels_remove_member', {'channel_id': channelId});

    return doFetch<dynamic>(
      '${getChannelMemberRoute(channelId, userId)}',
      method: 'delete',
    );
  }

  Future<ChannelStats> getChannelStats(String channelId) async {
    return doFetch<ChannelStats>(
      '${getChannelRoute(channelId)}/stats',
      method: 'get',
    );
  }

  Future<List<ChannelMemberCountByGroup>> getChannelMemberCountsByGroup(String channelId, bool includeTimezones) async {
    return doFetch<List<ChannelMemberCountByGroup>>(
      '${getChannelRoute(channelId)}/member_counts_by_group?include_timezones=$includeTimezones',
      method: 'get',
    );
  }

  Future<dynamic> viewMyChannel(String channelId, {String prevChannelId}) async {
    // collapsed_threads_supported is not based on user preferences but to know if "CLIENT" supports CRT
    final data = {'channel_id': channelId, 'prev_channel_id': prevChannelId, 'collapsed_threads_supported': true};
    return doFetch<dynamic>(
      '${getChannelsRoute()}/members/me/view',
      method: 'post',
      body: data,
    );
  }

  Future<List<Channel>> autocompleteChannels(String teamId, String name) async {
    return doFetch<List<Channel>>(
      '${getTeamRoute(teamId)}/channels/autocomplete${buildQueryString({'name': name})}',
      method: 'get',
    );
  }

  Future<List<Channel>> autocompleteChannelsForSearch(String teamId, String name) async {
    return doFetch<List<Channel>>(
      '${getTeamRoute(teamId)}/channels/search_autocomplete${buildQueryString({'name': name})}',
      method: 'get',
    );
  }

  Future<List<Channel>> searchChannels(String teamId, String term) async {
    return doFetch<List<Channel>>(
      '${getTeamRoute(teamId)}/channels/search',
      method: 'post',
      body: {'term': term},
    );
  }

  Future<List<Channel>> searchArchivedChannels(String teamId, String term) async {
    return doFetch<List<Channel>>(
      '${getTeamRoute(teamId)}/channels/search_archived',
      method: 'post',
      body: {'term': term},
    );
  }

  Future<List<Channel>> searchAllChannels(String term, List<String> teamIds, {bool archivedOnly = false}) async {
    final queryParams = {'include_deleted': false, 'system_console': false, 'exclude_default_channels': false};
    final body = {
      'term': term,
      'team_ids': teamIds,
      'deleted': archivedOnly,
      'exclude_default_channels': true,
      'exclude_group_constrained': true,
      'public': true,
      'private': false,
    };

    return doFetch<List<Channel>>(
      '${getChannelsRoute()}/search${buildQueryString(queryParams)}',
      method: 'post',
      body: body,
    );
  }

  Future<dynamic> updateChannelMemberSchemeRoles(String channelId, String userId, bool isSchemeUser, bool isSchemeAdmin) async {
    final body = {'scheme_user': isSchemeUser, 'scheme_admin': isSchemeAdmin};
    return doFetch<dynamic>(
      '${getChannelMembersRoute(channelId)}/$userId/schemeRoles',
      method: 'put',
      body: body,
    );
  }

  Future<ChannelMembership> getMemberInChannel(String channelId, String userId) async {
    return doFetch<ChannelMembership>(
      '${getChannelMembersRoute(channelId)}/$userId',
      method: 'get',
    );
  }

  Future<List<Team>> getGroupMessageMembersCommonTeams(String channelId) async {
    return doFetch<List<Team>>(
      '${getChannelRoute(channelId)}/common_teams',
      method: 'get',
    );
  }

  Future<Channel> convertGroupMessageToPrivateChannel(String channelId, String teamId, String displayName, String name) async {
    final body = {
      'channel_id': channelId,
      'team_id': teamId,
      'display_name': displayName,
      'name': name,
    };

    return doFetch<Channel>(
      '${getChannelRoute(channelId)}/convert_to_channel?team-id=$teamId',
      method: 'post',
      body: body,
    );
  }
}

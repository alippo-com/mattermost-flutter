
    // Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
    // See LICENSE.txt for license information.

    import 'package:mattermost_flutter/utils/helpers.dart';
    import 'package:mattermost_flutter/constants.dart';
    import 'package:mattermost_flutter/types/base.dart';

    abstract class ClientTeamsMix {
      Future<Team> createTeam(Team team);
      Future<void> deleteTeam(String teamId);
      Future<Team> updateTeam(Team team);
      Future<Team> patchTeam(PartialTeam team);
      Future<List<Team>> getTeams({int page = 0, int perPage = PER_PAGE_DEFAULT, bool includeTotalCount = false});
      Future<Team> getTeam(String teamId);
      Future<Team> getTeamByName(String teamName);
      Future<List<Team>> getMyTeams();
      Future<List<Team>> getTeamsForUser(String userId);
      Future<List<TeamMembership>> getMyTeamMembers();
      Future<List<TeamMembership>> getTeamMembers(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT});
      Future<TeamMembership> getTeamMember(String teamId, String userId);
      Future<List<TeamMembership>> getTeamMembersByIds(String teamId, List<String> userIds);
      Future<TeamMembership> addToTeam(String teamId, String userId);
      Future<List<TeamMemberWithError>> addUsersToTeamGracefully(String teamId, List<String> userIds);
      Future<List<TeamInviteWithError>> sendEmailInvitesToTeamGracefully(String teamId, List<String> emails);
      Future<TeamMembership> joinTeam(String inviteId);
      Future<void> removeFromTeam(String teamId, String userId);
      Future<dynamic> getTeamStats(String teamId);
      String getTeamIconUrl(String teamId, int lastTeamIconUpdate);
    }

    class ClientTeams<TBase extends ClientBase> extends TBase implements ClientTeamsMix {
      @override
      Future<Team> createTeam(Team team) async {
        this.analytics?.trackAPI('api_teams_create');

        return this.doFetch(
          '${this.getTeamsRoute()}',
          method: 'post',
          body: team,
        );
      }

      @override
      Future<void> deleteTeam(String teamId) async {
        this.analytics?.trackAPI('api_teams_delete');

        return this.doFetch(
          '${this.getTeamRoute(teamId)}',
          method: 'delete',
        );
      }

      @override
      Future<Team> updateTeam(Team team) async {
        this.analytics?.trackAPI('api_teams_update_name', {'team_id': team.id});

        return this.doFetch(
          '${this.getTeamRoute(team.id)}',
          method: 'put',
          body: team,
        );
      }

      @override
      Future<Team> patchTeam(PartialTeam team) async {
        this.analytics?.trackAPI('api_teams_patch_name', {'team_id': team.id});

        return this.doFetch(
          '${this.getTeamRoute(team.id)}/patch',
          method: 'put',
          body: team,
        );
      }

      @override
      Future<List<Team>> getTeams({int page = 0, int perPage = PER_PAGE_DEFAULT, bool includeTotalCount = false}) async {
        return this.doFetch(
          '${this.getTeamsRoute()}${buildQueryString({'page': page, 'per_page': perPage, 'include_total_count': includeTotalCount})}',
          method: 'get',
        );
      }

      @override
      Future<Team> getTeam(String teamId) async {
        return this.doFetch(
          this.getTeamRoute(teamId),
          method: 'get',
        );
      }

      @override
      Future<Team> getTeamByName(String teamName) async {
        this.analytics?.trackAPI('api_teams_get_team_by_name');

        return this.doFetch(
          this.getTeamNameRoute(teamName),
          method: 'get',
        );
      }

      @override
      Future<List<Team>> getMyTeams() async {
        return this.doFetch(
          '${this.getUserRoute('me')}/teams',
          method: 'get',
        );
      }

      @override
      Future<List<Team>> getTeamsForUser(String userId) async {
        return this.doFetch(
          '${this.getUserRoute(userId)}/teams',
          method: 'get',
        );
      }

      @override
      Future<List<TeamMembership>> getMyTeamMembers() async {
        return this.doFetch(
          '${this.getUserRoute('me')}/teams/members',
          method: 'get',
        );
      }

      @override
      Future<List<TeamMembership>> getTeamMembers(String teamId, {int page = 0, int perPage = PER_PAGE_DEFAULT}) async {
        return this.doFetch(
          '${this.getTeamMembersRoute(teamId)}${buildQueryString({'page': page, 'per_page': perPage})}',
          method: 'get',
        );
      }

      @override
      Future<TeamMembership> getTeamMember(String teamId, String userId) async {
        return this.doFetch(
          '${this.getTeamMemberRoute(teamId, userId)}',
          method: 'get',
        );
      }

      @override
      Future<List<TeamMembership>> getTeamMembersByIds(String teamId, List<String> userIds) async {
        return this.doFetch(
          '${this.getTeamMembersRoute(teamId)}/ids',
          method: 'post',
          body: userIds,
        );
      }

      @override
      Future<TeamMembership> addToTeam(String teamId, String userId) async {
        this.analytics?.trackAPI('api_teams_invite_members', {'team_id': teamId});

        final member = {'user_id': userId, 'team_id': teamId};
        return this.doFetch(
          '${this.getTeamMembersRoute(teamId)}',
          method: 'post',
          body: member,
        );
      }

      @override
      Future<List<TeamMemberWithError>> addUsersToTeamGracefully(String teamId, List<String> userIds) async {
        this.analytics?.trackAPI('api_teams_batch_add_members', {'team_id': teamId, 'count': userIds.length});

        final members = userIds.map((id) => {'team_id': teamId, 'user_id': id}).toList();

        return this.doFetch(
          '${this.getTeamMembersRoute(teamId)}/batch?graceful=true',
          method: 'post',
          body: members,
        );
      }

      @override
      Future<List<TeamInviteWithError>> sendEmailInvitesToTeamGracefully(String teamId, List<String> emails) async {
        this.analytics?.trackAPI('api_teams_invite_members', {'team_id': teamId});

        return this.doFetch(
          '${this.getTeamRoute(teamId)}/invite/email?graceful=true',
          method: 'post',
          body: emails,
        );
      }

      @override
      Future<TeamMembership> joinTeam(String inviteId) async {
        final query = buildQueryString({'invite_id': inviteId});
        return this.doFetch(
          '${this.getTeamsRoute()}/members/invite$query',
          method: 'post',
        );
      }

      @override
      Future<void> removeFromTeam(String teamId, String userId) async {
        this.analytics?.trackAPI('api_teams_remove_members', {'team_id': teamId});

        return this.doFetch(
          '${this.getTeamMemberRoute(teamId, userId)}',
          method: 'delete',
        );
      }

      @override
      Future<dynamic> getTeamStats(String teamId) async {
        return this.doFetch(
          '${this.getTeamRoute(teamId)}/stats',
          method: 'get',
        );
      }

      @override
      String getTeamIconUrl(String teamId, int lastTeamIconUpdate) {
        final params = lastTeamIconUpdate != null ? {'_': lastTeamIconUpdate} : {};
        return '${this.getTeamRoute(teamId)}/image${buildQueryString(params)}';
      }
    }
  
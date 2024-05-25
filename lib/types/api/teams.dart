// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import './error.dart';

class TeamMembership {
  String? id;
  int mentionCount;
  int msgCount;
  String teamId;
  String userId;
  String roles;
  int deleteAt;
  bool schemeUser;
  bool schemeAdmin;

  TeamMembership({
    this.id,
    required this.mentionCount,
    required this.msgCount,
    required this.teamId,
    required this.userId,
    required this.roles,
    required this.deleteAt,
    required this.schemeUser,
    required this.schemeAdmin,
  });
}

class TeamMemberWithError {
  TeamMembership member;
  String userId;
  ApiError error;

  TeamMemberWithError({
    required this.member,
    required this.userId,
    required this.error,
  });
}

class TeamInviteWithError {
  String email;
  ApiError error;

  TeamInviteWithError({
    required this.email,
    required this.error,
  });
}

enum TeamType { O, I }

class Team {
  String id;
  int createAt;
  int updateAt;
  int deleteAt;
  String displayName;
  String name;
  String description;
  String email;
  TeamType type;
  String companyName;
  String allowedDomains;
  String inviteId;
  bool allowOpenInvite;
  String? schemeId;
  bool? groupConstrained;
  int lastTeamIconUpdate;

  Team({
    required this.id,
    required this.createAt,
    required this.updateAt,
    required this.deleteAt,
    required this.displayName,
    required this.name,
    required this.description,
    required this.email,
    required this.type,
    required this.companyName,
    required this.allowedDomains,
    required this.inviteId,
    required this.allowOpenInvite,
    this.schemeId,
    this.groupConstrained,
    required this.lastTeamIconUpdate,
  });
}

class TeamsState {
  String currentTeamId;
  Map<String, Team> teams;
  Map<String, TeamMembership> myMembers;
  Map<String, dynamic> membersInTeam;
  Map<String, dynamic> stats;
  Map<String, dynamic> groupsAssociatedToTeam;
  int totalCount;

  TeamsState({
    required this.currentTeamId,
    required this.teams,
    required this.myMembers,
    required this.membersInTeam,
    required this.stats,
    required this.groupsAssociatedToTeam,
    required this.totalCount,
  });
}

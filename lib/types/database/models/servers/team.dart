// See LICENSE.txt for license information.

import 'package:sqflite/sqflite.dart';
import 'package:mattermost_flutter/types/database/models/servers/category.dart';
import 'package:mattermost_flutter/types/database/models/servers/channel.dart';
import 'package:mattermost_flutter/types/database/models/servers/my_team.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_channel_history.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_membership.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_search_history.dart';
import 'package:mattermost_flutter/types/associations.dart';

class TeamModel {
  static const String table = 'Team';

  static final Associations associations = Associations();

  final bool isAllowOpenInvite;
  final String description;
  final String displayName;
  final int updateAt;
  final bool isGroupConstrained;
  final int lastTeamIconUpdatedAt;
  final String name;
  final String type;
  final String allowedDomains;
  final String inviteId;

  final List<CategoryModel> categories;
  final List<ChannelModel> channels;
  final MyTeamModel? myTeam;
  final List<TeamChannelHistoryModel> teamChannelHistory;
  final List<TeamMembershipModel> members;
  final List<TeamSearchHistoryModel> teamSearchHistories;

  TeamModel({
    required this.isAllowOpenInvite,
    required this.description,
    required this.displayName,
    required this.updateAt,
    required this.isGroupConstrained,
    required this.lastTeamIconUpdatedAt,
    required this.name,
    required this.type,
    required this.allowedDomains,
    required this.inviteId,
    required this.categories,
    required this.channels,
    this.myTeam,
    required this.teamChannelHistory,
    required this.members,
    required this.teamSearchHistories,
  });

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      isAllowOpenInvite: map['isAllowOpenInvite'],
      description: map['description'],
      displayName: map['displayName'],
      updateAt: map['updateAt'],
      isGroupConstrained: map['isGroupConstrained'],
      lastTeamIconUpdatedAt: map['lastTeamIconUpdatedAt'],
      name: map['name'],
      type: map['type'],
      allowedDomains: map['allowedDomains'],
      inviteId: map['inviteId'],
      categories: (map['categories'] as List).map((item) => CategoryModel.fromMap(item)).toList(),
      channels: (map['channels'] as List).map((item) => ChannelModel.fromMap(item)).toList(),
      myTeam: map['myTeam'] != null ? MyTeamModel.fromMap(map['myTeam']) : null,
      teamChannelHistory: (map['teamChannelHistory'] as List).map((item) => TeamChannelHistoryModel.fromMap(item)).toList(),
      members: (map['members'] as List).map((item) => TeamMembershipModel.fromMap(item)).toList(),
      teamSearchHistories: (map['teamSearchHistories'] as List).map((item) => TeamSearchHistoryModel.fromMap(item)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isAllowOpenInvite': isAllowOpenInvite,
      'description': description,
      'displayName': displayName,
      'updateAt': updateAt,
      'isGroupConstrained': isGroupConstrained,
      'lastTeamIconUpdatedAt': lastTeamIconUpdatedAt,
      'name': name,
      'type': type,
      'allowedDomains': allowedDomains,
      'inviteId': inviteId,
      'categories': categories.map((item) => item.toMap()).toList(),
      'channels': channels.map((item) => item.toMap()).toList(),
      'myTeam': myTeam?.toMap(),
      'teamChannelHistory': teamChannelHistory.map((item) => item.toMap()).toList(),
      'members': members.map((item) => item.toMap()).toList(),
      'teamSearchHistories': teamSearchHistories.map((item) => item.toMap()).toList(),
    };
  }
}

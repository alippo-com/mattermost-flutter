
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Dart representation of Permalink error types in a Mattermost environment.
class PermalinkError {
  final bool? unreachable;
  final bool? notExist;
  final bool? joinedTeam;
  final bool? privateChannel;
  final bool? privateTeam;
  final String? teamName;
  final String? channelName;
  final String? teamId;
  final String? channelId;

  PermalinkError({
    this.unreachable,
    this.notExist,
    this.joinedTeam,
    this.privateChannel,
    this.privateTeam,
    this.teamName,
    this.channelName,
    this.teamId,
    this.channelId,
  });

  factory PermalinkError.fromJson(Map<String, dynamic> json) {
    return PermalinkError(
      unreachable: json['unreachable'],
      notExist: json['notExist'],
      joinedTeam: json['joinedTeam'],
      privateChannel: json['privateChannel'],
      privateTeam: json['privateTeam'],
      teamName: json['teamName'],
      channelName: json['channelName'],
      teamId: json['teamId'],
      channelId: json['channelId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unreachable': unreachable,
      'notExist': notExist,
      'joinedTeam': joinedTeam,
      'privateChannel': privateChannel,
      'privateTeam': privateTeam,
      'teamName': teamName,
      'channelName': channelName,
      'teamId': teamId,
      'channelId': channelId,
    };
  }
}

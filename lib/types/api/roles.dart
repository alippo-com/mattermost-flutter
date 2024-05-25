
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

/// Flutter representation of the ChannelModerationRoles type from Mattermost.
enum ChannelModerationRoles {
  members,
  guests,
}

/// Flutter representation of the Role type from Mattermost.
class Role {
  final String id;
  final String name;
  final String? displayName;
  final String? description;
  final int? createAt;
  final int? updateAt;
  final int? deleteAt;
  final List<String> permissions;
  final bool? schemeManaged;
  final bool? builtIn;

  Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.displayName,
    this.description,
    this.createAt,
    this.updateAt,
    this.deleteAt,
    this.schemeManaged,
    this.builtIn,
  });
}

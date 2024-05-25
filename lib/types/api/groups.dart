class Group {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final String source;
  final String remoteId;
  final int? memberCount;
  final bool allowReference;
  final int createAt;
  final int updateAt;
  final int deleteAt;

  Group({required this.id, required this.name, required this.displayName, required this.description, required this.source, required this.remoteId, this.memberCount, required this.allowReference, required this.createAt, required this.updateAt, required this.deleteAt});
}

class GroupTeam {
  final String? id;
  final String teamId;
  final String groupId;

  GroupTeam({this.id, required this.teamId, required this.groupId});
}

class GroupChannel {
  final String? id;
  final String channelId;
  final String groupId;

  GroupChannel({this.id, required this.channelId, required this.groupId});
}

class GroupMembership {
  final String? id;
  final String groupId;
  final String userId;

  GroupMembership({this.id, required this.groupId, required this.userId});
}

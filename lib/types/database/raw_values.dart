
// mattermost_flutter
// See LICENSE.txt for license information.

/// Dart class representing AppInfo.
class AppInfo {
  final String buildNumber;
  final int createdAt;
  final String versionNumber;

  AppInfo({required this.buildNumber, required this.createdAt, required this.versionNumber});
}

/// Dart class representing ChannelInfo.
class ChannelInfo {
  final String id;
  final int guestCount;
  final String header;
  final int memberCount;
  final int pinnedPostCount;
  final int filesCount;
  final String purpose;

  ChannelInfo({required this.id, required this.guestCount, required this.header, required this.memberCount, required this.pinnedPostCount, required this.filesCount, required this.purpose});
}

/// Dart class representing Draft.
class Draft {
  final String channelId;
  final List<FileInfo>? files;
  final String? message;
  final String rootId;
  final PostMetadata? metadata;

  Draft({required this.channelId, this.files, this.message, required this.rootId, this.metadata});
}

/// Dart class representing MyTeam.
class MyTeam {
  final String id;
  final String roles;

  MyTeam({required this.id, required this.roles});
}

/// Dart class representing PostsInChannel.
class PostsInChannel {
  final String? id;
  final String channelId;
  final int earliest;
  final int latest;

  PostsInChannel({this.id, required this.channelId, required this.earliest, required this.latest});
}

/// Dart class representing PostsInThread.
class PostsInThread {
  final String? id;
  final int earliest;
  final int latest;
  final String rootId;

  PostsInThread({this.id, required this.earliest, required this.latest, required this.rootId});
}

/// Dart class representing Metadata.
class Metadata {
  final PostMetadata data;
  final String id;

  Metadata({required this.data, required this.id});
}

/// Dart class representing ReactionsPerPost.
class ReactionsPerPost {
  final String postId;
  final List<Reaction> reactions;

  ReactionsPerPost({required this.postId, required this.reactions});
}

/// Dart class representing SessionExpiration.
class SessionExpiration {
  final String id;
  final String notificationId;
  final int expiresAt;

  SessionExpiration({required this.id, required this.notificationId, required this.expiresAt});
}

/// Dart class representing IdValue.
class IdValue {
  final String id;
  final dynamic value;

  IdValue({required this.id, this.value});
}

/// Dart class representing ParticipantsPerThread.
class ParticipantsPerThread {
  final String threadId;
  final List<ThreadParticipant> participants;

  ParticipantsPerThread({required this.threadId, required this.participants});
}

/// Dart class representing TeamChannelHistory.
class TeamChannelHistory {
  final String id;
  final List<String> channelIds;

  TeamChannelHistory({required this.id, required this.channelIds});
}

/// Dart class representing TeamSearchHistory.
class TeamSearchHistory {
  final int createdAt;
  final String displayTerm;
  final String term;
  final String teamId;

  TeamSearchHistory({required this.createdAt, required this.displayTerm, required this.term, required this.teamId});
}

/// Dart class representing TermsOfService.
class TermsOfService {
  final String id;
  final int acceptedAt;
  final int createAt;
  final String userId;
  final String text;

  TermsOfService({required this.id, required this.acceptedAt, required this.createAt, required this.userId, required this.text});
}

/// Dart class representing ThreadInTeam.
class ThreadInTeam {
  final String threadId;
  final String teamId;

  ThreadInTeam({required this.threadId, required this.teamId});
}

/// Dart class representing TeamThreadsSync.
class TeamThreadsSync {
  final String id;
  final int earliest;
  final int latest;

  TeamThreadsSync({required this.id, required this.earliest, required this.latest});
}


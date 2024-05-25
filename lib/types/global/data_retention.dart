// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class GlobalDataRetentionPolicy {
  final bool fileDeletionEnabled;
  final int fileRetentionCutoff;
  final bool messageDeletionEnabled;
  final int messageRetentionCutoff;

  GlobalDataRetentionPolicy({
    required this.fileDeletionEnabled,
    required this.fileRetentionCutoff,
    required this.messageDeletionEnabled,
    required this.messageRetentionCutoff,
  });
}

class TeamDataRetentionPolicy {
  final int postDuration;
  final String teamId;

  TeamDataRetentionPolicy({
    required this.postDuration,
    required this.teamId,
  });
}

class ChannelDataRetentionPolicy {
  final int postDuration;
  final String channelId;

  ChannelDataRetentionPolicy({
    required this.postDuration,
    required this.channelId,
  });
}

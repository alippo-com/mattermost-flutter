// Dart (Flutter)
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/index.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/team_threads_sync.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_in_team.dart';
import 'package:mattermost_flutter/types/database/models/servers/thread_participant.dart';

Future<ThreadModel> transformThreadRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as ThreadWithLastFetchedAt;
  final record = value.record as ThreadModel;
  final isCreateAction = action == OperationType.CREATE;

  final fieldsMapper = (ThreadModel thread) {
    thread.id = isCreateAction ? (raw?.id ?? thread.id) : record.id;
    thread.lastReplyAt = raw.lastReplyAt ?? record.lastReplyAt;
    thread.lastViewedAt = raw.lastViewedAt ?? record.lastViewedAt ?? 0;
    thread.replyCount = raw.replyCount;
    thread.isFollowing = raw.isFollowing ?? record.isFollowing;
    thread.unreadReplies = raw.unreadReplies ?? record.unreadReplies ?? 0;
    thread.unreadMentions = raw.unreadMentions ?? record.unreadMentions ?? 0;
    thread.viewedAt = record.viewedAt ?? 0;
    thread.lastFetchedAt = (record.lastFetchedAt ?? 0).max(raw.lastFetchedAt ?? 0);
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: THREAD,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<ThreadModel>;
}

Future<ThreadParticipantModel> transformThreadParticipantRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as ThreadParticipant;

  final fieldsMapper = (ThreadParticipantModel participant) {
    participant.threadId = raw.threadId;
    participant.userId = raw.id;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: THREAD_PARTICIPANT,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<ThreadParticipantModel>;
}

Future<ThreadInTeamModel> transformThreadInTeamRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as ThreadInTeam;

  final fieldsMapper = (ThreadInTeamModel threadInTeam) {
    threadInTeam.threadId = raw.threadId;
    threadInTeam.teamId = raw.teamId;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: THREADS_IN_TEAM,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<ThreadInTeamModel>;
}

Future<TeamThreadsSyncModel> transformTeamThreadsSyncRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as TeamThreadsSync;
  final record = value.record as TeamThreadsSyncModel;
  final isCreateAction = action == OperationType.CREATE;

  final fieldsMapper = (TeamThreadsSyncModel teamThreadsSync) {
    teamThreadsSync.id = isCreateAction ? (raw?.id ?? teamThreadsSync.id) : record.id;
    teamThreadsSync.earliest = raw.earliest ?? record.earliest;
    teamThreadsSync.latest = raw.latest ?? record.latest;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: TEAM_THREADS_SYNC,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<TeamThreadsSyncModel>;
}

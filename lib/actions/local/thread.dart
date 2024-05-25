Future<void> updateThread(String serverUrl, String threadId, {int? replyCount, int? viewedAt, int? lastViewedAt, int? unreadMentions, int? unreadReplies, bool? isFollowing, bool prepareRecordsOnly = false}) async {
  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = databaseAndOperator.database;
    final operator = databaseAndOperator.operator;
    final thread = await getThreadById(database, threadId);
    if (thread == null) {
      throw Exception('Thread not found');
    }

    final model = thread.prepareUpdate((record) {
      record.isFollowing = isFollowing ?? record.isFollowing;
      record.replyCount = replyCount ?? record.replyCount;
      record.lastViewedAt = lastViewedAt ?? record.lastViewedAt;
      record.viewedAt = viewedAt ?? record.viewedAt;
      record.unreadMentions = unreadMentions ?? record.unreadMentions;
      record.unreadReplies = unreadReplies ?? record.unreadReplies;
    });
    if (!prepareRecordsOnly) {
      await operator.batchRecords([model], 'updateThread');
    }
    return {'model': model};
  } catch (error) {
    logError('Failed updateThread', error);
    return {'error': error};
  }
}

Future<void> updateTeamThreadsSync(String serverUrl, TeamThreadsSync data, {bool prepareRecordsOnly = false}) async {
  try {
    final databaseAndOperator = await DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final operator = databaseAndOperator.operator;
    final models = await operator.handleTeamThreadsSync({'data': [data], 'prepareRecordsOnly': prepareRecordsOnly});
    if (!prepareRecordsOnly) {
      await operator.batchRecords(models, 'updateTeamThreadsSync');
    }
    return {'models': models};
  } catch (error) {
    logError('Failed updateTeamThreadsSync', error);
    return {'error': error};
  }
}

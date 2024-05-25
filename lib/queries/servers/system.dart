
Future<Map<String, dynamic>> setCurrentUserId(ServerDataOperator operator, String userId) async {
  try {
    final models = await prepareCommonSystemValues(operator, PrepareCommonSystemValuesArgs(currentUserId: userId));
    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'setCurrentChannelId');
    }

    return {'currentUserId': userId};
  } catch (error) {
    return {'error': error};
  }
}

Future<Map<String, dynamic>> setCurrentChannelId(ServerDataOperator operator, String channelId) async {
  try {
    final models = await prepareCommonSystemValues(operator, PrepareCommonSystemValuesArgs(currentChannelId: channelId));
    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'setCurrentChannelId');
    }

    return {'currentChannelId': channelId};
  } catch (error) {
    return {'error': error};
  }
}

Future<Map<String, dynamic>> setCurrentTeamId(ServerDataOperator operator, String teamId) async {
  try {
    final models = await prepareCommonSystemValues(operator, PrepareCommonSystemValuesArgs(currentTeamId: teamId));
    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'setCurrentTeamId');
    }

    return {'currentTeamId': teamId};
  } catch (error) {
    logError(error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> setCurrentTeamAndChannelId(ServerDataOperator operator, {String? teamId, String? channelId}) async {
  try {
    final models = await prepareCommonSystemValues(operator, PrepareCommonSystemValuesArgs(currentTeamId: teamId, currentChannelId: channelId));
    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'setCurrentTeamAndChannelId');
    }

    return {'currentTeamId': teamId, 'currentChannelId': channelId};
  } catch (error) {
    return {'error': error};
  }
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/database/operations.dart';
import 'package:mattermost_flutter/types/database.dart';
import 'package:mattermost_flutter/types/models/reaction.dart';

const REACTION = MM_TABLES.SERVER['REACTION'];

/// transformReactionRecord: Prepares a record of the SERVER database 'Reaction' table for update or create actions.
/// @param {TransformerArgs} operator
/// @param {Database} operator.database
/// @param {RecordPair} operator.value
/// @returns {Future<ReactionModel>}
Future<ReactionModel> transformReactionRecord({required String action, required Database database, required RecordPair value}) async {
  final raw = value.raw as Reaction;
  final record = value.record as ReactionModel;
  final isCreateAction = action == OperationType.CREATE;

  // id of reaction comes from server response
  void fieldsMapper(ReactionModel reaction) {
    reaction.id = isCreateAction ? (raw.id ?? reaction.id) : record.id;
    reaction.userId = raw.userId;
    reaction.postId = raw.postId;
    reaction.emojiName = raw.emojiName;
    reaction.createAt = raw.createAt;
  }

  return await prepareBaseRecord(
    action: action,
    database: database,
    tableName: REACTION,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as ReactionModel;
}

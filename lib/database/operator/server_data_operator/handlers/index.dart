import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/base_data_operator.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/general.dart';
import 'package:mattermost_flutter/database/operator/utils/general.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/reaction.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/reaction.dart';

import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart';
import 'package:mattermost_flutter/types/database/models/servers/reaction.dart';
import 'package:mattermost_flutter/types/database/models/servers/role.dart';
import 'package:mattermost_flutter/types/database/models/servers/system.dart';

const CONFIG = MM_TABLES.SERVER.CONFIG;
const CUSTOM_EMOJI = MM_TABLES.SERVER.CUSTOM_EMOJI;
const ROLE = MM_TABLES.SERVER.ROLE;
const SYSTEM = MM_TABLES.SERVER.SYSTEM;
const REACTION = MM_TABLES.SERVER.REACTION;

class ServerDataOperatorBase extends BaseDataOperator {
  Future<List<RoleModel>> handleRole({
    required List<RoleModel> roles,
    bool prepareRecordsOnly = true,
  }) async {
    if (roles.isEmpty) {
      logWarning('An empty or undefined "roles" array has been passed to the handleRole');
      return [];
    }

    return this.handleRecords(
      fieldName: 'id',
      transformer: transformRoleRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: getUniqueRawsBy(roles, 'id'),
      tableName: ROLE,
      functionName: 'handleRole',
    );
  }

  Future<List<CustomEmojiModel>> handleCustomEmojis({
    required List<CustomEmojiModel> emojis,
    bool prepareRecordsOnly = true,
  }) async {
    if (emojis.isEmpty) {
      logWarning('An empty or undefined "emojis" array has been passed to the handleCustomEmojis');
      return [];
    }

    return this.handleRecords(
      fieldName: 'name',
      transformer: transformCustomEmojiRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: getUniqueRawsBy(emojis, 'name'),
      tableName: CUSTOM_EMOJI,
      functionName: 'handleCustomEmojis',
    );
  }

  Future<List<SystemModel>> handleSystem({
    required List<SystemModel> systems,
    bool prepareRecordsOnly = true,
  }) async {
    if (systems.isEmpty) {
      logWarning('An empty or undefined "systems" array has been passed to the handleSystem');
      return [];
    }

    return this.handleRecords(
      fieldName: 'id',
      transformer: transformSystemRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: getUniqueRawsBy(systems, 'id'),
      tableName: SYSTEM,
      functionName: 'handleSystem',
    );
  }

  Future<void> handleConfigs({
    required List<dynamic> configs,
    required List<dynamic> configsToDelete,
    bool prepareRecordsOnly = true,
  }) async {
    if (configs.isEmpty && configsToDelete.isEmpty) {
      logWarning('An empty or undefined "configs" and "configsToDelete" arrays have been passed to the handleConfigs');
      return;
    }

    await this.handleRecords(
      fieldName: 'id',
      transformer: transformConfigRecord,
      prepareRecordsOnly: prepareRecordsOnly,
      createOrUpdateRawValues: getUniqueRawsBy(configs, 'id'),
      tableName: CONFIG,
      functionName: 'handleConfigs',
      deleteRawValues: configsToDelete,
    );
  }

  Future<List<dynamic>> handleReactions({
    required List<dynamic> postsReactions,
    bool prepareRecordsOnly = true,
    bool skipSync = false,
  }) async {
    final List<dynamic> batchRecords = [];

    if (postsReactions.isEmpty) {
      logWarning('An empty or undefined "postsReactions" array has been passed to the handleReactions method');
      return [];
    }

    for (final postReactions in postsReactions) {
      final postId = postReactions['post_id'];
      final reactions = postReactions['reactions'];
      final reactionResults = await sanitizeReactions(
        database: this.database,
        postId: postId,
        rawReactions: reactions,
        skipSync: skipSync,
      );

      final createReactions = reactionResults['createReactions'];
      final deleteReactions = reactionResults['deleteReactions'];

      if (createReactions.isNotEmpty) {
        final reactionsRecords = await this.prepareRecords(
          createRaws: createReactions,
          transformer: transformReactionRecord,
          tableName: REACTION,
        );
        batchRecords.addAll(reactionsRecords);
      }

      if (deleteReactions.isNotEmpty && !skipSync) {
        for (final outCast in deleteReactions) {
          outCast.prepareDestroyPermanently();
        }
        batchRecords.addAll(deleteReactions);
      }
    }

    if (prepareRecordsOnly) {
      return batchRecords;
    }

    if (batchRecords.isNotEmpty) {
      await this.batchRecords(batchRecords, 'handleReactions');
    }

    return batchRecords;
  }

  Future<List<dynamic>> execute({
    required List<dynamic> createRaws,
    required dynamic transformer,
    required String tableName,
    required List<dynamic> updateRaws,
  }) async {
    final models = await this.prepareRecords(
      tableName: tableName,
      createRaws: createRaws,
      updateRaws: updateRaws,
      transformer: transformer,
    );

    if (models.isNotEmpty) {
      await this.batchRecords(models, 'execute');
    }

    return models;
  }
}

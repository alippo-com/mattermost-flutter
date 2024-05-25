
// Dart (Flutter)
import 'package:mattermost_flutter/types/database/models/servers/config.dart';
import 'package:mattermost_flutter/types/database/models/servers/custom_emoji.dart';
import 'package:mattermost_flutter/types/database/models/servers/role.dart';
import 'package:mattermost_flutter/types/database/models/servers/system.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator/transformers/index.dart';

Future<CustomEmojiModel> transformCustomEmojiRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as CustomEmoji;
  final record = value.record as CustomEmojiModel;
  final isCreateAction = action == OperationType.CREATE;

  final fieldsMapper = (CustomEmojiModel emoji) {
    emoji.id = isCreateAction ? (raw?.id ?? emoji.id) : record.id;
    emoji.name = raw.name;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: CUSTOM_EMOJI,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<CustomEmojiModel>;
}

Future<RoleModel> transformRoleRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as Role;
  final record = value.record as RoleModel;
  final isCreateAction = action == OperationType.CREATE;

  final fieldsMapper = (RoleModel role) {
    role.id = isCreateAction ? (raw?.id ?? role.id) : record.id;
    role.name = raw?.name;
    role.permissions = raw?.permissions;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: ROLE,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<RoleModel>;
}

Future<SystemModel> transformSystemRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as IdValue;

  final fieldsMapper = (SystemModel system) {
    system.id = raw?.id;
    system.value = raw?.value;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: SYSTEM,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<SystemModel>;
}

Future<ConfigModel> transformConfigRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as IdValue;

  final fieldsMapper = (ConfigModel config) {
    config.id = raw?.id;
    config.value = raw?.value as String;
  };

  return prepareBaseRecord(
    action: action,
    database: database,
    tableName: CONFIG,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as Future<ConfigModel>;
}

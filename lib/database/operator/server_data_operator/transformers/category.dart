import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/database/operator/utils/index.dart';
import 'package:mattermost_flutter/types/database/database.dart';
import 'package:mattermost_flutter/types/database/models/servers/category.dart';
import 'package:mattermost_flutter/types/database/models/servers/category_channel.dart';

const CATEGORY = MM_TABLES.SERVER.CATEGORY;
const CATEGORY_CHANNEL = MM_TABLES.SERVER.CATEGORY_CHANNEL;

Future<CategoryModel> transformCategoryRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as Category;
  final record = value.record as CategoryModel;
  final isCreateAction = action == OperationType.CREATE;

  CategoryModel fieldsMapper(CategoryModel category) {
    category.id = isCreateAction ? (raw.id ?? category.id) : record.id;
    category.displayName = raw.displayName;
    category.sorting = raw.sorting ?? 'recent';
    category.sortOrder = raw.sortOrder == 0 ? 0 : raw.sortOrder / 10;
    category.muted = raw.muted ?? false;
    category.collapsed = isCreateAction ? false : record.collapsed;
    category.type = raw.type;
    category.teamId = raw.teamId;
    return category;
  }

  return await prepareBaseRecord(
    action: action,
    database: database,
    tableName: CATEGORY,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as CategoryModel;
}

Future<CategoryChannelModel> transformCategoryChannelRecord({
  required String action,
  required Database database,
  required RecordPair value,
}) async {
  final raw = value.raw as CategoryChannel;
  final record = value.record as CategoryChannelModel;
  final isCreateAction = action == OperationType.CREATE;

  CategoryChannelModel fieldsMapper(CategoryChannelModel categoryChannel) {
    categoryChannel.id = isCreateAction ? (raw.id ?? categoryChannel.id) : record.id;
    categoryChannel.channelId = raw.channelId;
    categoryChannel.categoryId = raw.categoryId;
    categoryChannel.sortOrder = raw.sortOrder;
    return categoryChannel;
  }

  return await prepareBaseRecord(
    action: action,
    database: database,
    tableName: CATEGORY_CHANNEL,
    value: value,
    fieldsMapper: fieldsMapper,
  ) as CategoryChannelModel;
}

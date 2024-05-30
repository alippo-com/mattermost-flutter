// categories.dart

import 'package:watermelondb/watermelondb.dart';
import 'package:mattermost_flutter/constants/categories.dart';
import 'package:mattermost_flutter/constants/database.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/servers/category.dart';
import 'package:mattermost_flutter/types/servers/category_channel.dart';
import 'package:mattermost_flutter/database/operator/server_data_operator.dart';

const CATEGORY = MM_TABLES.SERVER.CATEGORY;
const CATEGORY_CHANNEL = MM_TABLES.SERVER.CATEGORY_CHANNEL;

Future<CategoryModel?> getCategoryById(Database database, String categoryId) async {
  try {
    final record = await database.collections.get<CategoryModel>(CATEGORY).find(categoryId);
    return record;
  } catch {
    return null;
  }
}

Query<CategoryModel> queryCategoriesById(Database database, List<String> categoryIds) {
  return database.get<CategoryModel>(CATEGORY).query(Q.where('id', Q.oneOf(categoryIds)));
}

Query<CategoryModel> queryCategoriesByTeamIds(Database database, List<String> teamIds) {
  return database.get<CategoryModel>(CATEGORY).query(Q.where('team_id', Q.oneOf(teamIds)));
}

Query<CategoryChannelModel> queryCategoryChannelsByChannelId(Database database, String channelId) {
  return database.get<CategoryChannelModel>(CATEGORY_CHANNEL).query(Q.where('channel_id', Q.eq(channelId)));
}

Future<List<Model>> prepareCategoriesAndCategoriesChannels(ServerDataOperator operator, List<CategoryWithChannels> categories, {bool prune = false}) async {
  try {
    final database = operator.database;
    final modelPromises = [
      prepareCategories(operator, categories),
      prepareCategoryChannels(operator, categories),
    ];

    final models = await Future.wait(modelPromises);
    final flattenedModels = models.expand((modelList) => modelList).toList();

    final teamIdToChannelIds = <String, Set<String>>{};
    for (var category in categories) {
      final value = teamIdToChannelIds.putIfAbsent(category.teamId, () => <String>{});
      category.channelIds.forEach(value.add);
    }

    if (prune && categories.isNotEmpty) {
      final remoteCategoryIds = categories.map((cat) => cat.id).toSet();
      final teamIds = pluckUnique('team_id', categories).cast<String>();
      final localCategories = await queryCategoriesByTeamIds(database, teamIds).fetch();

      for (var localCategory in localCategories) {
        final localCategoryChannels = await localCategory.categoryChannels.fetch();

        if (remoteCategoryIds.contains(localCategory.id)) {
          for (var localCC in localCategoryChannels) {
            if (!teamIdToChannelIds[localCategory.teamId]?.contains(localCC.channelId) ?? false) {
              flattenedModels.add(localCC.prepareDestroyPermanently());
            }
          }
        } else {
          for (var cc in localCategoryChannels) {
            flattenedModels.add(cc.prepareDestroyPermanently());
          }
          flattenedModels.add(localCategory.prepareDestroyPermanently());
        }
      }
    }

    return flattenedModels;
  } catch (error) {
    logDebug('error while preparing categories and categories channels', error);
    return [];
  }
}

Future<List<Model>> prepareCategories(ServerDataOperator operator, [List<CategoryWithChannels>? categories]) {
  return operator.handleCategories(categories: categories, prepareRecordsOnly: true);
}

Future<List<CategoryChannelModel>> prepareCategoryChannels(ServerDataOperator operator, [List<CategoryWithChannels>? categories]) async {
  try {
    final categoryChannels = <CategoryChannel>[];

    categories?.forEach((category) {
      category.channelIds.asMap().forEach((index, channelId) {
        categoryChannels.add(CategoryChannel(
          id: makeCategoryChannelId(category.teamId, channelId),
          categoryId: category.id,
          channelId: channelId,
          sortOrder: index,
        ));
      });
    });

    return operator.handleCategoryChannels(categoryChannels: categoryChannels, prepareRecordsOnly: true);
  } catch (e) {
    return [];
  }
}

Future<List<Model>> prepareDeleteCategory(CategoryModel category) async {
  final preparedModels = [category.prepareDestroyPermanently()];

  final associatedChildren = [category.categoryChannels];
  await Future.wait(associatedChildren.map((children) async {
    final models = await children.fetch();
    models.forEach((model) => preparedModels.add(model.prepareDestroyPermanently()));
  }));

  return preparedModels;
}

Query<CategoryModel> queryChannelCategory(Database database, String teamId, String channelId) {
  return database.get<CategoryModel>(CATEGORY).query(Q.on(CATEGORY_CHANNEL, Q.where('id', makeCategoryChannelId(teamId, channelId))));
}

Future<CategoryModel?> getChannelCategory(Database database, String teamId, String channelId) async {
  final result = await queryChannelCategory(database, teamId, channelId).fetch();
  if (result.isNotEmpty) {
    return result.first;
  }
  return null;
}

Future<bool> getIsChannelFavorited(Database database, String teamId, String channelId) async {
  final result = await queryChannelCategory(database, teamId, channelId).fetch();
  if (result.isNotEmpty) {
    return result.first.type == FAVORITES_CATEGORY;
  }
  return false;
}

Stream<bool> observeIsChannelFavorited(Database database, String teamId, String channelId) {
  return queryChannelCategory(database, teamId, channelId)
      .observe()
      .switchMap((result) => Stream.value(result.isNotEmpty && result.first.type == FAVORITES_CATEGORY))
      .distinct();
}

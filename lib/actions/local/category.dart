import 'package:mattermost_flutter/database_manager.dart';
import 'package:mattermost_flutter/models/channel_model.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/queries/categories.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/team.dart';
import 'package:mattermost_flutter/utils/channel.dart';

Future<Map<String, dynamic>> deleteCategory(String serverUrl, String categoryId) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final category = await getCategoryById(database, categoryId);

    if (category != null) {
      await database.writeTxn((txn) async {
        await txn.delete(category);
      });
    }

    return {'category': category};
  } catch (error) {
    logError('FAILED TO DELETE CATEGORY', categoryId);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> storeCategories(
    String serverUrl, List<CategoryWithChannels> categories, {bool prune = false, bool prepareRecordsOnly = false}) async {
  try {
    final operator = DatabaseManager.getServerDatabaseAndOperator(serverUrl).operator;
    final models = await prepareCategoriesAndCategoriesChannels(operator, categories, prune);

    if (prepareRecordsOnly) {
      return {'models': models};
    }

    if (models.isNotEmpty) {
      await operator.batchRecords(models, 'storeCategories');
    }

    return {'models': models};
  } catch (error) {
    logError('FAILED TO STORE CATEGORIES', error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> toggleCollapseCategory(String serverUrl, String categoryId) async {
  try {
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final category = await getCategoryById(database, categoryId);

    if (category != null) {
      await database.writeTxn((txn) async {
        category.collapsed = !category.collapsed;
        await txn.update(category);
      });
    }

    return {'category': category};
  } catch (error) {
    logError('FAILED TO COLLAPSE CATEGORY', categoryId, error);
    return {'error': error};
  }
}

Future<Map<String, dynamic>> addChannelToDefaultCategory(
    String serverUrl, dynamic channel, {bool prepareRecordsOnly = false}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;

    final teamId = channel.teamId ?? channel.team_id;
    final userId = await getCurrentUserId(database);

    if (userId == null) {
      return {'error': 'no current user id'};
    }

    final categoriesWithChannels = <CategoryWithChannels>[];

    if (isDMorGM(channel)) {
      final allTeamIds = await queryMyTeams(database).fetchIds();
      final categories = await queryCategoriesByTeamIds(database, allTeamIds).fetch();
      final channelCategories = categories.where((c) => c.type == DMS_CATEGORY).toList();

      for (final cc in channelCategories) {
        final cwc = await cc.toCategoryWithChannels();
        cwc.channel_ids.insert(0, channel.id);
        categoriesWithChannels.add(cwc);
      }
    } else {
      final cwc = await prepareAddNonGMDMChannelToDefaultCategory(database, teamId, channel.id);
      if (cwc != null) {
        categoriesWithChannels.add(cwc);
      }
    }

    final models = await prepareCategoryChannels(operator, categoriesWithChannels);

    if (models.isNotEmpty && !prepareRecordsOnly) {
      await operator.batchRecords(models, 'addChannelToDefaultCategory');
    }

    return {'models': models};
  } catch (error) {
    logError('Failed to add channel to default category', error);
    return {'error': error};
  }
}

Future<CategoryWithChannels?> prepareAddNonGMDMChannelToDefaultCategory(
    Database database, String teamId, String channelId) async {
  final categories = await queryCategoriesByTeamIds(database, [teamId]).fetch();
  final channelCategory = categories.firstWhere((category) => category.type == CHANNELS_CATEGORY, orElse: () => null);

  if (channelCategory != null) {
    final cwc = await channelCategory.toCategoryWithChannels();
    if (!cwc.channel_ids.contains(channelId)) {
      cwc.channel_ids.insert(0, channelId);
      return cwc;
    }
  }
  return null;
}

Future<Map<String, dynamic>> handleConvertedGMCategories(
    String serverUrl, String channelId, String targetTeamID, {bool prepareRecordsOnly = false}) async {
  try {
    final dbOperator = DatabaseManager.getServerDatabaseAndOperator(serverUrl);
    final database = dbOperator.database;
    final operator = dbOperator.operator;

    final categoryChannels = await queryCategoryChannelsByChannelId(database, channelId).fetch();
    final categories = await queryCategoriesByTeamIds(database, [targetTeamID]).fetch();
    final channelCategory = categories.firstWhere((category) => category.type == CHANNELS_CATEGORY, orElse: () => null);

    if (channelCategory == null) {
      logError('Failed to find default category when handling category of converted GM');
      return {'error': 'Failed to find default category'};
    }

    final models = <Model>[];

    for (final categoryChannel in categoryChannels) {
      if (categoryChannel.categoryId != channelCategory.id) {
        models.add(categoryChannel.prepareDestroyPermanently());
      }
    }

    final cwc = await prepareAddNonGMDMChannelToDefaultCategory(database, targetTeamID, channelId);
    if (cwc != null) {
      final model = await prepareCategoryChannels(operator, [cwc]);
      models.addAll(model);
    } else {
      logDebug('handleConvertedGMCategories: could not find channel category of target team');
    }

    if (models.isNotEmpty && !prepareRecordsOnly) {
      await operator.batchRecords(models, 'putGMInCorrectCategory');
    }

    return {'models': models};
  } catch (error) {
    logError('Failed to handle category update for GM converted to channel', error);
    return {'error': error};
  }
}

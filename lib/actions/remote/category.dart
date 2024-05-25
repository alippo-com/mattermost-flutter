// Converted Dart code from TypeScript

import 'package:mattermost_flutter/actions/local/category.dart';
import 'package:mattermost_flutter/constants/general.dart';
import 'package:mattermost_flutter/constants/categories.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/managers/network_manager.dart';
import 'package:mattermost_flutter/queries/servers/categories.dart';
import 'package:mattermost_flutter/queries/servers/channel.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/utils/errors.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/utils/snack_bar.dart';

import 'session.dart';

class CategoriesRequest {
  List<CategoryWithChannels>? categories;
  dynamic error;

  CategoriesRequest({this.categories, this.error});
}

Future<CategoriesRequest> fetchCategories(
    String serverUrl, String teamId, {bool prune = false, bool fetchOnly = false}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final response = await client.getCategories('me', teamId);
    final List<CategoryWithChannels> categories = response['categories'];

    if (!fetchOnly) {
      storeCategories(serverUrl, categories, prune: prune);
    }

    return CategoriesRequest(categories: categories);
  } catch (error) {
    logDebug('error on fetchCategories', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return CategoriesRequest(error: error);
  }
}

Future<Map<String, dynamic>> toggleFavoriteChannel(
    String serverUrl, String channelId, {bool showSnackBar = false}) async {
  try {
    final client = NetworkManager.getClient(serverUrl);
    final database = DatabaseManager.getServerDatabaseAndOperator(serverUrl).database;
    final channel = await getChannelById(database, channelId);

    if (channel == null) {
      return {'error': 'channel not found'};
    }

    final currentTeamId = await getCurrentTeamId(database);
    final teamId = channel.teamId ?? currentTeamId;
    final currentCategory = await getChannelCategory(database, teamId, channelId);

    if (currentCategory == null) {
      return {'error': 'channel does not belong to a category'};
    }

    final categories = await queryCategoriesByTeamIds(database, [teamId]).fetch();
    final isFavorited = currentCategory.type == FAVORITES_CATEGORY;
    CategoryWithChannels targetWithChannels;
    CategoryWithChannels favoriteWithChannels;

    if (isFavorited) {
      final categoryType = (channel.type == General.DM_CHANNEL || channel.type == General.GM_CHANNEL)
          ? DMS_CATEGORY
          : CHANNELS_CATEGORY;
      final targetCategory = categories.firstWhere((c) => c.type == categoryType, orElse: () => null);

      if (targetCategory == null) {
        return {'error': 'target category not found'};
      }

      targetWithChannels = await targetCategory.toCategoryWithChannels();
      targetWithChannels.channelIds.insert(0, channelId);

      favoriteWithChannels = await currentCategory.toCategoryWithChannels();
      final channelIndex = favoriteWithChannels.channelIds.indexOf(channelId);
      favoriteWithChannels.channelIds.removeAt(channelIndex);
    } else {
      final favoritesCategory = categories.firstWhere((c) => c.type == FAVORITES_CATEGORY, orElse: () => null);

      if (favoritesCategory == null) {
        return {'error': 'No favorites category'};
      }

      favoriteWithChannels = await favoritesCategory.toCategoryWithChannels();
      favoriteWithChannels.channelIds.insert(0, channelId);

      targetWithChannels = await currentCategory.toCategoryWithChannels();
      final channelIndex = targetWithChannels.channelIds.indexOf(channelId);
      targetWithChannels.channelIds.removeAt(channelIndex);
    }

    await client.updateChannelCategories('me', teamId, [targetWithChannels, favoriteWithChannels]);

    if (showSnackBar) {
      final onUndo = () => toggleFavoriteChannel(serverUrl, channelId, showSnackBar: false);
      showFavoriteChannelSnackbar(!isFavorited, onUndo);
    }

    return {'data': true};
  } catch (error) {
    logDebug('error on toggleFavoriteChannel', getFullErrorMessage(error));
    forceLogoutIfNecessary(serverUrl, error);
    return {'error': error};
  }
}

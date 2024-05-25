import 'package:mattermost_flutter/actions/local/category.dart';
import 'package:mattermost_flutter/actions/remote/category.dart';
import 'package:mattermost_flutter/database/manager.dart';
import 'package:mattermost_flutter/queries/servers/categories.dart';
import 'package:mattermost_flutter/utils/log.dart';
import 'package:mattermost_flutter/types/device.dart';

class WebsocketCategoriesMessage {
  final Broadcast broadcast;
  final Data data;

  WebsocketCategoriesMessage({required this.broadcast, required this.data});
}

class Broadcast {
  final String teamId;

  Broadcast({required this.teamId});
}

class Data {
  final String teamId;
  final String? category;
  final String categoryId;
  final String? updatedCategories;
  final List<String>? order;

  Data({required this.teamId, this.category, required this.categoryId, this.updatedCategories, this.order});
}

Future<void> addOrUpdateCategories(String serverUrl, List<CategoryWithChannels> categories) async {
  try {
    storeCategories(serverUrl, categories);
  } catch (e) {
    logError('Category WS: addOrUpdateCategories', e, categories);
  }
}

Future<void> handleCategoryCreatedEvent(String serverUrl, WebsocketCategoriesMessage msg) async {
  try {
    if (msg.data.category != null) {
      final category = jsonDecode(msg.data.category!);
      await addOrUpdateCategories(serverUrl, [category]);
    }
  } catch (e) {
    logError('Category WS: handleCategoryCreatedEvent', e, msg);

    if (msg.broadcast.teamId.isNotEmpty) {
      await fetchCategories(serverUrl, msg.broadcast.teamId);
    }
  }
}

Future<void> handleCategoryUpdatedEvent(String serverUrl, WebsocketCategoriesMessage msg) async {
  try {
    if (msg.data.updatedCategories != null) {
      final categories = jsonDecode(msg.data.updatedCategories!);
      await addOrUpdateCategories(serverUrl, categories);
    }
  } catch (e) {
    logError('Category WS: handleCategoryUpdatedEvent', e, msg);
    
    if (msg.broadcast.teamId.isNotEmpty) {
      await fetchCategories(serverUrl, msg.broadcast.teamId, true);
    }
  }
}

Future<void> handleCategoryDeletedEvent(String serverUrl, WebsocketCategoriesMessage msg) async {
  try {
    if (msg.data.categoryId.isNotEmpty) {
      await deleteCategory(serverUrl, msg.data.categoryId);
    }

    if (msg.broadcast.teamId.isNotEmpty) {
      await fetchCategories(serverUrl, msg.broadcast.teamId);
    }
  } catch (e) {
    logError('Category WS: handleCategoryDeletedEvent', e, msg);
  }
}

Future<void> handleCategoryOrderUpdatedEvent(String serverUrl, WebsocketCategoriesMessage msg) async {
  try {
    final databaseManager = DatabaseManager();
    final database = databaseManager.getServerDatabase(serverUrl);
    final operator = databaseManager.getServerOperator(serverUrl);

    if (msg.data.order != null && msg.data.order!.isNotEmpty) {
      final order = msg.data.order!;
      final categories = await queryCategoriesById(database, order).fetch();
      
      categories.forEach((c) {
        c.prepareUpdate(() {
          c.sortOrder = order.indexWhere((id) => id == c.id);
        });
      });
      
      await operator.batchRecords(categories, 'handleCategoryOrderUpdatedEvent');
    }
  } catch (e) {
    logError('Category WS: handleCategoryOrderUpdatedEvent', e, msg);

    if (msg.broadcast.teamId.isNotEmpty) {
      await fetchCategories(serverUrl, msg.data.teamId);
    }
  }
}

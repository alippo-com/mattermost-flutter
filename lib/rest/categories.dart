// Copyright (c) 2021-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/base.dart';

mixin ClientCategoriesMix on ClientBase {
  Future<CategoriesWithOrder> getCategories(String userId, String teamId);
  Future<List<String>> getCategoriesOrder(String userId, String teamId);
  Future<Category> getCategory(String userId, String teamId, String categoryId);
  Future<CategoriesWithOrder> updateChannelCategories(String userId, String teamId, List<CategoryWithChannels> categories);
}

class ClientCategories extends ClientBase with ClientCategoriesMix {
  @override
  Future<CategoriesWithOrder> getCategories(String userId, String teamId) async {
    return doFetch(
      getCategoriesRoute(userId, teamId),
      method: 'GET',
    );
  }

  @override
  Future<List<String>> getCategoriesOrder(String userId, String teamId) async {
    return doFetch(
      getCategoriesOrderRoute(userId, teamId),
      method: 'GET',
    );
  }

  @override
  Future<Category> getCategory(String userId, String teamId, String categoryId) async {
    return doFetch(
      getCategoryRoute(userId, teamId, categoryId),
      method: 'GET',
    );
  }

  @override
  Future<CategoriesWithOrder> updateChannelCategories(String userId, String teamId, List<CategoryWithChannels> categories) async {
    return doFetch(
      getCategoriesRoute(userId, teamId),
      method: 'PUT',
      body: categories,
    );
  }
}

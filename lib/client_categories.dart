// Copyright (c) 2020-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:http/http.dart' as http;
import 'client_base.dart';

class ClientCategories with ClientBase {
  Future<Map<String, dynamic>> getCategories(String userId, String teamId) async {
    var response = await http.get(Uri.parse('${getCategoriesRoute(userId, teamId)}'));
    return response.body;
  }

  Future<List<String>> getCategoriesOrder(String userId, String teamId) async {
    var response = await http.get(Uri.parse('${getCategoriesOrderRoute(userId, teamId)}'));
    return response.body;
  }

  Future<Map<String, dynamic>> getCategory(String userId, String teamId, String categoryId) async {
    var response = await http.get(Uri.parse('${getCategoryRoute(userId, teamId, categoryId)}'));
    return response.body;
  }

  Future<Map<String, dynamic>> updateChannelCategories(String userId, String teamId, List<Map<String, dynamic>> categories) async {
    var response = await http.put(Uri.parse('${getCategoriesRoute(userId, teamId)}'), body: categories);
    return response.body;
  }
}

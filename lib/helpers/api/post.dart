// mattermost_flutter
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

/// Filters posts in ordered array. Returns a Map of filtered posts.
Map<String, dynamic> filterPostsInOrderedArray(
    Map<String, dynamic>? posts, List<String>? order) {
  Map<String, dynamic> result = {};

  if (posts == null || order == null) {
    return result;
  }

  for (String id in order) {
    if (posts.containsKey(id)) {
      result[id] = posts[id];
    }
  }

  return result;
}

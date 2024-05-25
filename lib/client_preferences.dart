
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'base.dart';  // Assuming base.dart exists and contains converted code of base.ts

abstract class ClientPreferencesMix {
  Future<dynamic> savePreferences(String userId, List<PreferenceType> preferences);
  Future<dynamic> deletePreferences(String userId, List<PreferenceType> preferences);
  Future<List<PreferenceType>> getMyPreferences();
}

class ClientPreferences extends ClientPreferencesMix {
  @override
  Future<dynamic> savePreferences(String userId, List<PreferenceType> preferences) async {
    analytics?.trackAPI('action_posts_flag');
    return doFetch(
      '${getPreferencesRoute(userId)}',
      {'method': 'put', 'body': preferences},
    );
  }

  @override
  Future<List<PreferenceType>> getMyPreferences() async {
    return doFetch(
      '${getPreferencesRoute('me')}',
      {'method': 'get'},
    );
  }

  @override
  Future<dynamic> deletePreferences(String userId, List<PreferenceType> preferences) async {
    analytics?.trackAPI('action_posts_unflag');
    return doFetch(
      '${getPreferencesRoute(userId)}/delete',
      {'method': 'post', 'body': preferences},
    );
  }
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants/preferences.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/categories.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/typings/database/database.dart';
import 'package:mattermost_flutter/typings/database/models/servers/preference.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'categories.dart';

class EnhancedCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final currentTeamId = observeCurrentTeamId(database);
    final categories = currentTeamId.switchMap((ctid) => queryCategoriesByTeamIds(database, [ctid]).observeWithColumns(['sort_order']));

    final unreadsOnTopUserPreference = querySidebarPreferences(database, Preferences.CHANNEL_SIDEBAR_GROUP_UNREADS)
        .observeWithColumns(['value'])
        .switchMap((prefs) => Observable.just(getPreferenceValue<String>(prefs, Preferences.CATEGORIES.SIDEBAR_SETTINGS, Preferences.CHANNEL_SIDEBAR_GROUP_UNREADS)));

    final unreadsOnTopServerPreference = observeConfigBooleanValue(database, 'ExperimentalGroupUnreadChannels');

    final unreadsOnTop = unreadsOnTopServerPreference.combineLatest(unreadsOnTopUserPreference, (s, u) {
      if (u == null) {
        return s;
      }
      return u != 'false';
    });

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: categories,
          initialData: [],
        ),
        StreamProvider.value(
          value: observeOnlyUnreads(database),
          initialData: false,
        ),
        StreamProvider.value(
          value: unreadsOnTop,
          initialData: false,
        ),
      ],
      child: Categories(),
    );
  }
}

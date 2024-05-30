// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:provider/provider.dart';


class DisplaySettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final allowsThemeSwitching = observeConfigBooleanValue(database, 'EnableThemeSelection');
    final allowedThemeKeys = observeAllowedThemesKeys(database);

    final isThemeSwitchingEnabled = StreamProvider<bool>(
      create: (_) => allowsThemeSwitching.switchMap((ts) {
        return allowedThemeKeys.map((ath) => ts && ath.isNotEmpty);
      }),
      initialData: false,
    );

    return MultiProvider(
      providers: [
        isThemeSwitchingEnabled,
        StreamProvider.value(
          value: observeIsCRTEnabled(database),
          initialData: false,
        ),
        StreamProvider.value(
          value: observeCRTUserPreferenceDisplay(database),
          initialData: false,
        ),
        StreamProvider.value(
          value: queryDisplayNamePreferences(database)
              .observeWithColumns(['value'])
              .switchMap((preferences) {
            return Stream.value(
                getDisplayNamePreferenceAsBool(preferences, Preferences.USE_MILITARY_TIME));
          }),
          initialData: false,
        ),
        StreamProvider.value(
          value: observeCurrentUser(database),
          initialData: null,
        ),
      ],
      child: DisplaySettings(),
    );
  }
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class NotificationSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return MultiProvider(
      providers: [
        StreamProvider.value(
          value: observeCurrentUser(database),
          initialData: null,
        ),
        StreamProvider.value(
          value: observeIsCRTEnabled(database),
          initialData: false,
        ),
        StreamProvider.value(
          value: observeConfigBooleanValue(database, 'ExperimentalEnableAutomaticReplies'),
          initialData: false,
        ),
        StreamProvider.value(
          value: observeConfigBooleanValue(database, 'EnableEmailBatching'),
          initialData: false,
        ),
        StreamProvider.value(
          value: queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.NOTIFICATIONS)
              .observeWithColumns(['value']).switchMap((preferences) {
            return Stream.value(getPreferenceValue(preferences, Preferences.CATEGORIES.NOTIFICATIONS, Preferences.EMAIL_INTERVAL, Preferences.INTERVAL_NOT_SET));
          }),
          initialData: null,
        ),
        StreamProvider.value(
          value: observeConfigBooleanValue(database, 'SendEmailNotifications'),
          initialData: false,
        ),
      ],
      child: NotificationSettings(),
    );
  }
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:provider/provider.dart';

import 'notification_email.dart';

class NotificationEmailScreen extends StatelessWidget {
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
          value: observeConfigBooleanValue(database, 'EnableEmailBatching'),
          initialData: false,
        ),
        StreamProvider.value(
          value: queryPreferencesByCategoryAndName(database, Preferences.CATEGORIES.NOTIFICATIONS)
              .observeWithColumns(['value'])
              .switchMap((preferences) => Stream.value(
                  getPreferenceValue<String>(preferences, Preferences.CATEGORIES.NOTIFICATIONS, Preferences.EMAIL_INTERVAL, Preferences.INTERVAL_NOT_SET))),
          initialData: Preferences.INTERVAL_NOT_SET,
        ),
        StreamProvider.value(
          value: observeIsCRTEnabled(database),
          initialData: false,
        ),
        StreamProvider.value(
          value: observeConfigBooleanValue(database, 'SendEmailNotifications'),
          initialData: false,
        ),
      ],
      child: NotificationEmail(),
    );
  }
}


// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/screens/settings/display_clock/display_clock.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class DisplayClockContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    final currentUserId = observeCurrentUserId(database);
    final hasMilitaryTimeFormat = queryDisplayNamePreferences(database).valueChanges().switchMap(
          (preferences) => Stream.value(getDisplayNamePreferenceAsBool(preferences, Preferences.USE_MILITARY_TIME)),
        );

    return StreamBuilder<bool>(
      stream: hasMilitaryTimeFormat,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final militaryTime = snapshot.data ?? false;
        return DisplayClock(
          currentUserId: currentUserId,
          hasMilitaryTimeFormat: militaryTime,
        );
      },
    );
  }
}

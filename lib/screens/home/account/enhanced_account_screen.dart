// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter_watermelondb/flutter_watermelondb.dart';
import 'package:rxdart/rxdart.dart';

import 'types/system.dart';
import 'types/user.dart';
import 'utils/helpers.dart';

import 'account.dart';

class EnhancedAccountScreen extends StatelessWidget {
  final Database database;

  EnhancedAccountScreen({required this.database});

  @override
  Widget build(BuildContext context) {
    final showFullName = observeConfigBooleanValue(database, 'ShowFullName');
    final version = observeConfigValue(database, 'Version');
    final enableCustomUserStatuses = observeConfigBooleanValue(database, 'EnableCustomUserStatuses')
        .combineLatestWith(version, (cfg, v) => cfg && isMinimumServerVersion(v ?? '', 5, 36));

    final currentUser = observeCurrentUser(database);

    return AccountScreen(
      currentUser: currentUser,
      enableCustomUserStatuses: enableCustomUserStatuses,
      showFullName: showFullName,
    );
  }
}

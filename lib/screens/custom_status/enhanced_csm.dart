// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/screens/custom_status/custom_status.dart';

class EnhancedCSM extends StatelessWidget {
  final Database database;

  EnhancedCSM({required this.database});

  @override
  Widget build(BuildContext context) {
    final currentUser = observeCurrentUser(database);
    final recentCustomStatuses = observeRecentCustomStatus(database);
    final customStatusExpirySupported = observeIsCustomStatusExpirySupported(database);

    return CustomStatus(
      currentUser: currentUser,
      recentCustomStatuses: recentCustomStatuses,
      customStatusExpirySupported: customStatusExpirySupported,
    );
  }
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/thread.dart';
import 'package:mattermost_flutter/queries/user.dart';

import 'notification_push.dart'; // Assuming this file is also converted to Dart

class EnhancedNotificationPush extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);

    return StreamProvider<User>(
      create: (_) => observeCurrentUser(database),
      initialData: User.initial(),
      child: StreamProvider<bool>(
        create: (_) => observeIsCRTEnabled(database),
        initialData: false,
        child: StreamProvider<bool>(
          create: (_) => observeConfigBooleanValue(database, 'SendPushNotifications'),
          initialData: false,
          child: NotificationPush(),
        ),
      ),
    );
  }
}

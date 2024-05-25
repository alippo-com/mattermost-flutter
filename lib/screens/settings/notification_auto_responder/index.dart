// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/database.dart';
import 'package:mattermost_flutter/observables.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/widgets/notification_auto_responder.dart';

class WithDatabaseArgs {
  final Database database;

  WithDatabaseArgs(this.database);
}

class EnhancedNotificationAutoResponder extends StatelessWidget {
  final WithDatabaseArgs args;

  EnhancedNotificationAutoResponder({required this.args});

  @override
  Widget build(BuildContext context) {
    final currentUser = observeCurrentUser(args.database);

    return NotificationAutoResponder(currentUser: currentUser);
  }
}

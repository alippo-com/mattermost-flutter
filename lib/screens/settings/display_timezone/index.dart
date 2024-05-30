
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database.dart';
import 'package:mattermost_flutter/observables.dart';

class EnhancedDisplayTimezone extends StatelessWidget {
  final Database database;

  EnhancedDisplayTimezone({required this.database});

  @override
  Widget build(BuildContext context) {
    final currentUser = observeCurrentUser(database);

    return DisplayTimezone(currentUser: currentUser);
  }
}

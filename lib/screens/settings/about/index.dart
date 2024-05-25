// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database.dart';
import 'package:mattermost_flutter/observables.dart';
import 'package:mattermost_flutter/queries/servers/system.dart';
import 'package:mattermost_flutter/screens/settings/about/about.dart';
import 'package:mattermost_flutter/types/database/database.dart';

class EnhancedAbout extends StatelessWidget {
  final Database database;

  EnhancedAbout({required this.database});

  @override
  Widget build(BuildContext context) {
    final config = observeConfig(database);
    final license = observeLicense(database);

    return About(config: config, license: license);
  }
}

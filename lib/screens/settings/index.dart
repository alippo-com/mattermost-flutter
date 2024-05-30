// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mattermost_flutter/types/database.dart';

import 'settings.dart';

class SettingsScreen extends StatelessWidget {
  final Database database;

  SettingsScreen({required this.database});

  @override
  Widget build(BuildContext context) {
    final helpLinkStream = observeConfigValue(database, 'HelpLink');
    final showHelpStream = helpLinkStream.switchMap((link) => 
      Stream.value(link != null && isValidUrl(link))
    );
    final siteNameStream = observeConfigValue(database, 'SiteName');

    return StreamBuilder(
      stream: CombineLatestStream.list([helpLinkStream, showHelpStream, siteNameStream]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final helpLink = snapshot.data[0];
        final showHelp = snapshot.data[1];
        final siteName = snapshot.data[2];

        return Settings(
          helpLink: helpLink,
          showHelp: showHelp,
          siteName: siteName,
        );
      },
    );
  }
}

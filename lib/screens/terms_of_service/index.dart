// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database/database.dart';
import 'package:mattermost_flutter/queries/system.dart';
import 'package:mattermost_flutter/queries/terms_of_service.dart';
import 'package:mattermost_flutter/screens/terms_of_service/terms_of_service.dart';

class TermsOfServiceScreen extends StatefulWidget {
  @override
  _TermsOfServiceScreenState createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  final Database _database = DatabaseProvider().database;

  Stream<String?> get siteNameStream => observeConfigValue(_database, 'SiteName');
  Stream<bool> get showToSStream => observeShowToS(_database);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
      ),
      body: StreamBuilder<bool>(
        stream: showToSStream,
        builder: (context, showToSSnapshot) {
          if (showToSSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (showToSSnapshot.hasError) {
            return Center(child: Text('Error: ${showToSSnapshot.error}'));
          }

          return StreamBuilder<String?>(
            stream: siteNameStream,
            builder: (context, siteNameSnapshot) {
              if (siteNameSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (siteNameSnapshot.hasError) {
                return Center(child: Text('Error: ${siteNameSnapshot.error}'));
              }

              return TermsOfService(
                siteName: siteNameSnapshot.data,
                showToS: showToSSnapshot.data ?? false,
              );
            },
          );
        },
      ),
    );
  }
}

// Assuming the TermsOfService widget is defined in terms_of_service.dart
// and accepts siteName and showToS as parameters.

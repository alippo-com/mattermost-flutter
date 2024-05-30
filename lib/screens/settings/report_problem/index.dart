// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/database.dart';
import 'package:mattermost_flutter/observables.dart';
import 'package:mattermost_flutter/screens/settings/report_problem/report_problem.dart';

class EnhancedReportProblem extends StatelessWidget {
  final Database database;

  EnhancedReportProblem({required this.database});

  @override
  Widget build(BuildContext context) {
    final buildNumber = observeConfigValue(database, 'BuildNumber');
    final currentTeamId = observeCurrentTeamId(database);
    final currentUserId = observeCurrentUserId(database);
    final supportEmail = observeConfigValue(database, 'SupportEmail');
    final version = observeConfigValue(database, 'Version');

    return ReportProblem(
      buildNumber: buildNumber,
      currentTeamId: currentTeamId,
      currentUserId: currentUserId,
      supportEmail: supportEmail,
      version: version,
    );
  }
}

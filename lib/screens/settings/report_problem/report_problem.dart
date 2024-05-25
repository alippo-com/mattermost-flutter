// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:device_info/device_info.dart';
import 'package:share/share.dart';
import 'package:mattermost_flutter/components/settings/item.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/files.dart';
import 'package:mattermost_flutter/utils/tap.dart';

class ReportProblem extends StatelessWidget {
  final String buildNumber;
  final String currentTeamId;
  final String currentUserId;
  final String supportEmail;
  final String version;
  final String siteName;

  ReportProblem({
    required this.buildNumber,
    required this.currentTeamId,
    required this.currentUserId,
    required this.supportEmail,
    required this.version,
    required this.siteName,
  });

  Future<void> openEmailClient(BuildContext context) async {
    final theme = useTheme(context);
    final deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    final iosInfo = await deviceInfoPlugin.iosInfo;

    final appVersion = '1.0.0';  // Replace with actual app version
    final appBuild = '1';  // Replace with actual build number
    final deviceId = Platform.isAndroid ? androidInfo.androidId : iosInfo.identifierForVendor;

    try {
      final logPaths = await TurboLogger.getLogPaths();
      final attachments = logPaths.map((path) => pathWithPrefix('file://', path)).toList();
      await Share.share(
        'Problem with $siteName Flutter app\n'
        'Please share a description of the problem:\n\n'
        'Current User Id: $currentUserId\n'
        'Current Team Id: $currentTeamId\n'
        'Server Version: $version (Build $buildNumber)\n'
        'App Version: $appVersion (Build $appBuild)\n'
        'App Platform: ${Platform.operatingSystem}\n'
        'Device Model: $deviceId\n',
        subject: 'Problem with $siteName Flutter app',
        email: supportEmail,
        attachments: attachments,
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);

    return SettingItem(
      optionLabelTextStyle: TextStyle(color: theme.linkColor),
      onTap: () => preventDoubleTap(() => openEmailClient(context)),
      optionName: 'report_problem',
      separator: false,
      testID: 'settings.report_problem.option',
      type: 'default',
    );
  }
}

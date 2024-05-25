// Converted from notification_mention.tsx
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';

import 'package:mattermost_flutter/components/settings/container.dart';
import 'mention_settings.dart';
import 'package:mattermost_flutter/types/database/models/servers/user.dart';
import 'package:mattermost_flutter/types/screens/navigation.dart';

class NotificationMention extends StatelessWidget {
  final AvailableScreens componentId;
  final UserModel? currentUser;
  final bool isCRTEnabled;

  NotificationMention({
    required this.componentId,
    this.currentUser,
    required this.isCRTEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SettingContainer(
      testID: 'mention_notification_settings',
      child: MentionSettings(
        currentUser: currentUser,
        componentId: componentId,
        isCRTEnabled: isCRTEnabled,
      ),
    );
  }
}

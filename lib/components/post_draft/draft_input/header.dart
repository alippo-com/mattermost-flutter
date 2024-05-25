// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:mattermost_flutter/components/compass_icon.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/post_priority/post_priority_label.dart';
import 'package:mattermost_flutter/constants/post_priority_colors.dart';
import 'package:mattermost_flutter/context/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';

class DraftInputHeader extends StatelessWidget {
  final PostPriority postPriority;
  final bool noMentionsError;

  const DraftInputHeader({
    Key? key,
    required this.postPriority,
    required this.noMentionsError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final hasLabels = postPriority.priority.isNotEmpty || postPriority.requestedAck;
    final style = getStyleSheet(theme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (postPriority.priority.isNotEmpty)
          PostPriorityLabel(label: postPriority.priority),
        if (postPriority.requestedAck) ...[
          CompassIcon(
            color: theme.onlineIndicator,
            name: 'check-circle-outline',
            size: 14,
          ),
          if (postPriority.priority.isEmpty)
            FormattedText(
              id: 'requested_ack.title',
              defaultMessage: 'Request Acknowledgements',
              style: TextStyle(color: theme.onlineIndicator),
            ),
        ],
        if (postPriority.persistentNotifications) ...[
          CompassIcon(
            color: PostPriorityColors.urgent,
            name: 'bell-ring-outline',
            size: 14,
          ),
          if (noMentionsError)
            FormattedText(
              id: 'persistent_notifications.error.no_mentions.title',
              defaultMessage: 'Recipients must be @mentioned',
              style: TextStyle(color: PostPriorityColors.urgent),
            ),
        ],
      ],
    ).paddingOnly(left: 12).paddingTop(
      hasLabels
          ? Platform.isIOS
              ? 6
              : 8
          : 0,
    );
  }

  TextStyleSheet getStyleSheet(Theme theme) {
    return TextStyleSheet(
      container: TextStyle(
        flexDirection: Axis.horizontal,
        alignItems: CrossAxisAlignment.center,
        marginLeft: 12,
        gap: 7,
      ),
      error: TextStyle(color: PostPriorityColors.urgent),
      acknowledgements: TextStyle(color: theme.onlineIndicator),
      paddingTopStyle: TextStyle(
        paddingTop: Platform.isIOS ? 6 : 8,
      ),
    );
  }
}

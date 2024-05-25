// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/types/user_custom_status.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/widgets/custom_status/clear_button.dart';
import 'package:mattermost_flutter/widgets/custom_status/custom_status_expiry.dart';
import 'package:mattermost_flutter/widgets/formatted_text.dart';
import 'package:mattermost_flutter/widgets/custom_status/custom_status_text.dart';

class CustomLabel extends StatelessWidget {
  final UserCustomStatus customStatus;
  final bool isCustomStatusExpirySupported;
  final bool isStatusSet;
  final VoidCallback onClearCustomStatus;
  final bool showRetryMessage;

  CustomLabel({
    required this.customStatus,
    required this.isCustomStatusExpirySupported,
    required this.isStatusSet,
    required this.onClearCustomStatus,
    required this.showRetryMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = _getStyleSheet(theme);

    return Column(
      children: [
        Container(
          width: '70%',
          margin: EdgeInsets.only(left: 16),
          child: CustomStatusText(
            isStatusSet: isStatusSet,
            customStatus: customStatus,
            testID: 'account.custom_status.custom_status_text',
          ),
        ),
        if (isStatusSet &&
            isCustomStatusExpirySupported &&
            customStatus.duration != null)
          CustomStatusExpiry(
            time: DateFormat("yyyy-MM-ddTHH:mm:ssZ")
                .parse(customStatus.expiresAt),
            theme: theme,
            textStyles: styles['customStatusExpiryText'],
            withinBrackets: true,
            showPrefix: true,
            testID:
                'account.custom_status.custom_status_duration.${customStatus.duration}.custom_status_expiry',
          ),
        if (showRetryMessage)
          FormattedText(
            id: 'custom_status.failure_message',
            defaultMessage: 'Failed to update status. Try again',
            style: styles['retryMessage'],
            testID: 'account.custom_status.failure_message',
          ),
        if (isStatusSet)
          Positioned(
            top: 4,
            right: 14,
            child: ClearButton(
              handlePress: onClearCustomStatus,
              theme: theme,
              testID: 'account.custom_status.clear.button',
            ),
          ),
      ],
    );
  }

  Map<String, TextStyle> _getStyleSheet(ThemeData theme) {
    return {
      'customStatusTextContainer': TextStyle(
        width: '70%',
        marginLeft: 16,
      ),
      'customStatusExpiryText': TextStyle(
        paddingTop: 3,
        fontSize: 15,
        color: changeOpacity(theme.centerChannelColor, 0.35),
      ),
      'retryMessage': TextStyle(
        color: theme.errorTextColor,
        paddingBottom: 25,
      ),
    };
  }
}

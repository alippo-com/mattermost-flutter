// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/utils/constants.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';

class StatusLabel extends StatelessWidget {
  final String status;
  final TextStyle? labelStyle;

  const StatusLabel({
    Key? key,
    this.status = General.OFFLINE,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final style = _getStyleSheet(theme);

    String i18nId = t('status_dropdown.set_offline');
    String defaultMessage = 'Offline';

    switch (status) {
      case General.AWAY:
        i18nId = t('status_dropdown.set_away');
        defaultMessage = 'Away';
        break;
      case General.DND:
        i18nId = t('status_dropdown.set_dnd');
        defaultMessage = 'Do Not Disturb';
        break;
      case General.ONLINE:
        i18nId = t('status_dropdown.set_online');
        defaultMessage = 'Online';
        break;
      case General.OUT_OF_OFFICE:
        i18nId = t('status_dropdown.set_ooo');
        defaultMessage = 'Out Of Office';
        break;
    }

    return FormattedText(
      id: i18nId,
      defaultMessage: defaultMessage,
      style: style.label.merge(labelStyle),
      testID: 'user_status.label.$status',
    );
  }

  TextStyle _getStyleSheet(ThemeData theme) {
    return TextStyle(
      color: changeOpacity(theme.centerChannelColor, 0.5),
      fontSize: 14, // Assuming typography('Body', 200) translates to fontSize 14,
      fontWeight: FontWeight.normal, // Assuming typography('Body', 200) translates to FontWeight.normal
      textBaseline: TextBaseline.alphabetic,
      height: 1.5, // Assuming textAlignVertical: 'center' translates to height
      fontFamily: 'Roboto', // Assuming default font family
    );
  }
}

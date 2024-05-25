// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_text.dart'; // Assuming a similar component exists
import 'package:mattermost_flutter/types.dart'; // Assuming the types are defined here
import 'package:mattermost_flutter/i18n.dart'; // Assuming localization setup
import 'package:mattermost_flutter/utils/theme.dart'; // Assuming utility functions for theme

class Subtitle extends StatelessWidget {
  final ClientConfig config;

  Subtitle({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _getStyleSheet(theme);

    String id = t('about.teamEditionSt');
    String defaultMessage = 'All your team communication in one place, instantly searchable and accessible anywhere.';

    if (config.buildEnterpriseReady == 'true') {
      id = t('about.enterpriseEditionSt');
      defaultMessage = 'Modern communication from
 behind your firewall.';
    }

    return FormattedText(
      id: id,
      defaultMessage: defaultMessage,
      style: style.subtitle,
      testID: 'about.subtitle',
    );
  }

  _getStyleSheet(ThemeData theme) {
    return {
      'subtitle': TextStyle(
        color: theme.centerChannelColor.withOpacity(0.72),
        fontSize: 20.0, // Assuming 'Heading' is a font size of 20.0
        fontWeight: FontWeight.w400, // Assuming 'Regular' is a weight of 400
        textAlign: TextAlign.center,
        padding: EdgeInsets.symmetric(horizontal: 36.0),
      ),
    };
  }
}

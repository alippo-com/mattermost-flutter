// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';

class LearnMore extends StatelessWidget {
  final ClientConfig config;
  final VoidCallback onPress;

  LearnMore({required this.config, required this.onPress});

  @override
  Widget build(BuildContext context) {
    final theme = useTheme(context);
    final styles = getStyleSheet(theme);

    String id = t('about.teamEditionLearn');
    String defaultMessage = 'Join the Mattermost community at ';
    final String url = Config.websiteURL;

    if (config.buildEnterpriseReady == 'true') {
      id = t('about.enterpriseEditionLearn');
      defaultMessage = 'Learn more about Enterprise Edition at ';
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormattedText(
            id: id,
            defaultMessage: defaultMessage,
            style: styles['learn'],
            testID: 'about.learn_more.text',
          ),
          GestureDetector(
            onTap: onPress,
            child: Text(
              url,
              style: styles['learnLink'],
              testID: 'about.learn_more.url',
            ),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> getStyleSheet(ThemeData theme) {
    return {
      'learn': TextStyle(
        color: theme.centerChannelColor,
        fontSize: 20,
        fontWeight: FontWeight.normal,
      ),
      'learnLink': TextStyle(
        color: theme.linkColor,
        fontSize: 20,
        fontWeight: FontWeight.normal,
      ),
    };
  }
}

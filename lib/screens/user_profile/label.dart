// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/utils/typography.dart';
import 'package:provider/provider.dart';

class UserProfileLabel extends StatelessWidget {
  final String title;
  final String description;
  final String? testID;

  const UserProfileLabel({
    Key? key,
    required this.title,
    required this.description,
    this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final styles = _getStyleSheet(theme);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: styles['title'],
            key: Key('${testID ?? ''}.title'),
          ),
          const SizedBox(height: 2.0),
          Text(
            description,
            style: styles['description'],
            key: Key('${testID ?? ''}.description'),
          ),
        ],
      ),
    );
  }

  Map<String, TextStyle> _getStyleSheet(Theme theme) {
    return {
      'title': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.56),
        ...typography('Body', 50, FontWeight.w600),
      ),
      'description': TextStyle(
        color: theme.centerChannelColor,
        ...typography('Body', 200),
      ),
    };
  }
}

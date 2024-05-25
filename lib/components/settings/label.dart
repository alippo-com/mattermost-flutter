// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/types/theme.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';

class Label extends StatelessWidget {
  final String label;
  final bool optional;
  final String testID;

  const Label({
    Key? key,
    required this.label,
    required this.optional,
    required this.testID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final style = _getStyleSheet(theme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 10),
          child: Text(
            label,
            style: style['label'],
            key: Key('$testID.label'),
          ),
        ),
        if (!optional)
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Text(
              ' *',
              style: style['asterisk'],
            ),
          ),
        if (optional)
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: FormattedText(
              style: style['optional'],
              id: 'channel_modal.optional',
              defaultMessage: '(optional)',
            ),
          ),
      ],
    );
  }

  Map<String, dynamic> _getStyleSheet(Theme theme) {
    return {
      'labelContainer': const EdgeInsets.only(top: 15, bottom: 10),
      'label': TextStyle(
        fontSize: 14,
        color: theme.centerChannelColor,
        marginLeft: 15,
      ),
      'optional': TextStyle(
        color: changeOpacity(theme.centerChannelColor, 0.5),
        fontSize: 14,
        marginLeft: 5,
      ),
      'asterisk': TextStyle(
        color: theme.errorTextColor,
        fontSize: 14,
      ),
    };
  }
}

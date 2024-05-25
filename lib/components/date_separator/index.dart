// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:mattermost_flutter/components/formatted_date.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/utils/datetime.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:provider/provider.dart';

class DateSeparator extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;
  final String? timezone;

  const DateSeparator({
    Key? key,
    required this.date,
    this.style,
    this.timezone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Theme>(context);
    final styles = _getStyleSheet(theme);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            height: 1,
            color: theme.centerChannelColor.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: RecentDate(
            date: date,
            style: styles.date.merge(style),
          ),
        ),
        Flexible(
          child: Container(
            height: 1,
            color: theme.centerChannelColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  TextStyle _getStyleSheet(Theme theme) {
    return TextStyle(
      color: theme.centerChannelColor,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
  }
}

class RecentDate extends StatelessWidget {
  final DateTime date;
  final TextStyle? style;

  const RecentDate({
    Key? key,
    required this.date,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final when = date;

    if (isToday(when)) {
      return FormattedText(
        id: 'date_separator.today',
        defaultMessage: 'Today',
        style: style,
      );
    } else if (isYesterday(when)) {
      return FormattedText(
        id: 'date_separator.yesterday',
        defaultMessage: 'Yesterday',
        style: style,
      );
    }

    final format = isSameYear(when, DateTime.now()) ? 'MMM dd' : 'MMM dd, yyyy';

    return FormattedDate(
      format: format,
      value: date,
      style: style,
    );
  }
}

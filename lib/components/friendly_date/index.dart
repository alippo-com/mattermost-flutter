// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mattermost_flutter/types/constants.dart';
import 'package:mattermost_flutter/utils/datetime.dart';

class FriendlyDate extends StatelessWidget {
  final TextStyle? style;
  final DateTime? sourceDate;
  final DateTime value;

  FriendlyDate({this.style, required this.value, this.sourceDate});

  @override
  Widget build(BuildContext context) {
    final formattedTime = getFriendlyDate(value, sourceDate);
    return Text(
      formattedTime,
      style: style,
    );
  }

  String getFriendlyDate(DateTime inputDate, [DateTime? sourceDate]) {
    final today = sourceDate ?? DateTime.now();
    final date = inputDate;
    final difference = today.difference(date).inSeconds;

    // Message: Now
    if (difference < SECONDS['MINUTE']!) {
      return Intl.message(
        'Now',
        name: 'friendly_date_now',
      );
    }

    // Message: Minutes Ago
    if (difference < SECONDS['HOUR']!) {
      final minutes = (difference / SECONDS['MINUTE']!).floor();
      return Intl.message(
        '$minutes ${minutes == 1 ? 'min' : 'mins'} ago',
        name: 'friendly_date_minsAgo',
        args: [minutes],
        desc: 'Minutes ago',
      );
    }

    // Message: Hours Ago
    if (difference < SECONDS['DAY']!) {
      final hours = (difference / SECONDS['HOUR']!).floor();
      return Intl.message(
        '$hours ${hours == 1 ? 'hour' : 'hours'} ago',
        name: 'friendly_date_hoursAgo',
        args: [hours],
        desc: 'Hours ago',
      );
    }

    // Message: Days Ago
    if (difference < SECONDS['DAYS_31']!) {
      if (isYesterday(date)) {
        return Intl.message(
          'Yesterday',
          name: 'friendly_date_yesterday',
        );
      }
      final completedAMonth = today.month != date.month && today.day >= date.day;
      if (!completedAMonth) {
        final days = (difference / SECONDS['DAY']!).floor() || 1;
        return Intl.message(
          '$days ${days == 1 ? 'day' : 'days'} ago',
          name: 'friendly_date_daysAgo',
          args: [days],
          desc: 'Days ago',
        );
      }
    }

    // Message: Months Ago
    if (difference < SECONDS['DAYS_366']!) {
      final completedAnYear = today.year != date.year &&
          today.month >= date.month &&
          today.day >= date.day;
      if (!completedAnYear) {
        final months = (difference / SECONDS['DAYS_30']!).floor() || 1;
        return Intl.message(
          '$months ${months == 1 ? 'month' : 'months'} ago',
          name: 'friendly_date_monthsAgo',
          args: [months],
          desc: 'Months ago',
        );
      }
    }

    // Message: Years Ago
    final years = (difference / SECONDS['DAYS_365']!).floor() || 1;
    return Intl.message(
      '$years ${years == 1 ? 'year' : 'years'} ago',
      name: 'friendly_date_yearsAgo',
      args: [years],
      desc: 'Years ago',
    );
  }
}

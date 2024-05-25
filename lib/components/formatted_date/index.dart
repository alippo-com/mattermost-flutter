// Copyright (c) 2015-present Mattermost, Inc.
// All Rights Reserved. See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mattermost_flutter/types/user_timezone.dart';
import 'package:mattermost_flutter/i18n.dart';

class FormattedDate extends StatelessWidget {
  final String? format;
  final dynamic timezone;
  final dynamic value;
  final TextStyle? style;

  FormattedDate({
    this.format = 'MMM dd, yyyy',
    this.timezone,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final locale = getLocaleFromLanguage(Localizations.localeOf(context).languageCode.toLowerCase());
    DateFormat dateFormat = DateFormat(format, locale.toString());

    DateTime dateTime;
    if (value is String) {
      dateTime = DateTime.parse(value);
    } else if (value is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(value);
    } else {
      dateTime = value;
    }

    if (timezone != null) {
      String zone;
      if (timezone is UserTimezone) {
        zone = timezone.useAutomaticTimezone ? timezone.automaticTimezone : timezone.manualTimezone;
      } else {
        zone = timezone;
      }
      final location = tz.getLocation(zone);
      dateTime = tz.TZDateTime.from(dateTime, location);
    }

    String formattedDate = dateFormat.format(dateTime);

    return Text(formattedDate, style: style);
  }
}

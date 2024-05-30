// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rx_dart/rx.dart';
import 'package:mattermost_flutter/components/formatted_date.dart';
import 'package:mattermost_flutter/components/formatted_text.dart';
import 'package:mattermost_flutter/components/formatted_time.dart';
import 'package:mattermost_flutter/helpers/api/preference.dart';
import 'package:mattermost_flutter/queries/servers/preference.dart';
import 'package:mattermost_flutter/queries/servers/user.dart';
import 'package:mattermost_flutter/utils/theme.dart';
import 'package:mattermost_flutter/types/theme.dart';

class CustomStatusExpiry extends StatelessWidget {
  final UserModel? currentUser;
  final bool isMilitaryTime;
  final bool? showPrefix;
  final bool? showTimeCompulsory;
  final bool? showToday;
  final String? testID;
  final TextStyle? textStyles;
  final Theme theme;
  final DateTime time;
  final bool? withinBrackets;

  CustomStatusExpiry({
    this.currentUser,
    required this.isMilitaryTime,
    this.showPrefix,
    this.showTimeCompulsory,
    this.showToday,
    this.testID,
    this.textStyles,
    required this.theme,
    required this.time,
    this.withinBrackets,
  });

  @override
  Widget build(BuildContext context) {
    final userTimezone = getUserTimezoneProps(currentUser);
    final timezone = userTimezone.useAutomaticTimezone
        ? userTimezone.automaticTimezone
        : userTimezone.manualTimezone;
    final styles = getStyleSheet(theme);
    final currentMomentTime = getCurrentMomentForTimezone(timezone);
    final expiryMomentTime = timezone != null
        ? currentMomentTime.clone().add(Duration(milliseconds: time.millisecondsSinceEpoch))
        : time;
    final plusSixDaysEndTime = currentMomentTime.add(Duration(days: 6)).endOfDay;
    final tomorrowEndTime = currentMomentTime.add(Duration(days: 1)).endOfDay;
    final todayEndTime = currentMomentTime.endOfDay;
    final isCurrentYear = currentMomentTime.year == expiryMomentTime.year;

    Widget? dateComponent;
    if ((showToday == true && expiryMomentTime.isBefore(todayEndTime)) ||
        expiryMomentTime.isSame(todayEndTime)) {
      dateComponent = FormattedText(
        id: 'custom_status.expiry_time.today',
        defaultMessage: 'Today',
        style: styles.text.merge(textStyles),
      );
    } else if (expiryMomentTime.isAfter(todayEndTime) &&
        expiryMomentTime.isSameOrBefore(tomorrowEndTime)) {
      dateComponent = FormattedText(
        id: 'custom_status.expiry_time.tomorrow',
        defaultMessage: 'Tomorrow',
        style: styles.text.merge(textStyles),
      );
    } else if (expiryMomentTime.isAfter(tomorrowEndTime)) {
      String format = 'EEEE';
      if (expiryMomentTime.isAfter(plusSixDaysEndTime) && isCurrentYear) {
        format = 'MMM dd';
      } else if (!isCurrentYear) {
        format = 'MMM dd, yyyy';
      }

      dateComponent = FormattedDate(
        format: format,
        timezone: timezone,
        value: expiryMomentTime.toDate(),
        style: styles.text.merge(textStyles),
      );
    }

    final useTime = showTimeCompulsory ?? !(expiryMomentTime.isSame(todayEndTime) ||
        expiryMomentTime.isAfter(tomorrowEndTime));

    return Text(
      testID ?? '',
      style: styles.text.merge(textStyles),
      children: [
        if (withinBrackets == true) TextSpan(text: '('),
        if (showPrefix == true)
          FormattedText(
            id: 'custom_status.expiry.until',
            defaultMessage: 'Until',
            style: styles.text.merge(textStyles),
          ),
        if (showPrefix == true) TextSpan(text: ' '),
        if (dateComponent != null) dateComponent,
        if (useTime && dateComponent != null)
          TextSpan(
            children: [
              TextSpan(text: ' '),
              FormattedText(
                id: 'custom_status.expiry.at',
                defaultMessage: 'at',
                style: styles.text.merge(textStyles),
              ),
              TextSpan(text: ' '),
            ],
          ),
        if (useTime)
          FormattedTime(
            isMilitaryTime: isMilitaryTime,
            timezone: timezone ?? '',
            value: expiryMomentTime.toDate(),
            style: styles.text.merge(textStyles),
          ),
        if (withinBrackets == true) TextSpan(text: ')'),
      ],
    );
  }

  TextStyle getStyleSheet(Theme theme) {
    return TextStyle(
      fontSize: 15,
      color: theme.centerChannelColor,
    );
  }
}

class EnhancedCustomStatusExpiry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<Database>(context);
    return StreamProvider<UserModel?>(
      create: (_) => observeCurrentUser(database),
      initialData: null,
      child: Consumer<UserModel?>(
        builder: (context, currentUser, child) {
          return StreamProvider<bool>(
            create: (_) => queryDisplayNamePreferences(database).observeWithColumns(['value']).switchMap(
                  (preferences) => Rx.of(getDisplayNamePreferenceAsBool(preferences, 'use_military_time')),
                ),
            initialData: false,
            child: Consumer<bool>(
              builder: (context, isMilitaryTime, child) {
                return CustomStatusExpiry(
                  currentUser: currentUser,
                  isMilitaryTime: isMilitaryTime,
                  theme: Theme.of(context),
                  time: DateTime.now(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

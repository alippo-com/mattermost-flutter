import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moment/moment.dart';
import 'package:mattermost_flutter/types.dart';
import 'package:mattermost_flutter/i18n.dart';

class FormattedTime extends StatelessWidget {
  final bool isMilitaryTime;
  final dynamic timezone;
  final dynamic value;
  final TextStyle? style;

  FormattedTime({
    required this.isMilitaryTime,
    required this.timezone,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final moment = Moment.setLocale(getLocaleFromLanguage(locale).toLowerCase());

    String getFormattedTime() {
      String format = 'HH:mm';
      if (!isMilitaryTime) {
        final localeFormat = moment.localeData().longDateFormat('LT');
        format = localeFormat.contains('A') ? localeFormat : 'h:mm a';
      }

      String zone;
      if (timezone is UserTimezone) {
        zone = timezone.useAutomaticTimezone ? timezone.automaticTimezone : timezone.manualTimezone;
      } else {
        zone = timezone;
      }

      return timezone != null ? moment.tz(value, zone).format(format) : moment(value).format(format);
    }

    final formattedTime = getFormattedTime();

    return Text(
      formattedTime,
      style: style,
    );
  }
}

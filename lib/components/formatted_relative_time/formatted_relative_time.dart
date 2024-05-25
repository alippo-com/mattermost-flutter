
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mattermost_flutter/types/user_timezone.dart';
import 'package:mattermost_flutter/utils/datetime.dart';

class FormattedRelativeTime extends StatefulWidget {
  final UserTimezone? timezone;
  final dynamic value; // Can be int, String, or DateTime
  final int? updateIntervalInSeconds;
  final TextStyle? style;

  FormattedRelativeTime({
    this.timezone,
    required this.value,
    this.updateIntervalInSeconds,
    this.style,
  });

  @override
  _FormattedRelativeTimeState createState() => _FormattedRelativeTimeState();
}

class _FormattedRelativeTimeState extends State<FormattedRelativeTime> {
  late String formattedTime;
  late tz.Location location;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    location = tz.getLocation('UTC');
    formattedTime = getFormattedRelativeTime();

    if (widget.updateIntervalInSeconds != null) {
      Future.delayed(Duration(seconds: widget.updateIntervalInSeconds!), updateFormattedTime);
    }
  }

  String getFormattedRelativeTime() {
    var zone = widget.timezone;
    if (zone != null && zone is UserTimezone) {
      zone = zone.useAutomaticTimezone ? zone.automaticTimezone : zone.manualTimezone;
    }

    DateTime dateTime;
    if (widget.value is int) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(widget.value);
    } else if (widget.value is String) {
      dateTime = DateTime.parse(widget.value);
    } else {
      dateTime = widget.value;
    }

    dateTime = tz.TZDateTime.from(dateTime, location);

    return timeago.format(dateTime); // Using relative time format
  }

  void updateFormattedTime() {
    setState(() {
      formattedTime = getFormattedRelativeTime();
    });
    Future.delayed(Duration(seconds: widget.updateIntervalInSeconds!), updateFormattedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formattedTime,
      style: widget.style,
    );
  }
}

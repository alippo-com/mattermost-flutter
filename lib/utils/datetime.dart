// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

bool isSameDate(DateTime a, [DateTime b]) {
  b ??= DateTime.now();
  return a.day == b.day && isSameMonth(a, b) && isSameYear(a, b);
}

bool isSameMonth(DateTime a, [DateTime b]) {
  b ??= DateTime.now();
  return a.month == b.month && isSameYear(a, b);
}

bool isSameYear(DateTime a, [DateTime b]) {
  b ??= DateTime.now();
  return a.year == b.year;
}

bool isToday(DateTime date) {
  DateTime now = DateTime.now();

  return isSameDate(date, now);
}

bool isYesterday(DateTime date) {
  DateTime yesterday = DateTime.now().subtract(Duration(days: 1));

  return isSameDate(date, yesterday);
}

int toMilliseconds({int? days, int? hours, int? minutes, int? seconds}) {
  int totalHours = ((days ?? 0) * 24) + (hours ?? 0);
  int totalMinutes = (totalHours * 60) + (minutes ?? 0);
  int totalSeconds = (totalMinutes * 60) + (seconds ?? 0);
  return totalSeconds * 1000;
}

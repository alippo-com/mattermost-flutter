// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mattermost_flutter/constants/custom_status.dart';
import 'package:mattermost_flutter/constants/view.dart';
import 'package:mattermost_flutter/types/types.dart';

import 'package:flutter/services.dart';
import 'package:mattermost_flutter/utils/device.dart';

class Helpers {
  static bool isMinimumServerVersion(String currentVersion, int minMajorVersion, int minMinorVersion, int minDotVersion) {
    if (currentVersion.isEmpty) {
      return false;
    }

    final split = currentVersion.split('.');

    final major = int.parse(split[0]);
    final minor = int.parse(split.length > 1 ? split[1] : '0');
    final dot = int.parse(split.length > 2 ? split[2] : '0');

    if (major > minMajorVersion) {
      return true;
    }
    if (major < minMajorVersion) {
      return false;
    }

    // Major version is equal, check minor
    if (minor > minMinorVersion) {
      return true;
    }
    if (minor < minMinorVersion) {
      return false;
    }

    // Minor version is equal, check dot
    if (dot > minDotVersion) {
      return true;
    }
    if (dot < minDotVersion) {
      return false;
    }

    // Dot version is equal
    return true;
  }

  static String buildQueryString(Map<String, dynamic> parameters) {
    final keys = parameters.keys.toList();
    if (keys.isEmpty) {
      return '';
    }

    final query = keys.map((key) {
      if (parameters[key] == null) {
        return '';
      }
      return '$key=${Uri.encodeComponent(parameters[key].toString())}';
    }).join('&');

    return '?$query';
  }

  static bool isEmail(String email) {
    return RegExp(r'^[^ ,@]+@[^ ,@]+$').hasMatch(email);
  }

  static T identity<T>(T arg) {
    return arg;
  }

  static dynamic safeParseJSON(dynamic rawJson) {
    try {
      if (rawJson is String) {
        return jsonDecode(rawJson);
      }
    } catch (e) {
      // Do nothing
    }
    return rawJson;
  }

  static DateTime getCurrentMomentForTimezone(String? timezone) {
    return timezone != null ? DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').parse(timezone) : DateTime.now();
  }

  static int getUtcOffsetForTimeZone(String timezone) {
    // This would require a proper timezone library in Dart
    return DateTime.now().timeZoneOffset.inMinutes;
  }

  static String toTitleCase(String str) {
    return str.replaceAllMapped(RegExp(r'\w\S*'), (Match txt) {
      return '${txt.group(0)![0].toUpperCase()}${txt.group(0)!.substring(1).toLowerCase()}';
    });
  }

  static DateTime getRoundedTime(DateTime value) {
    final roundedTo = CUSTOM_STATUS_TIME_PICKER_INTERVALS_IN_MINUTES;
    final start = value;
    final diff = start.minute % roundedTo;
    if (diff == 0) {
      return value;
    }
    final remainder = roundedTo - diff;
    return start.add(Duration(minutes: remainder)).copyWith(second: 0, millisecond: 0);
  }

  static Future<bool> isTablet() async {
    final result = await Device.isTablet();
    return result;
  }

  static List<T> pluckUnique<T>(String key, List<Map<String, dynamic>> array) {
    final values = array.map((obj) => obj[key]).toSet().toList();
    return values;
  }

  static double bottomSheetSnapPoint(int itemsCount, double itemHeight, double bottomInset) {
    final bottom = Platform.isIOS ? bottomInset : 0 + STATUS_BAR_HEIGHT;
    return (itemsCount * itemHeight) + bottom;
  }

  static bool hasTrailingSpaces(String term) {
    return term.length != term.trimRight().length;
  }

  static bool isMainActivity() {
    return Platform.isIOS || (ShareModule.getCurrentActivityName() == 'MainActivity');
  }

  static bool areBothStringArraysEqual(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }

    if (a.isEmpty && b.isEmpty) {
      return false;
    }

    a.sort();
    b.sort();
    return a.every((value, index) => value == b[index]);
  }
}
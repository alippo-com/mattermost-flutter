// Converted from TypeScript to Dart

// Importing a Dart package equivalent to key_mirror
import 'package:flutter/foundation.dart';

// Mimicking the keyMirror functionality using Dart
Map<String, String> keyMirror(List<String> keys) {
  return Map.fromIterable(keys, key: (item) => item, value: (item) => item);
}

// Creating enum for events using the keyMirror functionality
enum Events {
  ACCOUNT_SELECT_TABLET_VIEW,
  CHANNEL_ARCHIVED,
  CHANNEL_SWITCH,
  CLOSE_BOTTOM_SHEET,
  CONFIG_CHANGED,
  FREEZE_SCREEN,
  GALLERY_ACTIONS,
  LEAVE_CHANNEL,
  LEAVE_TEAM,
  LOADING_CHANNEL_POSTS,
  NOTIFICATION_ERROR,
  REMOVE_USER_FROM_CHANNEL,
  MANAGE_USER_CHANGE_ROLE,
  SERVER_LOGOUT,
  SERVER_VERSION_CHANGED,
  SESSION_EXPIRED,
  TAB_BAR_VISIBLE,
  TEAM_LOAD_ERROR,
  TEAM_SWITCH,
  USER_TYPING,
  USER_STOP_TYPING,
  POST_LIST_SCROLL_TO_BOTTOM,
  SWIPEABLE,
  ITEM_IN_VIEWPORT,
  SEND_TO_POST_DRAFT,
  CRT_TOGGLED,
  JOIN_CALL_BAR_VISIBLE,
}

// Extension to make it easy to convert enum to string values
extension EventsExtension on Events {
  String get name => describeEnum(this);
}

// Use this to get string values from Events enum
final events = keyMirror(Events.values.map((e) => e.name).toList());
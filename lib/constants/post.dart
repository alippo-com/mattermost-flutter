// See LICENSE.txt for license information.

import 'package:mattermost_flutter/utils/datetime.dart';

class PostTypes {
  static const String CHANNEL_DELETED = 'system_channel_deleted';
  static const String CHANNEL_UNARCHIVED = 'system_channel_restored';
  static const String DISPLAYNAME_CHANGE = 'system_displayname_change';
  static const String CONVERT_CHANNEL = 'system_convert_channel';
  static const String EPHEMERAL = 'system_ephemeral';
  static const String EPHEMERAL_ADD_TO_CHANNEL = 'system_ephemeral_add_to_channel';
  static const String HEADER_CHANGE = 'system_header_change';
  static const String PURPOSE_CHANGE = 'system_purpose_change';

  static const String SYSTEM_MESSAGE_PREFIX = 'system_';
  static const String JOIN_LEAVE = 'system_join_leave';
  static const String JOIN_CHANNEL = 'system_join_channel';
  static const String GUEST_JOIN_CHANNEL = 'system_guest_join_channel';
  static const String LEAVE_CHANNEL = 'system_leave_channel';
  static const String ADD_REMOVE = 'system_add_remove';
  static const String ADD_TO_CHANNEL = 'system_add_to_channel';
  static const String ADD_GUEST_TO_CHANNEL = 'system_add_guest_to_chan';
  static const String REMOVE_FROM_CHANNEL = 'system_remove_from_channel';

  static const String JOIN_TEAM = 'system_join_team';
  static const String LEAVE_TEAM = 'system_leave_team';
  static const String ADD_TO_TEAM = 'system_add_to_team';
  static const String REMOVE_FROM_TEAM = 'system_remove_from_team';

  static const String COMBINED_USER_ACTIVITY = 'system_combined_user_activity';
  static const String ME = 'me';
  static const String ADD_BOT_TEAMS_CHANNELS = 'add_bot_teams_channels';

  static const String SYSTEM_AUTO_RESPONDER = 'system_auto_responder';
  static const String CUSTOM_CALLS = 'custom_calls';
  static const String CUSTOM_CALLS_RECORDING = 'custom_calls_recording';
}

class PostPriorityColors {
  static const String URGENT = '#D24B4E';
  static const String IMPORTANT = '#5D89EA';
}

enum PostPriorityType {
  STANDARD,
  URGENT,
  IMPORTANT,
}

class PostConstants {
  static const int POST_TIME_TO_FAIL = toMilliseconds(seconds: 10);

  static const int POST_COLLAPSE_TIMEOUT = toMilliseconds(minutes: 5);
  static const List<String> USER_ACTIVITY_POST_TYPES = [
    PostTypes.ADD_TO_CHANNEL,
    PostTypes.JOIN_CHANNEL,
    PostTypes.LEAVE_CHANNEL,
    PostTypes.REMOVE_FROM_CHANNEL,
    PostTypes.ADD_TO_TEAM,
    PostTypes.JOIN_TEAM,
    PostTypes.LEAVE_TEAM,
    PostTypes.REMOVE_FROM_TEAM,
  ];

  static const List<String> IGNORE_POST_TYPES = [
    PostTypes.ADD_REMOVE,
    PostTypes.ADD_TO_CHANNEL,
    PostTypes.CHANNEL_DELETED,
    PostTypes.CHANNEL_UNARCHIVED,
    PostTypes.JOIN_LEAVE,
    PostTypes.JOIN_CHANNEL,
    PostTypes.LEAVE_CHANNEL,
    PostTypes.REMOVE_FROM_CHANNEL,
    PostTypes.JOIN_TEAM,
    PostTypes.LEAVE_TEAM,
    PostTypes.ADD_TO_TEAM,
    PostTypes.REMOVE_FROM_TEAM,
  ];
}

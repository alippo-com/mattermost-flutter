// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/types/calls.dart';

class WebsocketEvents {
  static const String POSTED = 'posted';
  static const String POST_ACKNOWLEDGEMENT_ADDED = 'post_acknowledgement_added';
  static const String POST_ACKNOWLEDGEMENT_REMOVED =
      'post_acknowledgement_removed';
  static const String POST_EDITED = 'post_edited';
  static const String POST_DELETED = 'post_deleted';
  static const String POST_UNREAD = 'post_unread';
  static const String CATEGORY_CREATED = 'sidebar_category_created';
  static const String CATEGORY_UPDATED = 'sidebar_category_updated';
  static const String CATEGORY_DELETED = 'sidebar_category_deleted';
  static const String CATEGORY_ORDER_UPDATED = 'sidebar_category_order_updated';
  static const String CHANNEL_CONVERTED = 'channel_converted';
  static const String CHANNEL_CREATED = 'channel_created';
  static const String CHANNEL_DELETED = 'channel_deleted';
  static const String CHANNEL_UNARCHIVED = 'channel_restored';
  static const String CHANNEL_UPDATED = 'channel_updated';
  static const String CHANNEL_VIEWED = 'channel_viewed';
  static const String MULTIPLE_CHANNELS_VIEWED = 'multiple_channels_viewed';
  static const String CHANNEL_MEMBER_UPDATED = 'channel_member_updated';
  static const String CHANNEL_SCHEME_UPDATED = 'channel_scheme_updated';
  static const String DIRECT_ADDED = 'direct_added';
  static const String GROUP_ADDED = 'group_added';
  static const String ADDED_TO_TEAM = 'added_to_team';
  static const String LEAVE_TEAM = 'leave_team';
  static const String UPDATE_TEAM = 'update_team';
  static const String USER_ADDED = 'user_added';
  static const String USER_REMOVED = 'user_removed';
  static const String USER_UPDATED = 'user_updated';
  static const String USER_ROLE_UPDATED = 'user_role_updated';
  static const String ROLE_UPDATED = 'role_updated';
  static const String TYPING = 'typing';
  static const String STOP_TYPING = 'stop_typing';
  static const String PREFERENCE_CHANGED = 'preference_changed';
  static const String PREFERENCES_CHANGED = 'preferences_changed';
  static const String PREFERENCES_DELETED = 'preferences_deleted';
  static const String EPHEMERAL_MESSAGE = 'ephemeral_message';
  static const String STATUS_CHANGED = 'status_change';
  static const String HELLO = 'hello';
  static const String WEBRTC = 'webrtc';
  static const String REACTION_ADDED = 'reaction_added';
  static const String REACTION_REMOVED = 'reaction_removed';
  static const String EMOJI_ADDED = 'emoji_added';
  static const String LICENSE_CHANGED = 'license_changed';
  static const String CONFIG_CHANGED = 'config_changed';
  static const String PLUGIN_ENABLED = 'plugin_enabled';
  static const String PLUGIN_DISABLED = 'plugin_disabled';
  static const String PLUGIN_STATUSES_CHANGED = 'plugin_statuses_changed';
  static const String OPEN_DIALOG = 'open_dialog';
  static const String INCREASE_POST_VISIBILITY_BY_ONE =
      'increase_post_visibility_by_one';
  static const String MEMBERROLE_UPDATED = 'memberrole_updated';
  static const String THREAD_UPDATED = 'thread_updated';
  static const String THREAD_FOLLOW_CHANGED = 'thread_follow_changed';
  static const String THREAD_READ_CHANGED = 'thread_read_changed';
  static const String DELETE_TEAM = 'delete_team';
  static const String RESTORE_TEAM = 'restore_team';
  static const String APPS_FRAMEWORK_REFRESH_BINDINGS =
      'custom_com.mattermost.apps_refresh_bindings';
  static const String CALLS_CHANNEL_ENABLED =
      'custom_${Calls.PluginId}_channel_enable_voice';
  static const String CALLS_CHANNEL_DISABLED =
      'custom_${Calls.PluginId}_channel_disable_voice';
  static const String CALLS_USER_CONNECTED =
      'custom_${Calls.PluginId}_user_connected';
  static const String CALLS_USER_DISCONNECTED =
      'custom_${Calls.PluginId}_user_disconnected';
  static const String CALLS_USER_JOINED =
      'custom_${Calls.PluginId}_user_joined';
  static const String CALLS_USER_LEFT = 'custom_${Calls.PluginId}_user_left';
  static const String CALLS_USER_MUTED = 'custom_${Calls.PluginId}_user_muted';
  static const String CALLS_USER_UNMUTED =
      'custom_${Calls.PluginId}_user_unmuted';
  static const String CALLS_USER_VOICE_ON =
      'custom_${Calls.PluginId}_user_voice_on';
  static const String CALLS_USER_VOICE_OFF =
      'custom_${Calls.PluginId}_user_voice_off';
  static const String CALLS_CALL_START = 'custom_${Calls.PluginId}_call_start';
  static const String CALLS_CALL_END = 'custom_${Calls.PluginId}_call_end';
  static const String CALLS_SCREEN_ON =
      'custom_${Calls.PluginId}_user_screen_on';
  static const String CALLS_SCREEN_OFF =
      'custom_${Calls.PluginId}_user_screen_off';
  static const String CALLS_USER_RAISE_HAND =
      'custom_${Calls.PluginId}_user_raise_hand';
  static const String CALLS_USER_UNRAISE_HAND =
      'custom_${Calls.PluginId}_user_unraise_hand';
  static const String CALLS_USER_REACTED =
      'custom_${Calls.PluginId}_user_reacted';
  static const String CALLS_RECORDING_STATE =
      'custom_${Calls.PluginId}_call_recording_state';
  static const String CALLS_JOB_STATE =
      'custom_${Calls.PluginId}_call_job_state';
  static const String CALLS_HOST_CHANGED =
      'custom_${Calls.PluginId}_call_host_changed';
  static const String CALLS_USER_DISMISSED_NOTIFICATION =
      'custom_${Calls.PluginId}_user_dismissed_notification';
  static const String CALLS_CAPTION = 'custom_${Calls.PluginId}_caption';
  static const String GROUP_RECEIVED = 'received_group';
  static const String GROUP_MEMBER_ADD = 'group_member_add';
  static const String GROUP_MEMBER_DELETE = 'group_member_delete';
  static const String GROUP_ASSOCIATED_TO_TEAM =
      'received_group_associated_to_team';
  static const String GROUP_DISSOCIATED_TO_TEAM =
      'received_group_not_associated_to_team';
  static const String GROUP_ASSOCIATED_TO_CHANNEL =
      'received_group_associated_to_channel';
  static const String GROUP_DISSOCIATED_TO_CHANNEL =
      'received_group_not_associated_to_channel';
}

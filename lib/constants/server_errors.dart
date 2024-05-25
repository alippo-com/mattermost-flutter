// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class ServerErrors {
  static const String deletedRootPostError = 'api.post.create_post.root_id.app_error';
  static const String townSquareReadOnlyError = 'api.post.create_post.town_square_read_only';
  static const String pluginDismissedPostError = 'plugin.message_will_be_posted.dismiss_post';
  static const String sendEmailWithDefaultsError = 'api.team.invite_members.unable_to_send_email_with_defaults.app_error';
  static const String teamMembershipDenialErrorId = 'api.team.add_members.user_denied';
  static const String duplicateChannelName = 'store.sql_channel.save_channel.exists.app_error';
}

// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

import 'package:mattermost_flutter/constants.dart';
import 'package:mattermost_flutter/i18n.dart';

const Map<String, Map<String, Map<String, String>>> postTypeMessages = {
  Post.POST_TYPES.JOIN_CHANNEL: {
    'one': {
      'id': t('combined_system_message.joined_channel.one'),
      'defaultMessage': '{firstUser} **joined the channel**.',
    },
    'one_you': {
      'id': t('combined_system_message.joined_channel.one_you'),
      'defaultMessage': 'You **joined the channel**.',
    },
    'two': {
      'id': t('combined_system_message.joined_channel.two'),
      'defaultMessage': '{firstUser} and {secondUser} **joined the channel**.',
    },
    'many_expanded': {
      'id': t('combined_system_message.joined_channel.many_expanded'),
      'defaultMessage': '{users} and {lastUser} **joined the channel**.',
    },
  },
  Post.POST_TYPES.ADD_TO_CHANNEL: {
    'one': {
      'id': t('combined_system_message.added_to_channel.one'),
      'defaultMessage': '{firstUser} **added to the channel** by {actor}.',
    },
    'one_you': {
      'id': t('combined_system_message.added_to_channel.one_you'),
      'defaultMessage': 'You were **added to the channel** by {actor}.',
    },
    'two': {
      'id': t('combined_system_message.added_to_channel.two'),
      'defaultMessage': '{firstUser} and {secondUser} **added to the channel** by {actor}.',
    },
    'many_expanded': {
      'id': t('combined_system_message.added_to_channel.many_expanded'),
      'defaultMessage': '{users} and {lastUser} were **added to the channel** by {actor}.',
    },
  },
  Post.POST_TYPES.REMOVE_FROM_CHANNEL: {
    'one': {
      'id': t('combined_system_message.removed_from_channel.one'),
      'defaultMessage': '{firstUser} was **removed from the channel**.',
    },
    'one_you': {
      'id': t('combined_system_message.removed_from_channel.one_you'),
      'defaultMessage': 'You were **removed from the channel**.',
    },
    'two': {
      'id': t('combined_system_message.removed_from_channel.two'),
      'defaultMessage': '{firstUser} and {secondUser} were **removed from the channel**.',
    },
    'many_expanded': {
      'id': t('combined_system_message.removed_from_channel.many_expanded'),
      'defaultMessage': '{users} and {lastUser} were **removed from the channel**.',
    },
  },
  Post.POST_TYPES.LEAVE_CHANNEL: {
    'one': {
      'id': t('combined_system_message.left_channel.one'),
      'defaultMessage': '{firstUser} **left the channel**.',
    },
    'one_you': {
      'id': t('combined_system_message.left_channel.one_you'),
      'defaultMessage': 'You **left the channel**.',
    },
    'two': {
      'id': t('combined_system_message.left_channel.two'),
      'defaultMessage': '{firstUser} and {secondUser} **left the channel**.',
    },
    'many_expanded': {
      'id': t('combined_system_message.left_channel.many_expanded'),
      'defaultMessage': '{users} and {lastUser} **left the channel**.',
    },
  },
  Post.POST_TYPES.JOIN_TEAM: {
    'one': {
      'id': t('combined_system_message.joined_team.one'),
      'defaultMessage': '{firstUser} **joined the team**.',
    },
    'one_you': {
      'id': t('combined_system_message.joined_team.one_you'),
      'defaultMessage': 'You **joined the team**.',
    },
    'two': {
      'id': t('combined_system_message.joined_team.two'),
      'defaultMessage': '{firstUser} and {secondUser} **joined the team**.',
    },
    'many_expanded': {
      'id': t('combined_system_message.joined_team.many_expanded'),
      'defaultMessage': '{users} and {lastUser} **joined the team**.',
    },
  },
  Post.POST_TYPES.ADD_TO_TEAM: {
    'one': {
      'id': t('combined_system_message.added_to_team.one'),
      'defaultMessage': '{firstUser} **added to the team** by {actor}.',
    },
    'one_you': {
      'id': t('combined_system_message.added_to_team.one_you'),
      'defaultMessage': 'You were **added to the team** by {actor}.',
    },
    'two': {
      'id': t('combined_system_message.added_to_team.two'),
      'defaultMessage': '{firstUser} and {secondUser} **added to the team** by {actor}.',
    },
    'many_expanded': {
      'id': t('combined_system_message.added_to_team.many_expanded'),
      'defaultMessage': '{users} and {lastUser} were **added to the team** by {actor}.',
    },
  },
  Post.POST_TYPES.REMOVE_FROM_TEAM: {
    'one': {
      'id': t('combined_system_message.removed_from_team.one'),
      'defaultMessage': '{firstUser} was **removed from the team**.',
    },
    'one_you': {
      'id': t('combined_system_message.removed_from_team.one_you'),
      'defaultMessage': 'You were **removed from the team**.',
    },
    'two': {
      'id': t('combined_system_message.removed_from_team.two'),
      'defaultMessage': '{firstUser} and {secondUser} were **removed from the team**.',
    },
    'many_expanded': {
      'id': t('combined_system_message.removed_from_team.many_expanded'),
      'defaultMessage': '{users} and {lastUser} were **removed from the team**.',
    },
  },
  Post.POST_TYPES.LEAVE_TEAM: {
    'one': {
      'id': t('combined_system_message.left_team.one'),
      'defaultMessage': '{firstUser} **left the team**.',
    },
    'one_you': {
      'id': t('combined_system_message.left_team.one_you'),
      'defaultMessage': 'You **left the team**.',
    },
    'two': {
      'id': t('combined_system_message.left_team.two'),
      'defaultMessage': '{firstUser} and {secondUser} **left the team**.',
    },
    'many_expanded': {
      'id': t('combined_system_message.left_team.many_expanded'),
      'defaultMessage': '{users} and {lastUser} **left the team**.',
    },
  },
};

const Map<String, Map<String, String>> systemMessages = {
  Post.POST_TYPES.ADD_TO_CHANNEL: {
    'id': t('last_users_message.added_to_channel.type'),
    'defaultMessage': 'were **added to the channel** by {actor}.',
  },
  Post.POST_TYPES.JOIN_CHANNEL: {
    'id': t('last_users_message.joined_channel.type'),
    'defaultMessage': '**joined the channel**.',
  },
  Post.POST_TYPES.LEAVE_CHANNEL: {
    'id': t('last_users_message.left_channel.type'),
    'defaultMessage': '**left the channel**.',
  },
  Post.POST_TYPES.REMOVE_FROM_CHANNEL: {
    'id': t('last_users_message.removed_from_channel.type'),
    'defaultMessage': 'were **removed from the channel**.',
  },
  Post.POST_TYPES.ADD_TO_TEAM: {
    'id': t('last_users_message.added_to_team.type'),
    'defaultMessage': 'were **added to the team** by {actor}.',
  },
  Post.POST_TYPES.JOIN_TEAM: {
    'id': t('last_users_message.joined_team.type'),
    'defaultMessage': '**joined the team**.',
  },
  Post.POST_TYPES.LEAVE_TEAM: {
    'id': t('last_users_message.left_team.type'),
    'defaultMessage': '**left the team**.',
  },
  Post.POST_TYPES.REMOVE_FROM_TEAM: {
    'id': t('last_users_message.removed_from_team.type'),
    'defaultMessage': 'were **removed from the team**.',
  },
};

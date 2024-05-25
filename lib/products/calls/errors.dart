
// Copyright (c) 2015-present Mattermost, Inc. All Rights Reserved.
// See LICENSE.txt for license information.

class UserRemovedFromChannelError implements Exception {
  final String message = 'user was removed from channel';
}

class UserLeftChannelError implements Exception {
  final String message = 'user has left channel';
}
